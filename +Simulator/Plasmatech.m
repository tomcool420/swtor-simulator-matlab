classdef Plasmatech <Simulator.Vanguard
    %PLASMATECH Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj=Plasmatech(z)
            if(nargin<1)
                z='PT';
            end
            if(isstruct(z))
                LoadAbilities_(obj,z);
            elseif(ischar(z))
                if(ismember(z,'Vanguard'))
                    LoadAbilities(obj,'json/Plasmatech.json')
                else
                    LoadAbilities(obj,'json/Plasmatech.json')
                end
            end
            obj.autocrit_abilities = {'Cell Burst','Fire Pulse'};
            obj.raid_armor_pen=0.2;
        end
        function PreloadMissiles(obj)
            obj.missiles_loaded=4;
        end
        function PreloadPulseGenerator(obj)
           obj.procs.PG.Charges=2;
           obj.procs.PG.LastProc=0;
        end
        
        
        function [isCast,CDLeft]=UseIonPulse(obj)
            [isCast,CDLeft]=obj.ApplyInstantCast(obj.abilities.ip);
        end
        function [isCast,CDLeft]=UseShockStrike(obj)
            [isCast,CDLeft]=obj.ApplyInstantCast(obj.abilities.ssk);
        end
        function [isCast,CDLeft]=UseHighImpactBolt(obj)
            [isCast,CDLeft]=obj.ApplyInstantCast(obj.abilities.hib);
        end
        function [isCast,CDLeft]=UseFirePulse(obj)
            [isCast,CDLeft]=obj.ApplyInstantCast(obj.abilities.fp);
        end
        function [isCast,CDLeft]=UsePulseCannon(obj)
            [isCast,CDLeft]=obj.ApplyChanneledAbility(obj.abilities.pc);
        end
        function [isCast,CDLeft]=UseHammerShot(obj)
            [isCast,CDLeft]=obj.ApplyInstantCast(obj.abilities.hs);
        end
        function [isCast,CDLeft]=UsePlasmatize(obj)
            [isCast,CDLeft]=obj.ApplyDot('PT',obj.abilities.pt);
        end
        function [isCast,CDLeft]=UseIncendiaryRound(obj)
            [isCast,CDLeft]=obj.ApplyInstantCast(obj.abilities.iri);
        end
        function UseShoulderCannon(obj)
            if(obj.missiles_loaded==0)
                obj.missiles_loaded=4;
                obj.activations{end+1}={obj.nextCast,'Loading Shoulder Cannon'};
                %fprintf('Reloading Shoulder Cannon %.02f\n',obj.nextCast);
            else
                obj.ApplyInstantCast(obj.abilities.sc);
                obj.missiles_loaded=obj.missiles_loaded-1;
            end
            
        end
        
        function ShockCallback(obj,t,~)
            obj.ApplyInstantCast(obj.abilities.ssi);
        end
        function IRCallback(obj,t,~)
            obj.ApplyDot('IR',obj.abilities.ird,1);
        end
        function [bd, bc,bs,bm]=CalculateBonus(obj,t,it,mhh,ohh)
            [bd, bc,bs,bm]=CalculateBonus@Simulator.Vanguard(obj,t,it,mhh,ohh);
            if(it.dmg_type < 3) %(kinetic or energy)
               bm=1.05*bm;      %Rain of Fire
            end
            if(it.dmg_type == 3) %elemental
                bc=bc+0.03;     %Cell Bonus;
            end
            if(strcmp(it.id,'hib') && obj.procs.HAC.Charges>0 && obj.procs.HAC.Dur+obj.procs.HAC.LastProc>t)
                bc=bc+1;
                obj.procs.HAC.Charges=0;
            end
            if(strcmp(it.id,'pulsecannon')  && obj.procs.PG.Dur+obj.procs.PG.LastProc>t)
                bm=bm*(1+0.25*obj.procs.PG.Charges);
            end
        end
        function AddDamageCB(obj,t,dmg,it)
            %"CallBack" (not) called right before the damage is applied
            %A good time to either proc on hit abilities (force technique) 
            %or on hit procs (force synergy)
            if(strcmp(it.id,'ionpulse')||strcmp(it.id,'firepulse'))
                e=obj.procs.PG;
                if(e.LastProc+e.Dur<t)
                    e.Charges=0;
                end
                e.LastProc=t;
                e.Charges=min(e.Charges+1,2);
                obj.procs.PG=e;
            end
            if(strcmp(it.id,'shockstrike'))
                if(obj.stats.pc2 &&(t>=(obj.procs.PC2.Available) ...
                        || obj.procs.PC2.LastProc<0))
                    obj.procs.PC2.LastProc=t;
                    obj.procs.PC2.Available=t+obj.procs.PC2.CD/(1+obj.stats.Alacrity)*0.99;
                end
                
                e=obj.procs.HAC;
                e.LastProc=t;
                e.Charges=1;
                obj.procs.HAC=e;
            end
            if(strcmp(it.id,'ionpulse'))
                if(obj.autocrit_last_proc+60<obj.nextCast || obj.autocrit_last_proc<0)
                    obj.autocrit_last_proc=obj.nextCast;
                    obj.autocrit_proc_duration=30;
                    obj.autocrit_charges=1;
                    %fprintf('autocrit procced %0.2f\n',obj.nextCast);
                end
            end
            if(strcmp(it.id,'shockstrike')|| ...
               strcmp(it.id,'ionpulse'));
                obj.ApplyDot('PCD',obj.abilities.pcd,1);
            end
            if(it.w==1&&rand()<0.35&& t>=obj.procs.PCD.Available)
                obj.procs.PCD.LastProc=t;
                obj.procs.PCD.Available=t+1;
                obj.ApplyDot('PCD',obj.abilities.pcd,1);
            end
        end
    end
    
    
    
end

