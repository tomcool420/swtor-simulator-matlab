classdef Vanguard < Simulator.BaseSimulator
    %VANGUARD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function UseBattleFocus(obj)
            if(obj.nextCast>=obj.buffs.BF.Available)
                obj.buffs.BF.Available=obj.nextCast+obj.buffs.BF.CD*(1-obj.stats.Alacrity);
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

