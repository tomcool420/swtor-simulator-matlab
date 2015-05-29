function [r,dps,dmg,apm,times,mx,mn]=ScrapperRotation(rotation,loops,pub,stats,delay)
if(nargin<2)
    loops=1;
end
if(nargin<3)
   pub=1; 
end
if(nargin<4)
    stats=json.loadjson('gear/Iahgazer_norelics.json');
end
if(nargin<5)
    delay=0.7;
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
if(pub)
     data=json.loadjson('json/Scrapper.json');

else
    data=json.loadjson('json/Marksman.json');
end
    for i = 1:loops
        strl=printclean(strl,'Rotation %.0f/%.0f',i,loops);
        %a=DFRotationClass();

        a=Simulator.Scrapper(data);
        a.stats=stats;
        a.continue_past_hp=1;
        for j = 1:numel(rotation)
            txt=rotation{j};
            if(strcmp(rotation{j},'Rifle Shot')||strcmp(txt,'Flurry of Bolts'))
                a.UseFlurryOfBolts();
            elseif(strcmp(rotation{j},'Quick Shot'))
                a.UseQuickShot();
            elseif(strcmp(txt,'Sucker Punch'))
                a.UseSuckerPunch();
                a.AddDelay(0.0);
            elseif(strcmp(txt,'Blood Boiler'))
                [isCast,CDLeft]=a.UseBloodBoiler();
                a.AddDelay(CDLeft);
                if(~isCast)
                    a.activations{end+1}={a.nextCast,'Delayed Blood Boilder'};
                    isCast=a.UseBloodBoiler();
                    %fprintf('delaying Blood Boilder %.1f %.0f\n',CDLeft,isCast);
                     
                end
            elseif(strcmp(txt,'Back Blast')||strcmp(txt,'Aimed Shot'))
                [isCast,CDLeft]=a.UseBackBlast();
                a.AddDelay(delay);
                a.AddDelay(CDLeft);
                if(~isCast)
                    a.activations{end+1}={a.nextCast,'Delayed Back Blast'};
                    isCast=a.UseBackBlast();
                    %fprintf('delaying Back Blast %.1f %.0 \n',CDLeft,isCast);
                     
                end
%                a.AddDelay(0.2);
            elseif(strcmp(txt,'Vital Shot')||strcmp(txt,'Vital Shot'))
                a.UseVitalShot();
            elseif(strcmp(txt,'Bludgeon'))
                idx=idx+1;
                [isCast,CDLeft]=a.UseBludgeon();
                a.AddDelay(delay);
                a.AddDelay(CDLeft);
                if(~isCast)
                    a.activations{end+1}={a.nextCast,'Delayed Bludgeon'};
                    isCast=a.UseBludgeon();
                    %fprintf('delaying Bludgeon %.1f %.0\n\n\n\n',CDLeft,isCast);
                end
 %               a.AddDelay(0.1);
            elseif(strcmp(txt,'Shank Shot'))
                [isCast,delay]=a.UseShankShot();
                a.AddDelay(delay);
                a.AddDelay(CDLeft);
                if(~isCast)
                    a.activations{end+1}={a.nextCast,'Delayed Shank Shot'};
                    isCast=a.UseShankShot();
                   % fprintf('delaying Shank Shot %.1f %.0f\n',CDLeft,isCast);
                end
            elseif(strcmp(txt,'Stealth'))
                a.stealth=1;
            elseif(strcmp(txt,'Pugnacity'))
                a.UsePugnacity();
            elseif(strcmp(txt,'Thermal Grenade')||strcmp(txt,'Burst Volley'))
                a.UseThermalGrenade();
            elseif(max(size(strfind(txt,'Adrenal')))>0)
                a.UseAdrenal();
            else
                %disp(['unknown ' txt]);
            end
            
        end
        %fprintf('%.0f Bludgeons used\n',idx);
        [times(i),dps(i),apm(i)]=a.GetStats();
        m=mean(dps(1:i));
        dmg(i)=a.total_damage;
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