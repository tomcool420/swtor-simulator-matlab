classdef Ruffian < Simulator.Scoundrel
    %RUFFIAN Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
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
            obj.weapon_mult=1.2;
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
        
        function [isCast,CDLeft]=UseShrapBomb(obj)
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
        function [isCast,CDLeft]=UseSanguinaryShot(obj)
            [isCast,CDLeft]=obj.ApplyInstantCast(obj.abilities.san);
        end
        function [isCast,CDLeft]=UseBrutalShots(obj)
            [isCast,CDLeft]=obj.ApplyInstantCast(obj.abilities.bru);
        end
        function DOTCheckCB(obj,t,it,dot)
            %Callback right AFTER a dot has ticked and the damage is
            %applied
           DOTCheckCB@ Simulator.Scoundrel(obj,t,it,dot);       %Call the superclass to check pugnacity
            if(strcmp(dot,'CD') && rand()<0.15)
                        [mhd,mhh,mhc]=CalculateDamage(obj,t,it);
                        AddDamage(obj,{t,it.name,mhd,mhc,mhh},it);
            end
        end
        function SSCallback(obj,t,~)
            obj.buffs.WB.LastUsed=t;
        end
        function PBSCallback(obj,t,it)
            obj.procs.CS.LastProc=t;
           if(strcmp(it.id,'point_blank_shot'))
               it2=obj.abilities.poii;
               [mhd,mhh,mhc]=CalculateDamage(obj,t,it2);
               AddDamage(obj,{t,it2.name,mhd,mhc,mhh},it2);
           else
               it2=obj.abilities.poisi;
               [mhd,mhh,mhc]=CalculateDamage(obj,t,it2);
               AddDamage(obj,{t,it2.name,mhd,mhc,mhh},it2);
           end
        end
        function AddDamageCB(obj,t,dmg,it)
            %"CallBack" (not) called right before the damage is applied
            %A good time to either proc on hit abilities (force technique) 
            %or on hit procs (force synergy)
            nm=it.id;
            if(strcmp(it.id,'brutal_shots'))
                if(obj.stats.pc2 &&(t>=(obj.procs.PC2.Available) ...
                        || obj.procs.PC2.LastProc<0))
                    obj.procs.PC2.LastProc=t;
                    obj.procs.PC2.Available=t+obj.procs.PC2.CD/(1+obj.stats.Alacrity)*0.99;
                end
                ac=obj.isAutocrit(obj.abilities.bru);
                if(t<obj.dots.CD.Expire)
                    [mhd,mhh,mhc]=CalculateDamage(obj,t,obj.abilities.brui,ac);
                    AddDamage(obj, {t,obj.abilities.brui.name,mhd,mhc,mhh},obj.abilities.brui);
                end
                if(t<obj.dots.CG.Expire)
                    [mhd,mhh,mhc]=CalculateDamage(obj,t,obj.abilities.brui,ac);
                    AddDamage(obj, {t,obj.abilities.brui.name,mhd,mhc,mhh},obj.abilities.brui);
                end
                %Do not remove auto crit stack, the main brutal shots gets
                %rid of it
            end
            if(strcmp(it.id,'blaster_whip'))
                if(obj.autocrit_last_proc+60<obj.nextCast || obj.autocrit_last_proc<0)
                    obj.autocrit_last_proc=obj.nextCast;
                    obj.autocrit_proc_duration=30;
                    obj.autocrit_charges=1;
                    %fprintf('autocrit procced %0.2f\n',obj.nextCast);
                end
            end
            if(strcmp(it.id,'brutal_shots')||strcmp(it.id,'brutal_shots_internal') || strcmp(it.id,'vital_shot') || strcmp(it.id,'shrap_bomb') )
                if(obj.buffs.WB.LastUsed+obj.buffs.WB.Dur>dmg{1}...
                        && obj.buffs.WB.LastUsed>0)
                    [mhd,mhh,mhc]=CalculateDamage(obj,dmg{1},obj.abilities.san);
                    AddDamage(obj,{dmg{1},obj.abilities.san.name,mhd,mhc,mhh},obj.abilities.san);
                end
            end
        end
        function [bd, bc,bs,bm]=CalculateBonus(obj,t,it,mhh,ohh)
            [bd, bc,bs,bm]=CalculateBonus@Simulator.Scoundrel(obj,t,it,mhh,ohh);
            cs=obj.procs.CS;
            if( cs.LastProc>0 && cs.LastProc+cs.Dur>t && (strcmp(it.id,'vital_shot') || strcmp(it.id,'shrap_bomb')))
                bm=bm+.2;
            end
        end
    end
    
end

