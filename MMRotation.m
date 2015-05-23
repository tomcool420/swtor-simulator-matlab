function [r,dps]=MMRotation(rotation,loops,pub)
if(nargin<2)
    loops=1;
end
if(nargin<3)
    pub=0;
end
r=0;
maxDPS=0;
dps=zeros(1,loops);
strl=0;
if(pub)
    data=loadjson('json/Sharpshooter.json');
     stats=loadjson('json/Gunslinger_6pc_bis.json');
%    stats=loadjson('json/LunaStats.json');
else
    data=loadjson('json/Marksman.json');
    stats=loadjson('json/Sniper_6pc_bis.json');
end
    for i = 1:loops
        strl=printclean(strl,'Rotation %.0f/%.0f',i,loops);
        %a=DFRotationClass();

        a=Marksman(data);
        a.stats=stats;
        a.UseLazeTarget();
        for j = 1:size(rotation)
            txt=rotation{j};
            if(strcmp(rotation{j},'Rifle Shot')||strcmp(txt,'Flurry of Bolts'))
                a.UseRifleShot();
            elseif(strcmp(rotation{j},'Overload Shot'))
                a.UseRifleShot();
            elseif(strcmp(txt,'Penetrating Blasts')||strcmp(txt,'Penetrating Rounds'))
                [isCast,CDLeft]=a.UsePenetratingBlasts();
                if(~isCast)
                    %fprintf('delaying PB %.1f\n',CDLeft)
                     a.activations{end+1}={a.nextCast,'Delayed PB'};
                    a.AddDelay(CDLeft);
                    [isCast,CDLeft]=a.UsePenetratingBlasts();
                end
%                a.AddDelay(0.2);
            elseif(strcmp(txt,'Followthrough')||strcmp(txt,'Trickshot'))
                %fprintf('ablt %.0f\n',j)
                [isCast,CDLeft]=a.UseFollowthrough();
            elseif(strcmp(txt,'Takedown')||strcmp(txt,'Quickdraw'))
                a.UseTakedown();
            elseif(strcmp(txt,'Ambush')||strcmp(txt,'Aimed Shot'))
                [isCast,CDLeft]=a.UseAmbush();
                a.AddDelay(0.0);
                if(~isCast)
                    a.activations{end+1}={a.nextCast,'Delayed AMB'};
                    a.AddDelay(CDLeft);
                    a.UseAmbush();
                    %fprintf('delaying Ambush %.1f\n',CDLeft)
                     
                end
%                a.AddDelay(0.2);
            elseif(strcmp(txt,'Corrosive Dart')||strcmp(txt,'Vital Shot'))
                a.UseCorrosiveDart();
            elseif(strcmp(txt,'Snipe')||strcmp(txt,'Charged Burst'))
                a.UseSnipe();
 %               a.AddDelay(0.1);
            elseif(strcmp(txt,'Sniper Volley')||strcmp(txt,'Burst Volley'))
                a.UseSniperVolley()
            elseif(strcmp(txt,'Laze Target') || strcmp(txt,'Smuggler''s Luck'))
                a.UseLazeTarget();
            elseif(strcmp(txt,'Illegal Mods') || strcmp(txt,'Target Acquired'))
                a.UseTargetAcquired();
            elseif(max(size(strfind(txt,'Adrenal')))>0)
                a.UseAdrenal();
            else
                %disp(['unknown ' txt]);
            end
            
        end
        dps(i)=a.total_damage/(a.damage{end}{1});
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