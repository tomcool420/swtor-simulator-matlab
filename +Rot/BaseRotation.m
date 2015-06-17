classdef BaseRotation <handle
    %BASEROTATION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        simulator=0;
        stats = struct();
        abilities = struct();
        options = 0;
        pub_json = '';
        imp_json = '';
        pub_abilities=struct();
        imp_abilities=struct();
    end
    
    methods
        function obj=BaseRotation()
           
        end
        function r=RunRotation(obj,rotation)
            
        end
        function load_abilities(obj)
           obj.imp_abilities=json.loadjson(obj.imp_json);
           obj.pub_abilities=json.loadjson(obj.pub_json);
           obj.abilities=obj.pub_abilities;
        end
        function [r,dps,dmg,apm,times,mx,mn] = RunLoops(obj,loops,rotation)
            
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
            for i = 1:loops
                a=obj.RunRotation(rotation);
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
        function SetStats(obj,stats_)
           if(~isfield(stats_,'WeaponBonus'))
              stats_=Simulator.StatCalculator(stats_);
           end
           obj.stats=stats_; 
        end
        function ResetSimulator()
            
        end
        function SetAbilities(obj,abilities_)
           obj.abilities= abilities_;
        end
    end
    
end

