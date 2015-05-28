classdef Saboteur < Simulator.Sniper
    %MARKSMAN Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods
        function obj=Saboteur(z)
            if(nargin<1)
                z='MM';
            end
            if(isstruct(z))
                LoadAbilities_(obj,z);
            elseif(ischar(z))
                if(ismember(z,'Gunslinger'))
                    LoadAbilities(obj,'json/Saboteur.json')
                else
                    LoadAbilities(obj,'json/Marksman.json')
                end
            end 
            obj.autocrit_abilities = {'Cull','Ambush','Engineering Probe','Aimed Shot','Wounding Shots','Sabotage Charge'};
            obj.armor_pen=0.1;
            obj.raid_armor_pen=0.2;
        end
        
        function [isCast,CDLeft]=UseVitalShot(obj)
            [isCast,CDLeft]=ApplyDot(obj,'CD',obj.abilities.vit);
        end
        function [isCast,CDLeft]=UseSpeedShot(obj)
            [isCast,CDLeft]=ApplyChanneledAbility(obj,obj.abilities.spe);
        end
        function [isCast,CDLeft]=UseThermalGrenade(obj)
            [isCast,CDLeft]=ApplyInstantCast(obj,obj.abilities.the);
        end
        function [isCast,CDLeft]=UseShockCharge(obj)
            [isCast,CDLeft]=ApplyDot(obj,'SC',obj.abilities.sho);
        end
        function [isCast,CDLeft]=UseIncendiaryGrenade(obj)
            [isCast,CDLeft]=ApplyDot(obj,'IG',obj.abilities.inc);
        end
        function [isCast,CDLeft]=UseXSFreighterFlyby(obj)
            [isCast,CDLeft]=ApplyDot(obj,'XS',obj.abilities.xs);
        end
        function [isCast,CDLeft]=UseSabotageCharge(obj)
            [isCast,CDLeft]=ApplyInstantCast(obj,obj.abilities.sabo);
        end
        function [isCast,CDLeft]=UseFlurryOfBolts(obj)
            [isCast,CDLeft]=ApplyInstantCast(obj,obj.abilities.flu);
        end
        function [isCast,CDLeft]=UseQuickShot(obj)
            [isCast,CDLeft]=ApplyInstantCast(obj,obj.abilities.qui);
        end
    end
    
    
end

