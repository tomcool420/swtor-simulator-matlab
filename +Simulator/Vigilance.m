classdef Vigilance < Simulator.Guardian
    %VIGILANCE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj=Vigilance(z)
            if(nargin<1)
                z='Guardian';
            end
            if(isstruct(z))
                LoadAbilities_(obj,z);
            elseif(ischar(z))
                if(ismember(z,'Guardian'))
                    LoadAbilities(obj,'json/Vigilance.json')
                else
                    LoadAbilities(obj,'json/Vigilance.json')
                end
            end 
            obj.autocrit_abilities = {'Overhead Slash'};
            obj.armor_pen=0.0;
            obj.raid_armor_pen=0.2;
            obj.weapon_mult=1.2;
        end
%%%%%%%%%%%%%%%%
%%% ABILITIES
%%%%%%%%%%%%%%%%
        function [isCast,CDLeft]=UseOverheadSlash(obj)
           [isCast,CDLeft]=ApplyInstantCast(obj,obj.abilities.ove);
        end
        function [isCast,CDLeft]=UsePlasmaBrand(obj)
            [isCast,CDLeft]=ApplyInstantCast(obj,obj.abilities.pla);
        end
        function [isCast,CDLeft]=UseBladeStorm(obj)
            [isCast,CDLeft]=ApplyInstantCast(obj,obj.abilities.bla);
        end
        function [isCast,CDLeft]=UseVigilantThrust(obj)
            [isCast,CDLeft]=ApplyInstantCast(obj,obj.abilities.vig);
        end
        function [isCast,CDLeft]=UseSunder(obj)
            [isCast,CDLeft]=ApplyInstantCast(obj,obj.abilities.sun);
        end
        function [isCast,CDLeft]=UseStrike(obj)
            [isCast,CDLeft]=ApplyInstantCast(obj,obj.abilities.str);
        end
        function [isCast,CDLeft]=UseForceLeap(obj)
            [isCast,CDLeft]=ApplyInstantCast(obj,obj.abilities.forc);
        end
        function [isCast,CDLeft]=UseSaberThrow(obj)
            [isCast,CDLeft]=ApplyInstantCast(obj,obj.abilities.sab);
        end
        function [isCast,CDLeft]=UseDispatch(obj)
            [isCast,CDLeft]=ApplyInstantCast(obj,obj.abilities.dis);
        end
        function [isCast,CDLeft]=UseMasterStrike(obj)
            [isCast,CDLeft]=ApplyMasterStrike(obj,obj.abilities.mas);
        end

        
        
        function [bd, bc,bs,bm]=CalculateBonus(obj,~,it,~,~)
            bd=0;bc=0;bs=0;bm=1.06;
            if(it.w==1)
                bm=bm+0.03;
            end
            if(strcmpi(it.id,'blade_storm'))
                bc=bc+0.5*obj.procs.FRU.Charges;
            end
        end
        function PBCallback(obj,~,~)
            ApplyDot(obj,'PB',obj.abilities.plad,1); 
        end
        function OHCallback(obj,~,~)
            ApplyDot(obj,'BP',obj.abilities.burp,1); 
        end
        function BSCallback(obj,~,~)
            ApplyDot(obj,'BB',obj.abilities.burb,1); 
        end
        
        
        
        function AddDamageCB(obj,t,dmg,it)
            %"CallBack" (not) called right before the damage is applied
            %A good time to either proc on hit abilities (force technique) 
            %or on hit procs (force synergy)
            nm=it.id;
            if(strcmpi(nm,'plasma_brand'))
                obj.avail.master_strike=t;
            end
            if(strcmpi(nm,'plasma_brand')|| ...
                strcmpi(nm,'overhead_slash')|| ...
                strcmpi(nm,'dispatch'))
                fru = obj.procs.FRU;
                fru.LastProc=t;
                fru.Charges=min(fru.Charges+1,2);
                obj.procs.FRU=fru;
            elseif(strcmpi(nm,'blade_storm'))
                obj.procs.FRU.Charges=0;
            end
            
        end
    end
    
end

