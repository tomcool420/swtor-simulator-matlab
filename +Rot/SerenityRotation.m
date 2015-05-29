function [ r,dps,dmg,times,apm,mx,mn ] = SerenityRotation( rotation ,loops)
%SERENITYROTATION Summary of this function goes here
%   Detailed explanation goes here
if(nargin<2)
    loops=1;
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
data=json.loadjson('json/Serenity.json');
stats=json.loadjson('gear/MulletShadow.json');
%stats=json.loadjson('json/ShTest.json');
    for i =1:loops
        strl=printclean(strl,'Rotation %.0f/%.0f',i,loops);
        %a=DFRotationClass();

        a=Simulator.Serenity(data);
        a.buffs.FP.Charges=3;
        a.raid_armor_pen=0.2;
        a.stats=stats;
        a.continue_past_hp=0;
        %a.total_HP=1080000;
        for j = 1:numel(rotation)
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
                a.AddDelay(0.4);
                [isCast,CDLeft]=a.UseVanquish();
            elseif(strcmp(rotation{j},'Double Strike'))
                a.UseDoubleStrike();
            elseif(strcmp(rotation{j},'Force in Balance'))
                
                a.UseForceInBalance();
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
        %a.MatchAPM(49.09);
        [times(i),dps(i),apm(i)]=a.GetStats();
        dmg(i)=a.total_damage;
        if(i==1)
            r=a;
        end
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