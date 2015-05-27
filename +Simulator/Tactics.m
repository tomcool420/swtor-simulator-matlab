classdef Tactics < Simulator.Vanguard
    %TACTICS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
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
                    LoadAbilities(obj,'json/AP.json')
                end
            end
            obj.autocrit_abilities = {'Cell Burst','Fire Pulse','Energy Burst'};
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
            if(obj.procs.EL.Charges<4)
                obj.procs.EL.Charges=obj.procs.EL.Charges+1;
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
                if(obj.stats.pc2 &&(t>=(obj.procs.PC2.Available) ...
                            || obj.procs.PC2.LastProc<0))
                obj.procs.PC2.LastProc=t;
                obj.procs.PC2.Available=t+obj.procs.PC2.CD/(1+obj.stats.Alacrity)*0.99;
                end
            end
        end
        function CBCallback(obj,t,~)
            obj.procs.EL.Charges=0;
        end
        function GUTCallback(obj,~,~)
             obj.ApplyDot('GUT',obj.abilities.gutd,1);
        end
      function [bd, bc,bs,bm]=CalculateBonus(obj,t,it,mhh,ohh)
            [bd, bc,bs,bm]=CalculateBonus@Simulator.Vanguard(obj,t,it,mhh,ohh);
            if(strcmp(it.id,'cellburst'))
                EL=obj.procs.EL.Charges;
                bm=EL;
            end
            if(obj.dots.GUT.Expire>t)
                bm=bm*1.03;
            end
        end

    end
end



