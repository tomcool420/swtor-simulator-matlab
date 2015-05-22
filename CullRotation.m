function [r,dps]=CullRotation(rotation,loops)
if(nargin<1)
    loops=1;
end
r=0;
maxDPS=0;
dps=zeros(1,loops);
    for i = 1:loops
        a=DFRotationClass();
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
                a.AddDelay(0.05);
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