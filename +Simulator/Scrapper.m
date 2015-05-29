classdef Scrapper<Simulator.Scoundrel
    %SCRAPPER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        
        function obj=Scrapper(z)
            if(nargin<1)
                z='Gunslinger';
            end
            if(isstruct(z))
                LoadAbilities_(obj,z);
            elseif(ischar(z))
                if(ismember(z,'Gunslinger'))
                    LoadAbilities(obj,'json/Scrapper.json')
                else
                    LoadAbilities(obj,'json/Marksman.json')
                end
            end 
            obj.autocrit_abilities = {'Blood Boiler'};
            obj.armor_pen=0.0;
            obj.raid_armor_pen=0.2;
        end
%%%%%%%%%%%%%%%%
%%% ABILITIES
%%%%%%%%%%%%%%%%
        function [isCast,CDLeft]=UseSuckerPunch(obj)
            [isCast,CDLeft]=obj.ApplyInstantCast(obj.abilities.suc);
        end
        function [isCast,CDLeft]=UseBludgeon(obj)
            [isCast,CDLeft]=obj.ApplyInstantCast(obj.abilities.blu);
        end
        function [isCast,CDLeft]=UseBloodBoiler(obj)
            [isCast,CDLeft]=obj.ApplyDebuff('BB',obj.abilities.blo);
        end
        function [isCast,CDLeft]=UseBackBlast(obj)
            if(obj.stealth==1)
                [isCast,CDLeft]=obj.ApplyInstantCast(obj.abilities.bacs);
                obj.stealth=0;
            else
                [isCast,CDLeft]=obj.ApplyInstantCast(obj.abilities.bac);
            end
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
        function [isCast,CDLeft]=UseShankShot(obj)
           [isCast,CDLeft]=obj.ApplyInstantCast(obj.abilities.sha);
        end
%%%%%%%%%%%%%%%%
%%% CALLBACKS
%%%%%%%%%%%%%%%%
        function BBCallback(obj,t,~)
            obj.ApplyDot('FR',obj.abilities.fle,1);
            obj.buffs.FR.LastUsed=t;
        end
        function SPCallback(obj,t,~)
            obj.ApplyInstantCast(obj.abilities.fly);
            obj.procs.RP.LastProc=t;
        end
%%%%%%%%%%%%%%%%
%%% SubClass Callbacks
%%%%%%%%%%%%%%%%
        function bonuspen = CalculateBonusPen(obj,it,t)
            %Right before DR is calculated, check for bonus armor pen 
            %only use for cooldowns (illegal mods or target acquired
            frb = obj.buffs.FR;
            bonuspen=0.0;
            if(frb.LastUsed>=0 && frb.LastUsed+frb.Dur>t)
                bonuspen=0.3;
            end
        end
        function AddDamageCB(obj,t,dmg,it)
            %"CallBack" (not) called right before the damage is applied
            %A good time to either proc on hit abilities (force technique)
            %or on hit procs (force synergy)
            if(obj.debuffs.BB.Charges>0 && obj.debuffs.BB.LastApplied+3.5<t && it.ctype==4)
                ac=isAutocrit(obj,obj.abilities.blo);
                [mhd,mhh,mhc]=CalculateDamage(obj,t,obj.abilities.blo,ac);
                if(mhh>0)
                    obj.debuffs.BB.Charges=0;
                    AddDamage(obj,{t,obj.abilities.blo.name,mhd,mhc,mhh},obj.abilities.blo);
                    if(ac==1)
                        obj.autocrit_charges=obj.autocrit_charges-1;
                    end

                end
            end
            if(strcmp(it.id,'sucker_punch'))
               if(obj.stats.pc2 &&(t>=(obj.procs.PC2.Available) ...
                            || obj.procs.PC2.LastProc<0))
                obj.procs.PC2.LastProc=t;
                obj.procs.PC2.Available=t+obj.procs.PC2.CD/(1+obj.stats.Alacrity)*0.99;
                end 
            end
            if(strcmp(it.id,'bludgeon'))
               if(obj.stats.pc2 &&(t>=(obj.procs.PC2.Available) ...
                            || obj.procs.PC2.LastProc<0))
                   obj.autocrit_last_proc=t; 
                   obj.autocrit_proc_duration=30;
                   obj.autocrit_charges=1;
                end 
            end
        end
        
        function [bd, bc,bs,bm]=CalculateBonus(obj,t,it,mhh,ohh)
            [bd,bc,bs,bm]=CalculateBonus@Simulator.Scoundrel(obj,t,it,mhh,ohh);
            rpp=obj.procs.RP;
            if(rpp.LastProc>=0 && rpp.LastProc+rpp.Dur>t)
               bc=bc+0.05; 
            end
        end

    end
    
end

