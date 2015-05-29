function [r,dps,apm,times,mx,mn]=TacticsRotation(rotation,loops,pub,stats,delay)
if(nargin<2)
    loops=1;
end
if(nargin<3)
   pub=1; 
end
if(nargin<4)
    stats=json.loadjson('json/Kwerty.json');
end
if(nargin<5)
    delay=0.02;
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
    data=json.loadjson('json/Tactics.json');
else
    data=json.loadjson('json/AP.json');
end

    for i = 1:loops
        strl=printclean(strl,'Rotation %.0f/%.0f',i,loops);
        %a=DFRotationClass();

        a=Simulator.Tactics(data);
        a.PreloadCBCharges;
        a.PreloadMissiles;
        a.raid_armor_pen=0.2;
        a.stats=stats;
        a.total_HP=1500000;
        %a.UseLazeTarget();
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
        %a.MatchAPM(49.09);
        [times(i),dps(i),apm(i)]=a.GetStats();
        %dps(i)=a.total_damage/(a.damage{end}{1});
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