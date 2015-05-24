function [r,dps]=TacticsRotation(rotation,loops)
if(nargin<2)
    loops=1;
end

r=0;
maxDPS=0;
dps=zeros(1,loops);
strl=0;
data=json.loadjson('json/Tactics.json');
stats=json.loadjson('json/VGTest.json');

    for i = 1:loops
        strl=printclean(strl,'Rotation %.0f/%.0f',i,loops);
        %a=DFRotationClass();

        a=Tactics(data);
        a.PreloadCBCharges;
        a.PreloadMissiles;
        a.raid_armor_pen=0.2;
        a.stats=stats;
        %a.UseLazeTarget();
        for j = 1:size(rotation)
            txt=rotation{j};
            if(strcmp(rotation{j},'Hammer Shot')||strcmp(txt,'Flurry of Bolts'))
                a.UseHammerShot();
            elseif(strcmp(rotation{j},'High Impact Bolt'))
                nc=a.nextCast;
                a.AddDelay(0.05);
                [isCast,CDLeft]=a.UseHighImpactBolt();
                if(~isCast)
                    fprintf('Delayed HIB (%.0f), %.2fs\n',j,CDLeft);
                    a.activations{end+1}={a.nextCast,'Delayed HiB'};
                    a.AddDelay(CDLeft);
                    a.UseHighImpactBolt();
                end
            elseif(strcmp(rotation{j},'Assault Plastique'))
                [isCast,CDLeft]=a.UseAssaultPlastique();
                if(~isCast)
                    a.activations{end+1}={a.nextCast,'Delayed AP'};
                    a.AddDelay(CDLeft);
                    a.UseAssaultPlastique();
                end
            elseif(strcmp(rotation{j},'Tactical Surge'))
                a.UseTacticalSurge();
            elseif(strcmp(rotation{j},'Stockstrike'))
                [isCast,CDLeft]=a.UseStockStrike();
                if(~isCast)
                    a.activations{end+1}={a.nextCast,'Delayed SS'};
                    a.AddDelay(CDLeft);
                    a.UseStockStrike();
                end
            elseif(strcmp(rotation{j},'Gut'))
                a.UseGut();
            elseif(strcmp(rotation{j},'Cell Burst'))
                a.UseCellBurst();
            elseif(strcmp(rotation{j},'Battle Focus'))
                a.UseBattleFocus();
            elseif(max(size(strfind(txt,'Adrenal')))>0)
                a.UseAdrenal();
            elseif(strcmp(rotation{j},'Shoulder Cannon'))
                a.UseShoulderCannon();
            else
                %disp(['unknown ' txt]);
            end
            
        end
        [~,dps(i)]=a.GetStats();
        %dps(i)=a.total_damage/(a.damage{end}{1});
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