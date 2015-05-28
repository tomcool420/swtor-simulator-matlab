classdef Sniper < Simulator.BaseSimulator
    %SNIPER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        instant_ls=false;
        last_instant_ls_used=-1;
        last_instant_ls_proc=-1;
    end
    
    methods
        function UseTargetAcquired(obj,name)
            if(nargin<2)
                name='Target Acquired';
            end
           obj.buffs.TA.LastUsed=obj.nextCast;
           %Take into account the 4pc/old2pc for CD
           baseCD=120-15*obj.stats.old2pc-15*obj.stats.pc4; 
           obj.buffs.AD.Available=obj.nextCast+baseCD/(1+obj.stats.Alacrity);
           obj.activations{end+1}={obj.nextCast,name};
        end
        function UseLazeTarget(obj,name)
            if(nargin<2)
                name='Laze Target';
            end
           if(obj.nextCast>=obj.buffs.LT.Available)
               obj.autocrit_charges=obj.autocrit_charges+1+obj.stats.pc6;
               obj.buffs.LT.Available=obj.nextCast+60/(1+obj.stats.Alacrity);
               obj.buffs.LT.LastUsed=obj.nextCast;
               obj.activations{end+1}={obj.nextCast,name};
               obj.autocrit_last_proc=obj.nextCast; 
               obj.autocrit_proc_duration=20+obj.stats.pc6*20;
               %fprintf('woot laze target\n');
           else
               %disp('LT is not up yet');
           end
        end
        function bonuspen = CalculateBonusPen(obj,it,t)
            %Right before DR is calculated, check for bonus armor pen 
            %only use for cooldowns (illegal mods or target acquired
            ta=obj.buffs.TA.LastUsed;
            bonuspen=0;
            if(ta>=0 && ta+15>t)
                bonuspen=0.15;
            end
        end
        function [bacc]=CalculateBonusAccuracy(obj,t,~)
            ta=obj.buffs.TA.LastUsed;
            bacc=0;
            if(ta>=0 && ta+15>t)
                bacc=0.3;
            end
        end
        
        function UseSmugglersLuck(obj)
            obj.UseLazeTarget('Smuggler''s Luck');
        end
        function UseIllegalMods(obj)
           obj.UseTargetAcquired('Illegal Mods'); 
        end
    end
    
end

