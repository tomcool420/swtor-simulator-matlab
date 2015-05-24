function [ r,dps,times,apm ] = SerenityRotation( rotation ,loops)
%SERENITYROTATION Summary of this function goes here
%   Detailed explanation goes here
if(nargin<2)
    loops=1;
end

r=0;
maxDPS=0;
dps=zeros(1,loops);
apm=zeros(1,loops);
times=zeros(1,loops);
strl=0;
data=json.loadjson('json/Serenity.json');
stats=json.loadjson('json/TShadow_norelics.json');
    for i =1:loops
        strl=printclean(strl,'Rotation %.0f/%.0f',i,loops);
        %a=DFRotationClass();

        a=Serenity(data);
        a.raid_armor_pen=0.2;
        a.stats=stats;
        %a.UseLazeTarget();
        for j = 1:size(rotation)
            txt=rotation{j};
            if(strcmp(rotation{j},'Saber Strike')||strcmp(txt,'Flurry of Bolts'))
                a.UseSaberStrike();
            elseif(strcmp(rotation{j},'Serenity Strike'))
                nc=a.nextCast;
                [isCast,CDLeft]=a.UseSerenityStrike();
            elseif(strcmp(rotation{j},'Force Breach'))
                [isCast,CDLeft]=a.UseForceBreach();
            elseif(strcmp(rotation{j},'Sever Force'))
                a.UseSeverForce();
            elseif(strcmp(rotation{j},'Vanquish'))
                [isCast,CDLeft]=a.UseVanquish();
            elseif(strcmp(rotation{j},'Double Strike'))
                a.UseDoubleStrike();
            elseif(strcmp(rotation{j},'Force in Balance'))
                a.UseForceInBalance();
            elseif(strcmp(rotation{j},'Spinning Strike'))
                a.UseSpinningStrike();
            elseif(max(size(strfind(txt,'Adrenal')))>0)
                a.UseAdrenal();
            elseif(strcmp(rotation{j},'Shoulder Cannon'))
                a.UseShoulderCannon();
            else
                a.extra_abilities=a.extra_abilities+1;
                disp(['unknown ' txt]);
            end
            
        end
        %a.MatchAPM(49.09);
        [times(i),dps(i),apm(i)]=a.GetStats();
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