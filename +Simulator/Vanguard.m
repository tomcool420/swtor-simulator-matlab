classdef Vanguard < Simulator.BaseSimulator
    %VANGUARD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        missiles_loaded=0;
    end
    
    methods
        function obj=Vanguard()
           obj.energy.me=100;
           obj.energy.ce=100;
            
        end
        function EnergyCheck(obj,t)
           e=obj.energy;
           while(t>=e.next_tick);
               ce=e.ce;
               er=5;
               if(ce<60 && ce>30)
                   er=4;
               elseif(ce<30)
                   er=3;
               end
               e.ce=min(ce+er/(1-obj.stats.Alacrity),e.me);
               e.next_tick=e.next_tick+1.0;
           end
           obj.energy=e;
        end
        function UseBattleFocus(obj)
            if(obj.nextCast>=obj.buffs.BF.Available)
                obj.buffs.BF.Available=obj.nextCast+obj.buffs.BF.CD/(+-obj.stats.Alacrity);
                obj.buffs.BF.LastUsed=obj.nextCast;
                %fprintf('Using Battle Focus (%.1f)\n',obj.nextCast)
                obj.activations{end+1}={obj.nextCast,'Battle Focus'};
            end
        end
        
        function [bd, bc,bs,bm]=CalculateBonus(obj,t,it,mhh,ohh)
            bd=0;bc=0;bs=0;bm=1;
            if(obj.buffs.BF.LastUsed>=0 && obj.buffs.BF.LastUsed+obj.buffs.BF.Dur>t)
                bc=0.25;
            end
        end
        

    end
    
end

