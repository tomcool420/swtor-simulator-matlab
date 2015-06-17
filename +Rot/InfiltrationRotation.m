function [r,dps,dmg,apm,times,mx,mn] = InfiltrationRotation(rotation,loops,pub,stats,HP)
if(nargin<2)
    loops=1;
end
if(nargin<3)
    pub=1;
end
if(nargin<4)
    stats=Simulator.StatCalculator(json.loadjson('gear/Mu2_base_6pc.json'));
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
dmg=zeros(1,loops);
strl=0;
idx=0;
data=json.loadjson('json/Infiltration.json');
ala=stats.Alacrity;
%stats=json.loadjson('json/ShTest.json');
    for i =1:loops
        strl=printclean(strl,'Rotation %.0f/%.0f',i,loops);
        %a=DFRotationClass();

        a=Simulator.Infiltration(data);
        a.buffs.FP.Charges=3;
        a.raid_armor_pen=0.2;
        a.stats=stats;
        a.autobuff=1;
        a.total_HP=HP;
        a.continue_past_hp=1;
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
                a.AddDelay(0.1/(1+ala));
                a.UsePsychokineticBlast();
            elseif(strcmp(rotation{j},'Clairvoyant Strike'))
                a.UseClairvoyantStrike();
            elseif(strcmp(rotation{j},'Spinning Strike'))
                a.UseSpinningStrike();
            elseif(max(size(strfind(txt,'Adrenal')))>0)
                a.UseAdrenal();
            elseif(strcmp(rotation{j},'Force Potency'))
                a.AddDelay(0.7/(1+ala));
                a.UseForcePotency();
            elseif(strcmp(rotation{j},'Battle Readiness'))
                a.AddDelay(0.5/(1+ala));
                a.UseBattleReadiness();
            elseif(strcmp(rotation{j},'Stealth')||strcmp(rotation{j},'Blackout'))
                a.AddDelay(0.7/(1+ala));
                a.extra_abilities=a.extra_abilities+1;
            else
                a.extra_abilities=a.extra_abilities+1;
                %disp(['unknown ' txt]);
            end
            
        end
        [times(i),dps(i),apm(i)]=a.GetStats();
        dmg(i)=a.total_damage;
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