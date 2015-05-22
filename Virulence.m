classdef Virulence < BaseSimulator
    %VIRULENCE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods
        function obj=Virulence(varargin)
            LoadAbilities(obj,'Virulence.json')
        end
        function WBCallback(obj,t,~)
            obj.buffs.WB.LastUsed=t;
        end
  
        function LSCallback(obj,t,~)
            if(obj.stats.pc2 &&(t>=(obj.procs.FT.LastProc+obj.procs.FT.CD) ...
                            || obj.procs.FT.LastProc<0))
                obj.procs.FT.LastProc=t;
            end
            ApplyInstantCast(obj,obj.abilities.ls_i);
        end
        function CullCallback(obj,t,it)
            if(t<obj.dots.CD.WExpire)
                [mhd,mhh,mhc]=CalculateDamage(obj,t,obj.abilities.cd);
                 AddDamage(obj, {t,obj.abilities.cd.name,mhd,mhc,mhh},obj.abilities.cd);
            end
            if(t<obj.dots.CG.WExpire)
                [mhd,mhh,mhc]=CalculateDamage(obj,t,obj.abilities.cg);
                 AddDamage(obj, {t,obj.abilities.cg.name,mhd,mhc,mhh},obj.abilities.cg);
            end 
        end
        
%%%%%%%%%%%%%%%%%%%%%%%
%%%  BUFFS
%%%%%%%%%%%%%%%%%%%%%%%
        function UseTargetAcquired(obj)
           obj.buffs.TA.LastUsed=obj.nextCast;
           %Take into account the 4pc/old2pc for CD
           baseCD=120-15*obj.stats.old2pc-15*obj.stats.pc4; 
           obj.buffs.AD.Available=obj.nextCast+baseCD*(1-obj.stats.Alacrity);
           obj.activations{end+1}={obj.nextCast,'Target Acquired'};
        end
        function UseLazeTarget(obj)
           if(obj.nextCast>=obj.buffs.LT.Available)
               obj.autocrit_charges=obj.autocrit_charges+1+obj.stats.pc6;
               obj.buffs.LT.Available=obj.nextCast+60*(1-obj.stats.Alacrity);
               obj.buffs.LT.LastUsed=obj.nextCast;
               obj.activations{end+1}={obj.nextCast,'Laze Target'};
           else
               %disp('LT is not up yet');
           end
        end
%%%%%%%%%%%%%%%%
%%% ABILITIES
%%%%%%%%%%%%%%%%
        function UseCorrosiveGrenade(obj)
            ApplyDot(obj,'CG',obj.abilities.cg);
        end
        function UseCorrosiveDart(obj)
            ApplyDot(obj,'CD',obj.abilities.cd);
        end
        function dr=CalculateBossDR(obj,~)
            extra_ap=0.0;
            ta=obj.buffs.TA.LastUsed;
            if(ta>=0 && ta+15>obj.nextCast)
                extra_ap=0.15;
            end
            ar=obj.boss_armor;
            ap=obj.armor_pen;
            
            dr=ar*(1-ap-extra_ap)/(ar*(1-ap-extra_ap)+240*60+800);
        end
        function UseWeakeningBlast(obj)
           ApplyInstantCast(obj,obj.abilities.wb);
        end
        function UseTakedown(obj)
            ApplyInstantCast(obj,obj.abilities.td);
        end
        function UseLethalShot(obj)
            ApplyCastAbilities(obj,obj.abilities.ls_w);
        end
        function UseCull(obj)
            ApplyChanneledAbility(obj,obj.abilities.cull);
        end
        function UseSeriesOfShots(obj)
            ApplyChanneledAbility(obj,obj.abilities.sos);
        end
        
        function [mhd,mhh,mhc,ohd,ohh,ohc] = CalculateDamage(obj,t,it,autocrit)
            if(nargin<4)
                autocrit = false;
            end
            if(t>obj.procs.SA.LastProc+obj.procs.SA.CD)
                if(rand()<0.3)
                    obj.SAprocs=obj.SAprocs+1;
                    obj.procs.SA.LastProc=t;
                end
            end
            if(t>obj.procs.FR.LastProc+obj.procs.FR.CD)
                if(rand()<0.3)
                    obj.FRprocs=obj.FRprocs+1;
                    obj.procs.FR.LastProc=t;
                end
            end
            bonusdmg=0;
            bonusacc=0;
            %is Focused Retribution Procced
            if(obj.procs.FR.LastProc>=0 && obj.procs.FR.LastProc+6>t)
                bonusdmg = bonusdmg + obj.stats.FR_proc*0.2*1.05*1.05;
            end
            
            %is Serendipidous Procced
            if(obj.procs.SA.LastProc>=0 && obj.procs.SA.LastProc+6>t)
                bonusdmg = bonusdmg + obj.stats.SA_proc*0.23*1.05;
            end
            
            %is Adrenal Used
            if(obj.buffs.AD.LastUsed>=0 && obj.buffs.AD.LastUsed+15>t)
                bonusdmg = bonusdmg + obj.stats.adrenal_amt*0.23*1.05;
            end
            %is Target Acquired Active
            if(obj.buffs.TA.LastUsed>=0 && obj.buffs.TA.LastUsed+15>t)
                bonusacc=0.3;
            end
            s_=obj.stats;
            if(it.w==1)
               rbonus = bonusdmg+obj.stats.RangedBonus;
               mhm= (rbonus*it.c+...
                  s_.MinMH*(1+it.Am)+it.Sm*it.Sh)*it.mult;
               mhx= (rbonus*it.c+...
                  s_.MaxMH*(1+it.Am)+it.Sx*it.Sh)*it.mult;
               ohn= (s_.MinOH*(1+it.Am))*it.mult;
               ohx= (s_.MaxOH*(1+it.Am))*it.mult;
               
               ohc = max(autocrit,rand()<(obj.stats.CritChance+it.cb));
               ohh = rand()<(it.base_acc-obj.boss_def+obj.stats.Accuracy-0.3+bonusacc);
               ohd = (rand()*(ohx-ohn)+ohn)*(1+(s_.Surge+it.sb)*ohc)*ohh;
               if(ohn==0 || ohx==0)
                   ohd=-1;
               end
               %fprintf('%f %f %f\n',mhm,mhx,rbonus);
            else
                tbonus = bonusdmg+obj.stats.TechBonus;
                mhm=(tbonus*it.c+it.Sm*it.Sh)*it.mult;
                mhx=(tbonus*it.c+it.Sx*it.Sh)*it.mult;
                ohc=0; ohh=0; ohd=-1;
            end
            mhc = max(rand()<(obj.stats.CritChance+it.cb),autocrit);
            
            mhh = rand()<(obj.stats.Accuracy+it.base_acc-obj.boss_def+bonusacc);
            mhd = (rand()*(mhx-mhm)+mhm)*(1+(s_.Surge+it.sb)*mhc)*mhh;
            %fprintf('%f %f %f\n',mhm,mhx,mhd);
            %2PC set bonus
            if(t<obj.procs.FR.LastProc+15 && obj.procs.FR.LastProc>=0)
                mhd=mhd*1.02;
                ohd=ohd*1.02;
            end;
            %Apply Raid multipliers
            mhd=mhd*it.raid_mult;
            ohd=ohd*it.raid_mult;
            %Sub 30% damage multiplier
            if(obj.total_damage>obj.total_HP*0.7)
               mhd=mhd*(1+it.s30);
               ohd=ohd*(1+it.s30);
            end
            
            
        end
    end
    
end
