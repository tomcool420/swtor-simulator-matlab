function [r,dps,apm,times,mx,mn]=MMRotation(rotation,loops,pub,stats,HP)
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
    %delay=0.0;
    HP=1000000;
end
delay=0.0;
r=0;
mx=0;
mxdps=0;
mn=0;
mndps=10000;
mdps=0;
dps=zeros(1,loops);
apm=zeros(1,loops);
times=zeros(1,loops);
strl=0;
if(pub)
     data=json.loadjson('json/Sharpshooter.json');
     %stats=json.loadjson('gear/Tosh.json');
%    stats=loadjson('json/LunaStats.json');
else
    data=json.loadjson('json/Marksman.json');
    %stats=json.loadjson('json/Sniper_6pc_bis.json');
end
    for i = 1:loops
        %strl=printclean(strl,'Rotation %.0f/%.0f',i,loops);
        %a=DFRotationClass();

        a=Simulator.Marksman(data);
        a.detailed_stats=0;
        a.stats=stats;
        a.UseLazeTarget();
        a.continue_past_hp=1;
        a.total_HP=HP;
        a.use_mean=1;
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
                    [isCast,CDLeft]=a.UsePenetratingBlasts();
                end
                a.AddDelay(delay);
%                a.AddDelay(0.2);
            elseif(strcmp(txt,'Followthrough')||strcmp(txt,'Trickshot'))
                %fprintf('ablt %.0f\n',j)
                a.AddDelay(delay);
                [isCast,CDLeft]=a.UseFollowthrough();
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

        [times(i),dps(i),apm(i)]=a.GetStats();
        m=mean(dps(1:i));
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