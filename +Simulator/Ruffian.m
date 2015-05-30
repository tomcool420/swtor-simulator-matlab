classdef Ruffian < Simulator.Scoundrel
    %RUFFIAN Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        weapon_mult=1.2;
    end
    
    methods
        function obj=Ruffian(z)
            if(nargin<1)
                z='Scoundrel';
            end
            if(isstruct(z))
                LoadAbilities_(obj,z);
            elseif(ischar(z))
                if(ismember(z,'Scoundrel'))
                    LoadAbilities(obj,'json/Ruffian.json')
                else
                    LoadAbilities(obj,'json/Marksman.json')
                end
            end 
            obj.autocrit_abilities = {'Blood Boiler'};
            obj.armor_pen=0.0;
            obj.raid_armor_pen=0.2;
        end
        function [isCast,CDLeft]=UseVitalShot(obj)
            [isCast,CDLeft]=ApplyDot(obj,'CD',obj.abilities.vit);
        end
        function [isCast,CDLeft]=UseQuickShot(obj)
            [isCast,CDLeft]=obj.ApplyInstantCast(obj.abilities.qui);
        end
        function [isCast,CDLeft]=UseFlurryOfBolts(obj)
           [isCast,CDLeft]=obj.ApplyInstantCast(obj.abilities.flu);
        end
        
        function [isCast,CDLeft]=ShrapBomb(obj)
            [isCast,CDLeft]=ApplyDot(obj,'CG',obj.abilities.shr);
        end
        function [isCast,CDLeft]=UsePointBlankShot(obj)
            if(obj.stealth==1)
                [isCast,CDLeft]=obj.ApplyInstantCast(obj.abilities.pois);
                obj.stealth=0;
            else
                [isCast,CDLeft]=obj.ApplyInstantCast(obj.abilities.poi);
            end
        end
        function [isCast,CDLeft]=UseBlasterWhip(obj)
            [isCast,CDLeft]=obj.ApplyInstantCast(obj.abilities.bla);
        end
        function [isCast,CDLeft]=SanguinaryShot(obj)
            [isCast,CDLeft]=obj.ApplyInstantCast(obj.abilities.bla);
        end
    end
    
end

