classdef DirtyFighting <Rot.BaseRotation
    %DIRTYFIGHTING Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj=DirtyFighting(opts)
            if(nargin<1)
                obj.options=Rot.RotOptions();
            else
                obj.options=opts;
            end
            obj.imp_json='json/virulence.json';
            obj.pub_json='json/DirtyFighting.json';
            obj.load_abilities();
        end
        function s=SetupSimulator(obj)
           s = Simulator.Virulence(obj.abilities); 
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
                   a.UseRifleShot();
               elseif(strcmp(rotation{j},'Overload Shot'))
                   a.UseOverloadShot();
               elseif(strcmp(rotation{j},'Covered Escape'))
                   [isCast,CDLeft]=a.UseCoveredEscape();
                   if(~isCast)
                       a.activations{end+1}={a.nextCast,'Delayed CE'};
                       a.AddDelay(CDLeft);
                       a.UseCoveredEscape();
                   end
               elseif(strcmp(txt,'Lethal Shot')||strcmp(txt,'Dirty Blast'))
                   a.UseLethalShot();
               elseif(strcmp(txt,'Cull')||strcmp(txt,'Wounding Shots'))
                   a.AddDelay(0.3)
                   [isCast,CDLeft]=a.UseCull();
                   if(~isCast)
                       a.activations{end+1}={a.nextCast,'Delayed Cull'};
                       a.AddDelay(CDLeft);
                       a.UseCull();
                   end
                   %a.AddDelay(0.2);
               elseif(strcmp(txt,'Takedown')||strcmp(txt,'Quickdraw'))
                   a.UseTakedown();
               elseif(strcmp(txt,'Corrosive Grenade')||strcmp(txt,'Shrap Bomb'))
                   a.UseCorrosiveGrenade();
               elseif(strcmp(txt,'Corrosive Dart')||strcmp(txt,'Vital Shot'))
                   a.UseCorrosiveDart();
               elseif(strcmp(txt,'Series of Shots')||strcmp(txt,'Speed Shot'))
                   [isCast,CDLeft]=a.UseSeriesOfShots();
                   if(~isCast)
                       a.activations{end+1}={a.nextCast,'Delayed SoS'};
                       a.AddDelay(CDLeft);
                       a.UseSeriesOfShots();
                   end
               elseif(strcmp(txt,'Weakening Blast')||strcmp(txt,'Hemorrhaging Blast'))
                   [isCast,CDLeft]=a.UseWeakeningBlast();
                   if(~isCast)
                       a.activations{end+1}={a.nextCast,'Delayed WB'};
                       a.AddDelay(CDLeft);
                       a.UseSeriesOfShots();
                   end
               elseif(strcmp(txt,'Laze Target') || strcmp(txt,'Smuggler''s Luck'))
                   a.UseLazeTarget();
               elseif(strcmp(txt,'Illegal Mods') || strcmp(txt,'Target Acquired'))
                   a.UseTargetAcquired();
               elseif(strcmp(txt,'XS Freighter Flyby'))
                   a.UseXSFreighterFlyby();
               elseif(strcmp(txt,'Crouch'))
                   a.UseCrouch()
               elseif(max(size(strfind(txt,'Adrenal')))>0)
                   a.UseAdrenal();
               else
                   a.extra_abilities=a.extra_abilities+1;
                   %disp(['unknown ' txt]);
               end
           end
        end
    
end
end
