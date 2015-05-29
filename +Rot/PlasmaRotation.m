function [r,dps,dmg,apm,times]=PlasmaRotation(rotation,loops)
if(nargin<2)
    loops=1;
end

r=0;
mdps=0;
dps=zeros(1,loops);
apm=zeros(1,loops);
times=zeros(1,loops);
dmg=zeros(1,loops);
strl=0;
data=json.loadjson('json/Plasmatech.json');
stats=json.loadjson('gear/Kwerty_NoRelics.json');
%stats=json.loadjson('json/VGTest.json');
    for i = 1:loops
        %strl=printclean(strl,'Rotation %.0f/%.0f',i,loops);
        %a=DFRotationClass();

        a=Simulator.Plasmatech(data);
        a.PreloadPulseGenerator;
        a.PreloadMissiles;
        a.raid_armor_pen=0.2;
        a.stats=stats;
        a.total_HP=1000000;
        a.continue_past_hp=1;
        %a.UseLazeTarget();
        for j = 1:numel(rotation)
            txt=rotation{j};
            if(strcmp(rotation{j},'Hammer Shot')||strcmp(txt,'Flurry of Bolts'))
                a.UseHammerShot();
            elseif(strcmp(rotation{j},'High Impact Bolt'))
                nc=a.nextCast;
               %a.AddDelay(0.237);
                [isCast,CDLeft]=a.UseHighImpactBolt();
                if(~isCast)
                    fprintf('Delayed HIB (%.0f), %.2fs\n',j,CDLeft);
                    a.activations{end+1}={a.nextCast,'Delayed HiB'};
                    a.AddDelay(CDLeft);
                    a.UseHighImpactBolt();
                end
            elseif(strcmp(rotation{j},'Fire Pulse'))
                [isCast,CDLeft]=a.UseFirePulse();
                if(~isCast)
                    fprintf('delayed AP\n');
                    a.activations{end+1}={a.nextCast,'Delayed AP'};
                    a.AddDelay(CDLeft);
                    a.UseFirePulse();
                end
            elseif(strcmp(rotation{j},'Ion Pulse'))
                a.UseIonPulse();
            elseif(strcmp(rotation{j},'Shockstrike'))
                [isCast,CDLeft]=a.UseShockStrike();
                if(~isCast)
                    a.activations{end+1}={a.nextCast,'Delayed SS'};
                    a.AddDelay(CDLeft);
                    a.UseShockStrike();
                end
            elseif(strcmp(rotation{j},'Plasmatize'))
                a.UsePlasmatize();
            elseif(strcmp(rotation{j},'Incendiary Round'))
                a.UseIncendiaryRound();
                
            elseif(strcmp(rotation{j},'Pulse Cannon'))
                a.AddDelay(0.5);
                a.UsePulseCannon();
            elseif(strcmp(rotation{j},'Battle Focus'))
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
        dmg(i)=a.total_damage;
        if(abs(dps(i)-m)<abs(mdps-m))
            r=a;
            mdps=dps(i);
        end
        if(loops == 1)
            r=a;
        end;
    end
end

function l = printclean(length,varargin)
    fprintf(1, repmat('\b',1,length));
    l=fprintf(varargin{:});
end