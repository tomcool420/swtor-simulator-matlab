classdef Serenity < Shadow
    %SERENITY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
      function obj=Serenity(z)
            if(nargin<1)
                z='Assassin';
            end
            if(isstruct(z))
                LoadAbilities_(obj,z);
            elseif(ischar(z))
                if(ismember(z,'Shadow'))
                    LoadAbilities(obj,'json/Serenity.json')
                else
                    LoadAbilities(obj,'json/Serenity.json')
                end
            end
            obj.autocrit_abilities = {'Spinning Strike'};
            obj.raid_armor_pen=0.2;
      end
        
      function [isCast,CDLeft]=UseSaberStrike(obj)
          [isCast,CDLeft]=ApplyInstantCast(obj,obj.abilities.sas);
      end
      function [isCast,CDLeft]=UseSpinningStrike(obj)
          %need to add 30% check AND proc check
          [isCast,CDLeft]=ApplyInstantCast(obj,obj.abilities.sps);
      end
      function [isCast,CDLeft]=UseDoubleStrike(obj)
          [isCast,CDLeft]=ApplyInstantCast(obj,obj.abilities.ds); 
      end
      function [isCast,CDLeft]=UseVanquish(obj)
          if(false )%instantproc check here,apply vq dot in callback
            [isCast,CDLeft]=ApplyInstantCast(obj,obj.abilities.vq);
          else 
            [isCast,CDLeft]=ApplyCastAbility(obj,obj.abilities.vq); 
          end
          
      end
      function [isCast,CDLeft]=UseForceInBalance(obj)
           [isCast,CDLeft]=ApplyInstantCast(obj.abilities.fib);
      end
      function [isCast,CDLeft]=UseSeverForce(obj)
           [isCast,CDLeft]=ApplyDot(obj.abilities.sf);
      end
      function [isCast,CDLeft]=UseForceBreach(obj)
          [isCast,CDLeft]=ApplyDot(obj.abilities.fb);
      end
      function [isCast,CDLeft]=UseSerenityStrike(obj)
          [isCast,CDLeft]=ApplyInstantCast(obj.abilities.ses);
      end
      
      function VQCallback(obj,~,~)
         ApplyDot(obj,obj.abilities.vqd,1); 
      end
%Crush Spirit check goes into the dot check
%Force Synergy check goes into add damage
%Add Force Technique to the Add Damage
      
    end
    
end

