classdef Serenity <Rot.BaseRotation
    %SERENITY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj=Serenity(opts)
            if(nargin<1)
                obj.options=Rot.RotOptions();
            else
                obj.options=opts;
            end
            obj.imp_json='json/Serenity.json';
            obj.pub_json='json/DirtyFighting.json';
            obj.load_abilities();
        end
        function s=SetupSimulator(obj)
            s = Simulator.Serenity(obj.abilities);
            opts=obj.opts;
            s.continue_past_hp=opts.continue_past_hp;
            s.total_HP=opts.total_HP;
            s.stats=obj.stats;
            if(opts.preload_buffs)
                s.buffs.FP.Charges=3;
            end
            if(opts.use_armor_debuff)
                s.raid_armor_pen=0.2;
            end
            s.use_mean=opts.use_mean;
            s.detailed_stats=opts.detailed_stats;
        end
        function a = RunRotation(obj,rotation)
            a=obj.SetupSimulator();
            
            for j = 1:numel(rotation)
                txt=rotation{j};
                if(strcmp(rotation{j},'Saber Strike')||strcmp(txt,'Flurry of Bolts'))
                    a.UseSaberStrike();
                elseif(strcmp(rotation{j},'Serenity Strike'))
                    [isCast,CDLeft]=a.UseSerenityStrike();
                    if(~isCast)
                       a.activations{end+1}={a.nextCast,'Delayed Serenity Strike'};
                       a.AddDelay(CDLeft);
                       a.UseCoveredEscape();
                   end
                elseif(strcmp(rotation{j},'Force Breach'))
                    a.UseForceBreach();
                elseif(strcmp(rotation{j},'Sever Force'))
                    a.UseSeverForce();
                elseif(strcmp(rotation{j},'Vanquish'))
                    a.AddDelay(0.4);
                    [isCast,CDLeft]=a.UseVanquish();
                elseif(strcmp(rotation{j},'Double Strike'))
                    a.UseDoubleStrike();
                elseif(strcmp(rotation{j},'Force in Balance'))
                    [isCast,CDLeft]=a.UseForceInBalance();
                    if(~isCast)
                        a.activations{end+1}={a.nextCast,'Delayed Force In Balance'};
                        a.AddDelay(CDLeft);
                        a.UseCoveredEscape();
                    end
                elseif(strcmp(rotation{j},'Spinning Strike'))
                    a.UseSpinningStrike();
                elseif(max(size(strfind(txt,'Adrenal')))>0)
                    a.UseAdrenal();
                elseif(strcmp(rotation{j},'Force Potency'))
                    a.UseForcePotency();
                elseif(strcmp(rotation{j},'Battle Readiness'))
                    a.UseBattleReadiness();
                else
                    a.extra_abilities=a.extra_abilities+1;
                    %disp(['unknown ' txt]);
                end
                
            end
        end
        
    end
end
