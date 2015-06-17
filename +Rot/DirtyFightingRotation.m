function [r,dps,dmg,apm,times,mx,mn]=DirtyFightingRotation(rotation,loops,pub,stats,HP)
if(nargin<2)
    loops=1;
end
if(nargin<3)
    pub=1;
end
if(nargin<4)
    stats=json.loadjson('gear/Luna6pc.json');
end
if(nargin<5)
    HP=1e6;
end
r=0;
mx=0;
mxdps=0;
mn=0;
mndps=10000;
mdps=0;
dps=zeros(1,loops);
apm=zeros(1,loops);
times=zeros(1,loops);
dmg=zeros(1,loops);
strl=0;
idx=0;
if(pub)
    data=json.loadjson('json/DirtyFighting.json');
     %stats=json.loadjson('gear/LunaStats.json');
%    stats=loadjson('json/LunaStats.json');
else
    data=json.loadjson('json/Virulence.json');
    %stats=json.loadjson('json/Sniper_6pc_bis.json');
end
    for i = 1:loops
        strl=printclean(strl,'Rotation %.0f/%.0f',i,loops);
        %a=DFRotationClass();

        a=Simulator.Virulence(data);
        a.autocrit_charges=1;
        a.raid_armor_pen=0.2;
        a.stats=stats;
        %a.UseLazeTarget();
        a.continue_past_hp=1;
        a.total_HP=HP;
        a.use_mean=1;
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
        [times(i),dps(i),apm(i)]=a.GetStats();
        m=mean(dps(1:i));
        dmg(i)=a.total_damage;
        if(abs(dps(i)-m)<abs(mdps-m))
            r=a;
            mdps=dps(i);
        end
        if(dps(i)>mxdps)
           mx=a;
           mxdps=dps(i);
        end
        if(dps(i)<mndps)
           mn=a;
           mndps=dps(i);
        end
    end
end

function l = printclean(length,varargin)
    fprintf(1, repmat('\b',1,length));
    l=fprintf(varargin{:});
end