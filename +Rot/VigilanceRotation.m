function [r,dps,apm,times,mx,mn]=VigilanceRotation(rotation,loops,pub,stats,HP)
if(nargin<2)
    loops=1;
end
if(nargin<3)
   pub=1; 
end
if(nargin<4)
    stats=Simulator.StatCalculator(json.loadjson('gear/Mahina_base_6pc.json'));
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
strl=0;
if(pub)
    data=json.loadjson('json/Vigilance.json');
else
    data=json.loadjson('json/Vigilance.json');
end

    for i = 1:loops
        strl=printclean(strl,'Rotation %.0f/%.0f',i,loops);
        %a=DFRotationClass();

        a=Simulator.Vigilance(data);
        a.raid_armor_pen=0.2;
        a.stats=stats;
        a.total_HP=HP;
        %a.UseLazeTarget();
        for j = 1:numel(rotation)
            txt=rotation{j};
            if(strcmp(rotation{j},'Strike')||strcmp(txt,'Strike'))
                a.UseStrike();
            elseif(strcmp(rotation{j},'Sundering Strike'))
               %a.AddDelay(delay);
                [isCast,CDLeft]=a.UseSunder();
                if(~isCast)
                    fprintf('Delayed Sunder (%.0f), %.2fs\n',j,CDLeft);
                    a.activations{end+1}={a.nextCast,'Delayed Sunder'};
                    a.AddDelay(CDLeft);
                    a.UseSunder();
                end
            elseif(strcmp(rotation{j},'Overhead Slash'))
                [isCast,CDLeft]=a.UseOverheadSlash();
                if(~isCast)
                    fprintf('delayed OHS (%.0f), %.2fs\n',j,CDLeft);
                    a.activations{end+1}={a.nextCast,'Delayed OHS'};
                    a.AddDelay(CDLeft);
                    a.UseOverheadSlash();
                end
            elseif(strcmp(rotation{j},'Plasma Brand'))
                %a.AddDelay(0.13);
                [isCast,CDLeft]=a.UsePlasmaBrand();
                if(~isCast)
                    a.activations{end+1}={a.nextCast,'Delayed PB'};
                    a.AddDelay(CDLeft);
                    a.UsePlasmaBrand();
                end
            elseif(strcmp(rotation{j},'Blade Storm'))
                [isCast,CDLeft]=a.UseBladeStorm();
                if(~isCast)
                    a.activations{end+1}={a.nextCast,'Delayed BS'};
                    a.AddDelay(CDLeft);
                    a.UseBladeStorm();
                end
            elseif(strcmp(rotation{j},'Master Strike'))
                [isCast,CDLeft]=a.UseMasterStrike();
                if(~isCast)
                    fprintf('delayed MS\n');
                    a.activations{end+1}={a.nextCast,'Delayed MS'};
                    a.AddDelay(CDLeft);
                    a.UseMasterStrike();
                end
            elseif(strcmp(rotation{j},'Vigilant Thrust'))
                [isCast,CDLeft]=a.UseVigilantThrust();
                if(~isCast)
                    fprintf('delayed VT\n');
                    a.activations{end+1}={a.nextCast,'Delayed VT'};
                    a.AddDelay(CDLeft);
                    a.UseVigilantThrust();
                end
            elseif(strcmp(rotation{j},'Saber Throw'))
                [isCast,CDLeft]=a.UseSaberThrow();
                if(~isCast)
                    fprintf('delayed ST\n');
                    a.activations{end+1}={a.nextCast,'Delayed ST'};
                    a.AddDelay(CDLeft);
                    a.UseSaberThrow();
                end
            elseif(strcmp(rotation{j},'Force Leap'))
                [isCast,CDLeft]=a.UseForceLeap();
                if(~isCast)
                    fprintf('delayed FL\n');
                    a.activations{end+1}={a.nextCast,'Delayed FL'};
                    a.AddDelay(CDLeft);
                    a.UseForceLeap();
                end
            elseif(strcmp(rotation{j},'Dispatch'))
                [isCast,CDLeft]=a.UseDispatch();
                if(~isCast)
                    fprintf('delayed Dispatch\n');
                    a.activations{end+1}={a.nextCast,'Delayed Dispatch'};
                    a.AddDelay(CDLeft);
                    a.UseDispatch();
                end
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