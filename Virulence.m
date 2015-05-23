classdef Virulence < BaseSimulator
    %VIRULENCE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        instant_ls=false;
        last_instant_ls_used=-1;
        last_instant_ls_proc=-1;
    end
    
    methods
        function obj=Virulence(z)
            if(nargin<1)
                z='Sniper';
            end
            if(isstruct(z))
                LoadAbilities_(obj,z);
            elseif(ischar(z))
                if(ismember(z,'Gunslinger'))
                    LoadAbilities(obj,'json/DirtyFighting.json')
                else
                    LoadAbilities(obj,'json/Virulence.json')
                end
            end
            obj.autocrit_abilities = {'Cull','Ambush','Engineering Probe','Aimed Shot','Wounding Shots','Sabotage Charge'};
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
        function UseTargetAcquired(obj,name)
            if(nargin<2)
                name='Target Acquired';
            end
           obj.buffs.TA.LastUsed=obj.nextCast;
           %Take into account the 4pc/old2pc for CD
           baseCD=120-15*obj.stats.old2pc-15*obj.stats.pc4; 
           obj.buffs.AD.Available=obj.nextCast+baseCD*(1-obj.stats.Alacrity);
           obj.activations{end+1}={obj.nextCast,name};
        end
        function UseLazeTarget(obj,name)
            if(nargin<2)
                name='Laze Target';
            end
           if(obj.nextCast>=obj.buffs.LT.Available)
               obj.autocrit_charges=obj.autocrit_charges+1+obj.stats.pc6;
               obj.buffs.LT.Available=obj.nextCast+60*(1-obj.stats.Alacrity);
               obj.buffs.LT.LastUsed=obj.nextCast;
               obj.activations{end+1}={obj.nextCast,name};
           else
               %disp('LT is not up yet');
           end
        end
%%%%%%%%%%%%%%%%
%%% ABILITIES
%%%%%%%%%%%%%%%%
        function [isCast,CDLeft]=UseCorrosiveGrenade(obj)
            [isCast,CDLeft]=ApplyDot(obj,'CG',obj.abilities.cg);
        end
        function [isCast,CDLeft]=UseCorrosiveDart(obj)
            [isCast,CDLeft]=ApplyDot(obj,'CD',obj.abilities.cd);
        end
        function dr=CalculateBossDR(obj,~)
            extra_ap=0.0;
            ta=obj.buffs.TA.LastUsed;
            if(ta>=0 && ta+15>obj.nextCast)
                extra_ap=0.15;
            end
            ar=obj.boss_armor;
            ap=obj.raid_armor_pen+obj.armor_pen;
            
            dr=ar*(1-ap-extra_ap)/(ar*(1-ap-extra_ap)+240*60+800);
        end
        function [isCast,CDLeft]=UseWeakeningBlast(obj)
           [isCast,CDLeft]=ApplyInstantCast(obj,obj.abilities.wb);
        end
        function [isCast,CDLeft]=UseTakedown(obj)
            [isCast,CDLeft]=ApplyInstantCast(obj,obj.abilities.td);
        end
        function [isCast,CDLeft]=UseLethalShot(obj)
            if(obj.last_instant_ls_proc<obj.nextCast+6 && obj.last_instant_ls_proc>=0)
                [isCast,CDLeft]=ApplyInstantCast(obj,obj.abilities.ls_w);
                obj.last_instant_ls_used=obj.nextCast;
                obj.last_instant_ls_proc=-1;
            else
                [isCast,CDLeft]=ApplyCastAbilities(obj,obj.abilities.ls_w);
            end
        end
        function [isCast,CDLeft]=UseOverloadShot(obj)
            [isCast,CDLeft]=ApplyInstantCast(obj,obj.abilities.os);
        end
        function [isCast,CDLeft]=UseCull(obj)
            [isCast,CDLeft]=ApplyChanneledAbility(obj,obj.abilities.cull);
        end
        function [isCast,CDLeft]=UseSeriesOfShots(obj)
           [isCast,CDLeft]= ApplyChanneledAbility(obj,obj.abilities.sos);
        end
        function [isCast,CDLeft]=UseCoveredEscape(obj)
            [isCast,CDLeft]= ApplyDot(obj,'CM',obj.abilities.cm);
        end
        function [isCast,CDLeft]=UseRifleShot(obj)
            [isCast,CDLeft]=ApplyInstantCast(obj,obj.abilities.rs);
        end
        function UseCrouch(obj)
            if(obj.last_instant_ls_used<0|| ...
                obj.nextCast>obj.last_instant_ls_used+6)
                obj.last_instant_ls_proc=obj.nextCast;
            end
        end
            
%%%%%%%%%%%%%%%%%
%%% PUB ABILITIES
%%%%%%%%%%%%%%%%%
        function UseSmugglersLuck(obj)
            obj.UseLazeTarget('Smuggler''s Luck');
        end
        function UseIllegalMods(obj)
           obj.UseTargetAcquired('Illegal Mods'); 
        end
        function [isCast,CDLeft]=UseShrapBomb(obj)
            [isCast,CDLeft]=obj.UseCorrosiveGrenade();
        end
        function [isCast,CDLeft]=UseVitalShot(obj)
            [isCast,CDLeft]=obj.UseCorrosiveDart();
        end
        function [isCast,CDLeft]=UseHemorrhagingBlast(obj)
           [isCast,CDLeft]=obj.UseWeakeningBlast();
        end
        function [isCast,CDLeft]=UseQuickdraw(obj)
            [isCast,CDLeft]=obj.UseTakedown();
        end
        
        function [isCast,CDLeft]=UseDirtyBlast(obj)
            [isCast,CDLeft]=obj.UseLethalShot();
        end
        function [isCast,CDLeft]=UseWoundingShots(obj)
            [isCast,CDLeft]=obj.UseCull();
        end
        function [isCast,CDLeft]=UseSpeedShot(obj)
            [isCast,CDLeft]=obj.UseSeriesOfShots();
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
               ohd = (rand()*(ohx-ohn)+ohn)*(1+(s_.Surge+it.sb)*ohc)*ohh*0.3;
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
        function DOTCheck(obj,t)
           fn=fieldnames(obj.dots);
           for i = 1:size(fn,1)
              dot = fn{i};
              tn=obj.dots.(dot).NextTick;
              while(tn>0 && tn<=t) 
                    it=obj.abilities.(obj.dots.(dot).it);
                    [mhd,mhh,mhc]=CalculateDamage(obj,tn,it);
                    AddDamage(obj, {obj.dots.(dot).NextTick,it.name,mhd,mhc,mhh},it);
                    if(strcmp(dot,'CD') && rand()<0.15)
                        [mhd,mhh,mhc]=CalculateDamage(obj,tn,it);
                        AddDamage(obj,{tn,it.name,mhd,mhc,mhh},it);
                    end
                    if(t>=obj.dots.(dot).Expire)
                        obj.dots.(dot).NextTick=-1;
                    else
                        obj.dots.(dot).NextTick=tn+it.int*(1-obj.dots.(dot).Ala);
                    end
                    tn=obj.dots.(dot).NextTick;
              end
           end
        end 
        function [isCast,CDLeft]=ApplyDot(obj,dname,it)
            [isCast,CDLeft]=isAvailable(obj,it);
            if(~isCast)
                return;
            end
            t=obj.nextCast;
            obj.avail.(it.id)=t+it.CD*(1-obj.stats.Alacrity);
            DOTCheck(obj,t);
            [mhd,mhh,mhc]=CalculateDamage(obj,t,it);
            AddDamage(obj,{t,it.name,mhd,mhc,mhh},it);
            %double tick chance on CD
            if(strcmp(dname,'CD') && rand()<0.15)
                [mhd,mhh,mhc]=CalculateDamage(obj,t,it);
                AddDamage(obj,{t,it.name,mhd,mhc,mhh},it);
            end
            obj.activations{end+1}={t,it.name};
            obj.dots.(dname).Ala=obj.stats.Alacrity;
            obj.dots.(dname).LastUsed=t;
            obj.dots.(dname).NextTick=t+it.int*(1-obj.stats.Alacrity);
            obj.dots.(dname).Expire=t+it.dur*(1-obj.stats.Alacrity);
            obj.dots.(dname).WExpire=t+(it.dur+5)*(1-obj.stats.Alacrity);
            GCD=1.5*(1-obj.stats.Alacrity);
            DOTCheck(obj,t+GCD);
            obj.nextCast=t+GCD;
        end
          function AddDamage(obj,dmg,it)
            if(it.dmg_type==3 )
                if(obj.buffs.WB.LastUsed+obj.buffs.WB.Dur>dmg{1}...
                     && obj.buffs.WB.LastUsed>0 ...
                     && ~strcmp(it.id,'corr_mine'))
                     [mhd,mhh,mhc,ohd,ohh,ohc]=CalculateDamage(obj,dmg{1},obj.abilities.wb);
                     AddDamage(obj,{dmg{1},obj.abilities.wb.name,mhd,mhc,mhh},obj.abilities.wb);
                     if(ohd>=0)
                        AddDamage(obj,{dmg{1},[obj.abilities.wb.name ' OH'],ohd,ohc,ohh},obj.abilities.wb);
                     end
                end
             elseif(it.dmg_type==1)
                     dmg{3}=dmg{3}*(1-CalculateBossDR(obj,it));
             end
            if(obj.total_damage<obj.total_HP)
            %if(true)
                if(dmg{4}>0)
                    obj.crits=obj.crits+1;
                end
                obj.dmg_effects=obj.dmg_effects+1;
                obj.total_damage=obj.total_damage+dmg{3};
                obj.damage{end+1}=dmg;
                AddToStats(obj,dmg);
            end
        end
    end
    
end

