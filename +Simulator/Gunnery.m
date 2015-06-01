classdef Gunnery <Simulator.Commando
    %GUNNERY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj=Gunnery(z)
            if(nargin<1)
                z='Commando';
            end
            if(isstruct(z))
                LoadAbilities_(obj,z);
            elseif(ischar(z))
                if(ismember(z,'Mercenary'))
                    LoadAbilities(obj,'json/Plasmatech.json')
                else
                    LoadAbilities(obj,'json/Gunnery.json')
                end
            end
            obj.autocrit_abilities = {'Demolition Round','Fire Pulse'};
            obj.raid_armor_pen=0.2;
        end
         function [isCast,CDLeft]=UseHighImpactBolt(obj)
            [isCast,CDLeft]=obj.ApplyInstantCast(obj.abilities.hig);
         end
         function [isCast,CDLeft]=UseHammerShot(obj)
            [isCast,CDLeft]=obj.ApplyInstantCast(obj.abilities.ham);
         end
         function [isCast,CDLeft]=UseElectroNet(obj)
            [isCast,CDLeft]=obj.ApplyDot('EN',obj.abilities.ele);
         end
         function [isCast,CDLeft]=UseFullAuto(obj)
            [isCast,CDLeft]=obj.ApplyChanneledAbility(obj.abilities.ful);
         end
         function [isCast,CDLeft]=UseGravRound(obj)
            [isCast,CDLeft]=obj.ApplyCastAbility(obj.abilities.gra);
         end
         function [isCast,CDLeft]=UseVortexBolt(obj)
            [isCast,CDLeft]=obj.ApplyInstantCast(obj.abilities.vor);
         end
         function [isCast,CDLeft]=UseDemolitionRound(obj)
            [isCast,CDLeft]=obj.ApplyInstantCast(obj.abilities.dem);
         end
        
    end
    
end

