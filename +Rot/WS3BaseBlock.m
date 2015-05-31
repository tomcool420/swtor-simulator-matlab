function [r,dps,dmg,apm,times,mx,mn]=WS3BaseBlock(loops,pub)
if(nargin<2)
    loops=1;
end
if(nargin<3)
    pub=1;
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
    stats=json.loadjson('gear/LunaStats.json');
    %    stats=loadjson('json/LunaStats.json');
else
    data=json.loadjson('json/Virulence.json');
    stats=json.loadjson('json/Sniper_6pc_bis.json');
end
for i = 1:loops
    strl=printclean(strl,'Rotation %.0f/%.0f',i,loops);
    %a=DFRotationClass();
    
    a=Simulator.Virulence(data);
    a.total_HP=3000000;
    a.total_damage=2150000;
    %a.autocrit_charges=1;
    a.raid_armor_pen=0.2;
    a.stats=stats;
    %a.UseLazeTarget();
    for j =1:1
        a.UseShrapBomb;
        a.UseVitalShot;
        a.UseHemorrhagingBlast;
        a.UseWoundingShots;
        a.AddDelay(0.1);
        
        a.UseDirtyBlast;
        a.UseDirtyBlast;
        a.UseHightailIt;
        a.UseQuickdraw;
        a.UseWoundingShots;
        a.AddDelay(0.1);
        
        a.UseQuickdraw;
        a.UseSpeedShot;
        a.UseHemorrhagingBlast;
        a.UseWoundingShots;
        a.AddDelay(0.1);
        
        a.UseDirtyBlast;
        a.UseShrapBomb;
        a.UseVitalShot;
        a.UseQuickdraw;
        a.UseWoundingShots;
        a.AddDelay(0.1);
        
        a.UseQuickdraw;
        a.UseSpeedShot;
        a.UseHemorrhagingBlast;
        a.UseWoundingShots;
        a.AddDelay(0.1);
        
        a.UseDirtyBlast;
        a.UseDirtyBlast;
        a.UseHightailIt;
        a.UseQuickdraw;
        a.UseWoundingShots;
        a.AddDelay(0.1);
        
        a.UseQuickdraw;
    end
    a.total_damage=a.total_damage-2150000;
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




