classdef Infiltration <Rot.BaseRotation
    %SERENITY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj=Infiltration(opts)
            if(nargin<1)
                obj.options=Rot.RotOptions();
            else
                obj.options=opts;
            end
            obj.imp_json='json/Infiltration.json';
            obj.pub_json='json/Infiltration.json';
            obj.load_abilities();
        end
        function s=SetupSimulator(obj)
            s = Simulator.Infiltration(obj.abilities);
            opts=obj.opts;
            s.continue_past_hp=opts.continue_past_hp;
            s.total_HP=opts.total_HP;
            s.stats=obj.stats;
            if(opts.preload_buffs)
                s.buffs.FP.Charges=3;
            end
            s.autobuff=1;
            %if(opts.use_armor_debuff)
            s.raid_armor_pen=0.2;
            %end
            s.use_mean=opts.use_mean;
            s.detailed_stats=opts.detailed_stats;
        end
        function a = RunRotation(obj,rotation)
            a=obj.SetupSimulator();
            for j = 1:numel(rotation)
                txt=rotation{j};
                if(strcmp(rotation{j},'Saber Strike'))
                    a.UseSaberStrike();
                elseif(strcmp(rotation{j},'Shadow Strike'))
                    nc=a.nextCast;
                    [isCast,CDLeft]=a.UseShadowStrike();
                elseif(strcmp(rotation{j},'Force Breach'))
                    [isCast,CDLeft]=a.UseForceBreach();
                elseif(strcmp(rotation{j},'Psychokinetic Blast'))
                    a.AddDelay(0.1/(1+ala));
                    a.UsePsychokineticBlast();
                elseif(strcmp(rotation{j},'Clairvoyant Strike'))
                    a.UseClairvoyantStrike();
                elseif(strcmp(rotation{j},'Spinning Strike'))
                    a.UseSpinningStrike();
                elseif(max(size(strfind(txt,'Adrenal')))>0)
                    a.UseAdrenal();
                elseif(strcmp(rotation{j},'Force Potency'))
                    a.AddDelay(0.7/(1+ala));
                    a.UseForcePotency();
                elseif(strcmp(rotation{j},'Battle Readiness'))
                    a.AddDelay(0.5/(1+ala));
                    a.UseBattleReadiness();
                elseif(strcmp(rotation{j},'Stealth')||strcmp(rotation{j},'Blackout'))
                    a.AddDelay(0.7/(1+ala));
                    a.extra_abilities=a.extra_abilities+1;
                else
                    a.extra_abilities=a.extra_abilities+1;
                    %disp(['unknown ' txt]);
                end
                
            end
            
        end
        
    end
end
