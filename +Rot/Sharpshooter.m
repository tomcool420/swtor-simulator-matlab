classdef Sharpshooter < Rot.BaseRotation
    %SHARPSHOOTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj=Sharpshooter(opts)
            if(nargin<1)
                obj.options=Rot.RotOptions();
            else
                obj.options=opts;
            end
            obj.imp_json='json/Marksman.json';
            obj.pub_json='json/Sharpshooter.json';
            obj.load_abilities();
        end
        function s=SetupSimulator(obj)
            s = Simulator.Marksman(obj.abilities);
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
            s.detailed_stats=opts.detailed_stats;
        end
        function a = RunRotation(obj,rotation)
            a=obj.SetupSimulator();
            for j = 1:numel(rotation)
                txt=rotation{j};
                if(strcmp(rotation{j},'Rifle Shot')||strcmp(txt,'Flurry of Bolts'))
                    a.UseRifleShot();
                elseif(strcmp(rotation{j},'Overload Shot'))
                    a.UseRifleShot();
                elseif(strcmp(txt,'Penetrating Blasts')||strcmp(txt,'Penetrating Rounds'))
                    [isCast,CDLeft]=a.UsePenetratingBlasts();
                    if(~isCast)
                        %fprintf('delaying PB %.1f\n',CDLeft)
                        a.activations{end+1}={a.nextCast,'Delayed PB'};
                        a.AddDelay(CDLeft);
                        a.UsePenetratingBlasts();
                    end
                    a.AddDelay(delay);
                    %                a.AddDelay(0.2);
                elseif(strcmp(txt,'Followthrough')||strcmp(txt,'Trickshot'))
                    %fprintf('ablt %.0f\n',j)
                    a.AddDelay(delay);
                    a.UseFollowthrough();
                elseif(strcmp(txt,'Takedown')||strcmp(txt,'Quickdraw'))
                    a.UseTakedown();
                elseif(strcmp(txt,'Ambush')||strcmp(txt,'Aimed Shot'))
                    [isCast,CDLeft]=a.UseAmbush();
                    a.AddDelay(0.0);
                    if(~isCast)
                        a.activations{end+1}={a.nextCast,'Delayed AMB'};
                        a.AddDelay(CDLeft);
                        a.UseAmbush();
                        %fprintf('delaying Ambush %.1f\n',CDLeft)
                        
                    end
                    %                a.AddDelay(0.2);
                elseif(strcmp(txt,'Corrosive Dart')||strcmp(txt,'Vital Shot'))
                    a.UseCorrosiveDart();
                elseif(strcmp(txt,'Snipe')||strcmp(txt,'Charged Burst'))
                    a.UseSnipe();
                    %               a.AddDelay(0.1);
                elseif(strcmp(txt,'Sniper Volley')||strcmp(txt,'Burst Volley'))
                    a.UseSniperVolley()
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

