classdef Plasmatech < Rot.BaseRotation
    %TACTICS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj=Plasmatech(opts)
            if(nargin<1)
                obj.options=Rot.RotOptions();
            else
                obj.options=opts;
            end
            obj.imp_json='json/Plasmatech.json';
            obj.pub_json='json/Plasmatech.json';
            obj.load_abilities();
        end
        function s=SetupSimulator(obj)
            s = Simulator.Plasmatech(obj.abilities);
            opts=obj.opts;
            s.continue_past_hp=opts.continue_past_hp;
            s.total_HP=opts.total_HP;
            s.stats=obj.stats;
            if(opts.preload_buffs)
                a.a.PreloadPulseGenerator;
                a.PreloadMissiles;
            end
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
                if(strcmp(rotation{j},'Hammer Shot')||strcmp(txt,'Flurry of Bolts'))
                    a.UseHammerShot();
                elseif(strcmp(rotation{j},'High Impact Bolt'))
                    %a.AddDelay(0.237);
                    [isCast,CDLeft]=a.UseHighImpactBolt();
                    if(~isCast)
                        a.activations{end+1}={a.nextCast,'Delayed HiB'};
                        a.AddDelay(CDLeft);
                        a.UseHighImpactBolt();
                    end
                elseif(strcmp(rotation{j},'Fire Pulse'))
                    [isCast,CDLeft]=a.UseFirePulse();
                    if(~isCast)
                        a.activations{end+1}={a.nextCast,'Delayed AP'};
                        a.AddDelay(CDLeft);
                        a.UseFirePulse();
                    end
                elseif(strcmp(rotation{j},'Ion Pulse'))
                    a.UseIonPulse();
                elseif(strcmp(rotation{j},'Shockstrike'))
                    [isCast,CDLeft]=a.UseShockStrike();
                    if(~isCast)
                        a.activations{end+1}={a.nextCast,'Delayed SS'};
                        a.AddDelay(CDLeft);
                        a.UseShockStrike();
                    end
                elseif(strcmp(rotation{j},'Plasmatize'))
                    a.UsePlasmatize();
                elseif(strcmp(rotation{j},'Incendiary Round'))
                    a.UseIncendiaryRound();
                    
                elseif(strcmp(rotation{j},'Pulse Cannon'))
                    a.AddDelay(0.5);
                    a.UsePulseCannon();
                elseif(strcmp(rotation{j},'Battle Focus'))
                    a.UseBattleFocus();
                elseif(max(size(strfind(txt,'Adrenal')))>0)
                    a.UseAdrenal();
                elseif(strcmp(rotation{j},'Shoulder Cannon'))
                    a.UseShoulderCannon();
                else
                    a.extra_abilities=a.extra_abilities+1;
                    %disp(['unknown ' txt]);
                end
                
            end
            
            
            
        end
    end
    
    
end

