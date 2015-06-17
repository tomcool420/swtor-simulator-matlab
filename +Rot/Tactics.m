classdef Tactics < Rot.BaseRotation
    %TACTICS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj=Tactics(opts)
            if(nargin<1)
                obj.options=Rot.RotOptions();
            else
                obj.options=opts;
            end
            obj.imp_json='json/AP.json';
            obj.pub_json='json/Tactics.json';
            obj.load_abilities();
        end
        function s=SetupSimulator(obj)
            s = Simulator.Tactics(obj.abilities);
            opts=obj.opts;
            s.continue_past_hp=opts.continue_past_hp;
            s.total_HP=opts.total_HP;
            s.stats=obj.stats;
            if(opts.preload_buffs)
                a.PreloadCBCharges;
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
                if(strcmp(rotation{j},'Hammer Shot')||strcmp(txt,'Rapid Shots'))
                    a.UseHammerShot();
                elseif(strcmp(rotation{j},'High Impact Bolt')||strcmp(rotation{j},'Rail Shot'))
                    a.AddDelay(delay);
                    [isCast,CDLeft]=a.UseHighImpactBolt();
                    if(~isCast)
                        fprintf('Delayed HIB (%.0f), %.2fs\n',j,CDLeft);
                        a.activations{end+1}={a.nextCast,'Delayed HiB'};
                        a.AddDelay(CDLeft);
                        a.UseHighImpactBolt();
                    end
                elseif(strcmp(rotation{j},'Assault Plastique')||strcmp(rotation{j},'Thermal Detonator'))
                    [isCast,CDLeft]=a.UseAssaultPlastique();
                    if(~isCast)
                        fprintf('delayed AP\n');
                        a.activations{end+1}={a.nextCast,'Delayed AP'};
                        a.AddDelay(CDLeft);
                        a.UseAssaultPlastique();
                    end
                elseif(strcmp(rotation{j},'Tactical Surge')||strcmp(rotation{j},'Magnetic Blast'))
                    a.UseTacticalSurge();
                elseif(strcmp(rotation{j},'Stockstrike'))
                    [isCast,CDLeft]=a.UseStockStrike();
                    if(~isCast)
                        a.activations{end+1}={a.nextCast,'Delayed SS'};
                        a.AddDelay(CDLeft);
                        a.UseStockStrike();
                    end
                elseif(strcmp(rotation{j},'Gut')||strcmp(rotation{j},'Retractable Blade'))
                    a.UseGut();
                elseif(strcmp(rotation{j},'Cell Burst')||strcmp(rotation{j},'Energy Burst'))
                    a.UseCellBurst();
                elseif(strcmp(rotation{j},'Battle Focus')||strcmp(rotation{j},'Explosive Fuel'))
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

