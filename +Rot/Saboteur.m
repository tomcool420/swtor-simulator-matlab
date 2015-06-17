classdef Saboteur <Rot.BaseRotation
    %SABOTEUR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj=Saboteur(opts)
            if(nargin<1)
                obj.options=Rot.RotOptions();
            else
                obj.options=opts;
            end
            obj.imp_json='json/Saboteur.json';
            obj.pub_json='json/Saboteur.json';
            obj.load_abilities();
        end
        function s=SetupSimulator(obj)
           s = Simulator.Saboteur(obj.abilities); 
           opts=obj.opts;
           s.continue_past_hp=opts.continue_past_hp;
           s.total_HP=opts.total_HP;
           s.stats=obj.stats;
           if(opts.preload_buffs)
               s.autocrit_charges=1+s.stats.pc6;
           end
           if(opts.use_armor_debuff)
               s.raid_armor_pen=0.2;
           end
           s.use_mean=opts.use_mean;
        end
        function a = RunRotation(obj,rotation)
            a=obj.SetupSimulator();
            a.detailed_stats=0;
            for j = 1:numel(rotation)
                txt=rotation{j};
                if(strcmp(rotation{j},'Rifle Shot')||strcmp(txt,'Flurry of Bolts'))
                    a.UseFlurryOfBolts();
                elseif(strcmp(rotation{j},'Quick Shot'))
                    a.UseQuickShot();
                elseif(strcmp(txt,'Sabotage Charge')||strcmp(txt,'Penetrating Rounds'))
                    [isCast,CDLeft]=a.UseSabotageCharge();
                    if(~isCast)
                        fprintf('delaying Sabotage Charge %.1f\n',CDLeft)
                        a.activations{end+1}={a.nextCast,'Delayed Sab Charge'};
                        a.AddDelay(CDLeft);
                        a.UseSabotageCharge();
                    end
                    a.AddDelay(0.0);
                    %                a.AddDelay(0.2);;
                elseif(strcmp(txt,'Takedown')||strcmp(txt,'Quickdraw'))
                    a.UseQuickdraw();
                elseif(strcmp(txt,'Speed Shot')||strcmp(txt,'Aimed Shot'))
                    [isCast,CDLeft]=a.UseSpeedShot();
                    a.AddDelay(delay);
                    if(~isCast)
                        a.activations{end+1}={a.nextCast,'Delayed Speed Shot'};
                        a.AddDelay(CDLeft);
                        a.UseSpeedShot();
                        %fprintf('delaying Ambush %.1f\n',CDLeft);
                        
                    end
                    %                a.AddDelay(0.2);
                elseif(strcmp(txt,'Vital Shot')||strcmp(txt,'Vital Shot'))
                    a.UseVitalShot();
                elseif(strcmp(txt,'Shock Charge')||strcmp(txt,'Charged Burst'))
                    a.UseShockCharge();
                    %               a.AddDelay(0.1);
                elseif(strcmp(txt,'Incendiary Grenade')||strcmp(txt,'Burst Volley'))
                    a.UseIncendiaryGrenade();
                elseif(strcmp(txt,'Thermal Grenade')||strcmp(txt,'Burst Volley'))
                    a.UseThermalGrenade();
                elseif(strcmp(txt,'Sabotage')||strcmp(txt,'Burst Volley'))
                    [isCast,CDLeft]=a.UseSabotage();
                    a.AddDelay(delay);
                    if(~isCast)
                        a.activations{end+1}={a.nextCast,'Delayed Sabotage'};
                        a.AddDelay(CDLeft);
                        a.UseSabotage();
                    end
                elseif(strcmp(txt,'Laze Target') || strcmp(txt,'Smuggler''s Luck'))
                    a.UseLazeTarget();
                elseif(strcmp(txt,'Illegal Mods') || strcmp(txt,'Target Acquired'))
                    a.UseTargetAcquired();
                elseif(strcmp(txt,'XS Freighter Flyby') || strcmp(txt,'Target Acquired'))
                    a.UseXSFreighterFlyby();
                elseif(max(size(strfind(txt,'Adrenal')))>0)
                    a.UseAdrenal();
                else
                    %disp(['unknown ' txt]);
                end
            end
        end
        
    end
end
