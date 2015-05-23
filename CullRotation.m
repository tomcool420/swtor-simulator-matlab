function [r,dps]=CullRotation(rotation,loops,pub)
if(nargin<2)
    loops=1;
end
if(nargin<3)
    pub=0;
end
r=0;
maxDPS=0;
dps=zeros(1,loops);
strl=0;
if(pub)
    data=loadjson('json/DirtyFighting.json');
     stats=loadjson('json/Gunslinger_old4pc_bis.json');
%    stats=loadjson('json/LunaStats.json');
else
    data=loadjson('json/Virulence.json');
    stats=loadjson('json/Sniper_old4pc_bis.json');
end
    for i = 1:loops
        strl=printclean(strl,'Rotation %.0f/%.0f',i,loops);
        %a=DFRotationClass();

        a=Virulence(data);
        a.stats=stats;
        a.UseLazeTarget();
        for j = 1:size(rotation)
            txt=rotation{j};
            if(strcmp(rotation{j},'Rifle Shot')||strcmp(txt,'Flurry of Bolts'))
                a.UseRifleShot();
            elseif(strcmp(rotation{j},'Overload Shot'))
                a.UseRifleShot();
            elseif(strcmp(txt,'Lethal Shot')||strcmp(txt,'Dirty Blast'))
                a.UseLethalShot();
            elseif(strcmp(txt,'Cull')||strcmp(txt,'Wounding Shots'))
                a.UseCull();
                a.AddDelay(0.2);
            elseif(strcmp(txt,'Takedown')||strcmp(txt,'Quickdraw'))
                a.UseTakedown();
            elseif(strcmp(txt,'Corrosive Grenade')||strcmp(txt,'Shrap Bomb'))
                a.UseCorrosiveGrenade();
            elseif(strcmp(txt,'Corrosive Dart')||strcmp(txt,'Vital Shot'))
                a.UseCorrosiveDart();
            elseif(strcmp(txt,'Series of Shots')||strcmp(txt,'Speed Shot'))
                a.UseSeriesOfShots();
            elseif(strcmp(txt,'Weakening Blast')||strcmp(txt,'Hemorrhaging Blast'))
                a.UseWeakeningBlast();
            elseif(strcmp(txt,'Laze Target') || strcmp(txt,'Smuggler''s Luck'))
                a.UseLazeTarget();
            elseif(strcmp(txt,'Illegal Mods') || strcmp(txt,'Target Acquired'))
                a.UseTargetAcquired();
            elseif(max(size(strfind(txt,'Adrenal')))>0)
                a.UseAdrenal();
            else
                %disp(['unknown ' txt]);
            end
            
        end
        dps(i)=a.total_damage/(a.damage{end}{1});
        if(dps(i)>maxDPS)
            r=a;
            maxDPS=dps(i);
        end
    end
end

function l = printclean(length,varargin)
    fprintf(1, repmat('\b',1,length));
    l=fprintf(varargin{:});
end