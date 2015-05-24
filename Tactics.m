classdef Tactics < BaseSimulator
    %TACTICS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        missiles_loaded=0;
    end

    methods

        function obj=Tactics(z)
            if(nargin<1)
                z='PT';
            end
            if(isstruct(z))
                LoadAbilities_(obj,z);
            elseif(ischar(z))
                if(ismember(z,'Vanguard'))
                    LoadAbilities(obj,'json/Tactics.json')
                else
                    LoadAbilities(obj,'json/Tactics.json')
                end
            end
            obj.autocrit_abilities = {'Cull','Ambush','Engineering Probe','Cell Burst','Fire Pulse'};
            obj.raid_armor_pen=0.2;
        end
        function PreloadMissiles(obj)
            obj.missiles_loaded=7;
        end
        function PreloadCBCharges(obj)
            obj.abilities.cb.charges=4;
        end
%%%%%%%%%%%%%%%%%%
%%% USE FUNCTIONS
%%%%%%%%%%%%%%%%%%
        function UseBattleFocus(obj)
            if(obj.nextCast>=obj.buffs.BF.Available)
                obj.buffs.BF.Available=obj.nextCast+obj.buffs.BF.CD*(1-obj.stats.Alacrity);
                obj.buffs.BF.LastUsed=obj.nextCast;
                %fprintf('Using Battle Focus (%.1f)\n',obj.nextCast)
                obj.activations{end+1}={obj.nextCast,'Battle Focus'};
            end
        end
        function [isCast,CDLeft]=UseTacticalSurge(obj)
            [isCast,CDLeft]=obj.ApplyInstantCast(obj.abilities.ts);
        end
        function [isCast,CDLeft]=UseStockStrike(obj)
            [isCast,CDLeft]=obj.ApplyInstantCast(obj.abilities.ss);
        end
        function [isCast,CDLeft]=UseHighImpactBolt(obj)
            [isCast,CDLeft]=obj.ApplyInstantCast(obj.abilities.hib);
        end
        function [isCast,CDLeft]=UseGut(obj)
            [isCast,CDLeft]=obj.ApplyInstantCast(obj.abilities.gut);
            
        end
        function [isCast,CDLeft]=UseCellBurst(obj)
            [isCast,CDLeft]=obj.ApplyInstantCast(obj.abilities.cb);
        end
        function [isCast,CDLeft]=UseHammerShot(obj)
            [isCast,CDLeft]=obj.ApplyInstantCast(obj.abilities.hs);
        end
        function [isCast,CDLeft]=UseAssaultPlastique(obj)
            [isCast,CDLeft]=obj.ApplyDot('AP',obj.abilities.ap);
        end
        function UseShoulderCannon(obj)
            if(obj.missiles_loaded==0)
                obj.missiles_loaded=7;
                obj.activations{end+1}={obj.nextCast,'Loading Shoulder Cannon'};
                %fprintf('Reloading Shoulder Cannon %.02f\n',obj.nextCast);
            else
                obj.ApplyInstantCast(obj.abilities.sc);
                obj.missiles_loaded=obj.missiles_loaded-1;
            end
            
        end
        
%%%%%%%%%%%%%%%%%%
%%% CALLBACKS
%%%%%%%%%%%%%%%%%%
        function HIBCallback(obj,t,~)
            if(obj.abilities.cb.charges<4)
                obj.abilities.cb.charges=obj.abilities.cb.charges+1;
            end
            if(obj.dots.GUT.Expire>t)
                DOTCheck(obj,t);
                ApplyDot(obj,'GUT',obj.abilities.gutd,1);
            end
        end
        function ProcCallback(obj,t,it)
            ia=obj.procs.IA;
            if(ia.LastProc<0 || (ia.LastProc+ia.CD*(1-ia.Ala)*.99)<=t)
               ia.LastProc=t;
               ia.Ala=obj.stats.Alacrity;
               obj.avail.hib=t;
               obj.procs.IA=ia;
            end
            if(strcmp(it.id,'tacsurge'))
                if(obj.autocrit_last_proc+60<obj.nextCast || obj.autocrit_last_proc<0)
                   obj.autocrit_last_proc=obj.nextCast; 
                   obj.autocrit_proc_duration=30;
                   obj.autocrit_charges=1;
                   %fprintf('autocrit procced %0.2f\n',obj.nextCast);
                end
            end
        end
        function CBCallback(obj,t,~)
            obj.abilities.cb.charges=0;
        end
        function GUTCallback(obj,~,~)
             obj.ApplyDot('GUT',obj.abilities.gutd,1);
        end
    
    function [mhd,mhh,mhc,ohd,ohh,ohc] = CalculateDamage(obj,t,it,autocrit)
            if(nargin<4)
                autocrit = false;
            end
%             if(autocrit)
%                 fprintf('woo autocrit %.2f\n',t)
%             end
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
            bonuscrit=0;
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
            %is BattleFocus Active
            if(obj.buffs.BF.LastUsed>=0 && obj.buffs.BF.LastUsed+obj.buffs.BF.Dur>t)
                bonuscrit=0.25;
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
               
               ohc = max(autocrit,rand()<(obj.stats.CritChance+bonuscrit+it.cb));
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
            mhc = max(rand()<(obj.stats.CritChance+it.cb+bonuscrit),autocrit);
            
            mhh = rand()<(obj.stats.Accuracy+it.base_acc-obj.boss_def+bonusacc);
            mhd = (rand()*(mhx-mhm)+mhm)*(1+(s_.Surge+it.sb)*mhc)*mhh;
            if(isfield(it,'charges'))
                mhd=mhd*it.charges; 
            end
            %fprintf('%f %f %f\n',mhm,mhx,mhd);
            %2PC set bonus
            if(t<obj.procs.CT.LastProc+15 && obj.procs.CT.LastProc>=0)
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



