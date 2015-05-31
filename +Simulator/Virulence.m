classdef Virulence < Simulator.Sniper
    %VIRULENCE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties

    end
    
    methods
        function obj=Virulence(z)
            if(nargin<1)
                z='Sniper';
            end
            if(isstruct(z))
                LoadAbilities_(obj,z);
            elseif(ischar(z))
                if(ismember(z,'Gunslinger'))
                    LoadAbilities(obj,'json/DirtyFighting.json')
                else
                    LoadAbilities(obj,'json/Virulence.json')
                end
            end
            obj.autocrit_abilities = {'Cull','Ambush','Engineering Probe','Aimed Shot','Wounding Shots','Sabotage Charge'};
        end
        function WBCallback(obj,t,~)
            obj.buffs.WB.LastUsed=t;
        end
  
        function LSCallback(obj,t,~)
            if(obj.stats.pc2 &&(t>=(obj.procs.PC2.Available) ...
                            || obj.procs.PC2.LastProc<0))
                obj.procs.PC2.LastProc=t;
                obj.procs.PC2.Available=t+obj.procs.PC2.CD/(1+obj.stats.Alacrity)*0.99;
            end
            ApplyInstantCast(obj,obj.abilities.ls_i);
        end
        function CullCallback(obj,t,it)
            if(t<obj.dots.CD.WExpire)
                [mhd,mhh,mhc]=CalculateDamage(obj,t,obj.abilities.cd);
                 AddDamage(obj, {t,obj.abilities.cd.name,mhd,mhc,mhh},obj.abilities.cd);
            end
            if(t<obj.dots.CG.WExpire)
                [mhd,mhh,mhc]=CalculateDamage(obj,t,obj.abilities.cg);
                 AddDamage(obj, {t,obj.abilities.cg.name,mhd,mhc,mhh},obj.abilities.cg);
            end 
        end
        function DOTCheckCB(obj,t,it,dot)
            %Callback right AFTER a dot has ticked and the damage is
            %applied
            if(strcmp(dot,'CD') && rand()<0.15)
                        [mhd,mhh,mhc]=CalculateDamage(obj,t,it);
                        AddDamage(obj,{t,it.name,mhd,mhc,mhh},it);
            end
        end
        function AddDamageCB(obj,t,dmg,it)
            %"CallBack" (not) called right before the damage is applied
            %A good time to either proc on hit abilities (force technique) 
            %or on hit procs (force synergy)
            nm=it.id;
            if(it.dmg_type==4 || (strcmp(it.id,'cull')&&dmg{3}>600) )
                if(obj.buffs.WB.LastUsed+obj.buffs.WB.Dur>dmg{1}...
                        && obj.buffs.WB.LastUsed>0)
                    [mhd,mhh,mhc,ohd,ohh,ohc]=CalculateDamage(obj,dmg{1},obj.abilities.wb);
                    AddDamage(obj,{dmg{1},obj.abilities.wb.name,mhd,mhc,mhh},obj.abilities.wb);
                    if(ohd>=0)
                        AddDamage(obj,{dmg{1},[obj.abilities.wb.name ' OH'],ohd,ohc,ohh},obj.abilities.wb);
                    end
                end
            end
        end

%%%%%%%%%%%%%%%%
%%% ABILITIES
%%%%%%%%%%%%%%%%
        function [isCast,CDLeft]=UseCorrosiveGrenade(obj)
            [isCast,CDLeft]=ApplyDot(obj,'CG',obj.abilities.cg);
        end
        function [isCast,CDLeft]=UseCorrosiveDart(obj)
            [isCast,CDLeft]=ApplyDot(obj,'CD',obj.abilities.cd);
        end
        function [isCast,CDLeft]=UseWeakeningBlast(obj)
           [isCast,CDLeft]=ApplyInstantCast(obj,obj.abilities.wb);
        end
        function [isCast,CDLeft]=UseTakedown(obj)
            [isCast,CDLeft]=ApplyInstantCast(obj,obj.abilities.td);
        end
        function [isCast,CDLeft]=UseLethalShot(obj)
            if(obj.last_instant_ls_proc<obj.nextCast+6 && obj.last_instant_ls_proc>=0)
                [isCast,CDLeft]=ApplyInstantCast(obj,obj.abilities.ls_w);
                obj.last_instant_ls_used=obj.nextCast;
                obj.last_instant_ls_proc=-1;
            else
                [isCast,CDLeft]=ApplyCastAbilities(obj,obj.abilities.ls_w);
            end
        end
        function [isCast,CDLeft]=UseOverloadShot(obj)
            [isCast,CDLeft]=ApplyInstantCast(obj,obj.abilities.os);
        end
        function [isCast,CDLeft]=UseCull(obj)
            [isCast,CDLeft]=ApplyChanneledAbility(obj,obj.abilities.cull);
        end
        function [isCast,CDLeft]=UseSeriesOfShots(obj)
           [isCast,CDLeft]= ApplyChanneledAbility(obj,obj.abilities.sos);
        end
        function [isCast,CDLeft]=UseCoveredEscape(obj)
            [isCast,CDLeft]= ApplyDot(obj,'CM',obj.abilities.cm);
        end
        function [isCast,CDLeft]=UseRifleShot(obj)
            [isCast,CDLeft]=ApplyInstantCast(obj,obj.abilities.rs);
        end
        function UseCrouch(obj)
            if(obj.last_instant_ls_used<0|| ...
                obj.nextCast>obj.last_instant_ls_used+6)
                obj.last_instant_ls_proc=obj.nextCast;
            end
        end
            
%%%%%%%%%%%%%%%%%
%%% PUB ABILITIES
%%%%%%%%%%%%%%%%%

        function [isCast,CDLeft]=UseShrapBomb(obj)
            [isCast,CDLeft]=obj.UseCorrosiveGrenade();
        end
        function [isCast,CDLeft]=UseVitalShot(obj)
            [isCast,CDLeft]=obj.UseCorrosiveDart();
        end
        function [isCast,CDLeft]=UseHemorrhagingBlast(obj)
           [isCast,CDLeft]=obj.UseWeakeningBlast();
        end
        function [isCast,CDLeft]=UseQuickdraw(obj)
            [isCast,CDLeft]=obj.UseTakedown();
        end
        function [isCast,CDLeft]=UseDirtyBlast(obj)
            [isCast,CDLeft]=obj.UseLethalShot();
        end
        function [isCast,CDLeft]=UseWoundingShots(obj)
            [isCast,CDLeft]=obj.UseCull();
        end
        function [isCast,CDLeft]=UseSpeedShot(obj)
            [isCast,CDLeft]=obj.UseSeriesOfShots();
        end
        function [isCast,CDLeft]=UseXSFreighterFlyby(obj)
           [isCast,CDLeft]=ApplyDot(obj,'XS',obj.abilities.xs);
        end
        function [isCast,CDLeft]=UseHightailIt(obj)
            [isCast,CDLeft]= ApplyDot(obj,'CM',obj.abilities.cm);
        end
        

    end
    
end

