function [r,dps,apm,times,mx,mn]=SabRotation(rotation,loops,pub,stats,delay)
if(nargin<2)
    loops=1;
end
if(nargin<3)
   pub=1; 
end
if(nargin<4)
    stats=json.loadjson('gear/LunaStats.json');
end
if(nargin<5)
    delay=0.3;
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
strl=0;
if(pub)
     data=json.loadjson('json/Saboteur.json');
     %stats=json.loadjson('gear/Tosh.json');
%    stats=loadjson('json/LunaStats.json');
else
    data=json.loadjson('json/Marksman.json');
    %stats=json.loadjson('json/Sniper_6pc_bis.json');
end
    for i = 1:loops
        strl=printclean(strl,'Rotation %.0f/%.0f',i,loops);
        %a=DFRotationClass();

        a=Simulator.Saboteur(data);
        a.stats=stats;
        a.UseLazeTarget();
        a.buffs.LT.Available=0;
        a.continue_past_hp=1;
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
                     a.activations{end+1}={a.nextCast,'Delayed PB'};
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
                a.UseSabotage();
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