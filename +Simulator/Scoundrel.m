classdef Scoundrel <Simulator.BaseSimulator
    %SCOUNDREL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        upper_hand = 0;
        max_upper_hand=0;
        stealth = 0;
    end
    
    methods
        function UsePugnacity(obj,name)
            if(nargin<2)
                name='Pugnacity';
            end
           sv=obj.buffs.PG;
           if(obj.nextCast>sv.Available)
               obj.upper_hand=min(obj.upper_hand+1,obj.max_upper_hand);
               obj.activations{end+1}={obj.nextCast,name};
               sv.LastUsed=obj.nextCast();
               sv.Available = 120/(1+obj.stats.Alacrity);
               obj.stats.Alacrity=obj.stats.Alacrity+0.1;
               obj.avail.penblast=0;
           end
           obj.buffs.PG=sv;
        end
        function DOTCheckCB(obj,t,~,~)
            CheckPugnacity(obj,t);
        end
        function CheckPugnacity(obj,t)
            
           sv=obj.buffs.PG;
           sm=sv.LastUsed+sv.Dur;
           nc=t;%obj.nextCast;
           if(sv.LastUsed>0 && nc>sm)
               sv.LastUsed=-1;
               obj.stats.Alacrity=obj.stats.Alacrity-0.1;
           end
           obj.buffs.PG=sv;
        end
        
        function UseRaidBuff(obj)
        end
    end
    
end

