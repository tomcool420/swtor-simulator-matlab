function [ r,dps,dmg,times,apm ] = InfiltrationRotation( rotation ,loops)
%SERENITYROTATION Summary of this function goes here
%   Detailed explanation goes here
if(nargin<2)
    loops=1;
end

r=0;
maxDPS=0;
dps=zeros(1,loops);
apm=zeros(1,loops);
dmg=zeros(1,loops);
times=zeros(1,loops);
strl=0;
data=json.loadjson('json/Infiltration.json');
stats=json.loadjson('json/ShTest.json');
    for i =1:loops
        strl=printclean(strl,'Rotation %.0f/%.0f',i,loops);
        %a=DFRotationClass();

        a=Simulator.Infiltration(data);
        a.buffs.FP.Charges=3;
        a.raid_armor_pen=0.2;
        a.stats=stats;
        a.autobuff=1;
        for j = 1:numel(rotation)
            txt=rotation{j};
            if(strcmp(rotation{j},'Saber Strike'))
                a.UseSaberStrike();
            elseif(strcmp(rotation{j},'Shadow Strike'))
                nc=a.nextCast;
                [isCast,CDLeft]=a.UseShadowStrike();
            elseif(strcmp(rotation{j},'Force Breach'))
                [isCast,CDLeft]=a.UseForceBreach();
            elseif(strcmp(rotation{j},'Psychokinetic Blast'))
                a.UsePsychokineticBlast();
            elseif(strcmp(rotation{j},'Clairvoyant Strike'))
                a.UseClairvoyantStrike();
            elseif(strcmp(rotation{j},'Spinning Strike'))
                a.UseSpinningStrike();
            elseif(max(size(strfind(txt,'Adrenal')))>0)
                a.UseAdrenal();
            elseif(strcmp(rotation{j},'Force Potency'))
                a.UseForcePotency();
            elseif(strcmp(rotation{j},'Battle Readiness'))
                a.UseBattleReadiness();
            else
                a.extra_abilities=a.extra_abilities+1;
                disp(['unknown ' txt]);
            end
            
        end
        [times(i),dps(i),apm(i)]=a.GetStats();
        dmg(i)=a.total_damage;
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