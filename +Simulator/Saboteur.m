classdef Saboteur < Simulator.Sniper
    %MARKSMAN Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods
        function obj=Saboteur(z)
            if(nargin<1)
                z='Gunslinger';
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
            obj.armor_pen=0.0;
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
            [isCast,CDLeft]=ApplyDebuff(obj,'SC',obj.abilities.sabo);
        end
        function [isCast,CDLeft]=UseFlurryOfBolts(obj)
            [isCast,CDLeft]=ApplyInstantCast(obj,obj.abilities.flu);
        end
        function [isCast,CDLeft]=UseQuickShot(obj)
            [isCast,CDLeft]=ApplyInstantCast(obj,obj.abilities.qui);
        end
        function [isCast,CDLeft]=UseQuickdraw(obj)
            [isCast,CDLeft]=ApplyInstantCast(obj,obj.abilities.qd);
        end
        function [isCast,CDLeft]=UseSabotage(obj)
            [isCast,CDLeft]=ApplyInstantCast(obj,obj.abilities.sab);
        end
        
        
        function AddDamageCB(obj,t,dmg,it)
            %"CallBack" (not) called right before the damage is applied
            %A good time to either proc on hit abilities (force technique)
            %or on hit procs (force synergy)
            if(it.w==1 && dmg{3}>300 && (strcmp(it.id,'speed_shot')))% || strcmp(it.id,'charged_burst')||strcmp(it.id,'thermal_grenade')))
               ApplyDot(obj,'BS',obj.abilities.bla,1,t); 
            end
            if(obj.debuffs.SC.Charges>0)
                ac=isAutocrit(obj,obj.abilities.sabo);
                [mhd,mhh,mhc]=CalculateDamage(obj,t,obj.abilities.sabo,ac);
                if(mhh>0)
                    obj.debuffs.SC.Charges=0;
                    AddDamage(obj,{t,obj.abilities.sabo.name,mhd,mhc,mhh},obj.abilities.sabo);
                    if(ac==1)
                        obj.autocrit_charges=obj.autocrit_charges-1;
                    end
                    ApplyDebuff(obj,'CC',obj.abilities.con);
                end
%                [mhd,mhh,mhc]=obj.CalculateDamage(t,obj.abilities.ft);
%                AddDamage(obj,{t,obj.abilities.ft.name,mhd,mhc,mhh},obj.abilities.ft);
            elseif(it.w==1 && obj.debuffs.CC.Charges>0)
                [mhd,mhh,mhc]=CalculateDamage(obj,t,obj.abilities.con);
                if(mhh>0)
                    obj.debuffs.CC.Charges=obj.debuffs.CC.Charges-1;
                    AddDamage(obj,{t,obj.abilities.con.name,mhd,mhc,mhh},obj.abilities.con);
                end
            end
        end
        
        
        
    end
    
    
end

