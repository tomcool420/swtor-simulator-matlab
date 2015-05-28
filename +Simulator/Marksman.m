classdef Marksman < Simulator.Sniper
    %MARKSMAN Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods
        function obj=Marksman(z)
            if(nargin<1)
                z='MM';
            end
            if(isstruct(z))
                LoadAbilities_(obj,z);
            elseif(ischar(z))
                if(ismember(z,'Gunslinger'))
                    LoadAbilities(obj,'json/Sharpshooter.json')
                else
                    LoadAbilities(obj,'json/Marksman.json')
                end
            end 
            obj.autocrit_abilities = {'Cull','Ambush','Engineering Probe','Aimed Shot','Wounding Shots','Sabotage Charge'};
            obj.armor_pen=0.1;
            obj.raid_armor_pen=0.2;
        end
        function AMBCallback(obj,t,~)
            if(obj.stats.pc2 &&(t>=(obj.procs.PC2.Available) ...
                            || obj.procs.PC2.LastProc<0))
                obj.procs.PC2.LastProc=t;
                obj.procs.PC2.Available=t+obj.procs.PC2.CD/(1+obj.stats.Alacrity)*0.99;
            end
            obj.buffs.ZS.Charges=0;
        end
        function SNCallback(obj,t,~)
            hs=obj.procs.HS;
            if(hs.LastProc>=0 && hs.LastProc+hs.Dur>t)
                hs.Charges=min(hs.Charges+1,3);
            else
                hs.Charges=1;
            end
            hs.LastProc=t;
            obj.procs.HS=hs;
            hs=obj.procs.ZS;
            if(hs.LastProc>=0 && hs.LastProc+hs.Dur>t)
                hs.Charges=min(hs.Charges+1,2);
            else
                hs.Charges=1;
            end
            hs.LastProc=t;
            obj.procs.ZS=hs;
        end

        function UseSniperVolley(obj,name)
            if(nargin<2)
                name='Sniper Volley';
            end
           sv=obj.buffs.SV;
           if(obj.nextCast>sv.Available)
               obj.activations{end+1}={obj.nextCast,name};
               sv.LastUsed=obj.nextCast();
               sv.Available = 45/(1+obj.stats.Alacrity);
               obj.stats.Alacrity=obj.stats.Alacrity+0.1;
               obj.avail.penblast=0;
           end
           obj.buffs.SV=sv;
           
        end
        function CheckSniperVolley(obj)
           sv=obj.buffs.SV;
           sm=sv.LastUsed+sv.Dur;
           nc=obj.nextCast;
           if(sv.LastUsed>0 && nc>sm)
               sv.LastUsed=-1;
               obj.stats.Alacrity=obj.stats.Alacrity-0.1;
           end
           obj.buffs.SV=sv;
        end
        function [isCast,CDLeft]=UseCorrosiveDart(obj)
            obj.CheckSniperVolley()
            [isCast,CDLeft]=ApplyDot(obj,'CD',obj.abilities.cd);
        end
        function [isCast,CDLeft]=UseAmbush(obj)
            obj.CheckSniperVolley()
            zs=obj.procs.ZS;
            ct_red=0;
            if(zs.Charges>0 && obj.nextCast<zs.LastProc+zs.Dur)
               ct_red=0.25*zs.Charges; 
            end
            [isCast,CDLeft]=obj.ApplyCastAbilities(obj.abilities.amb,ct_red); 
        end
        function [isCast,CDLeft]=UseFollowthrough(obj)
            obj.CheckSniperVolley()
            [isCast,CDLeft]=ApplyInstantCast(obj,obj.abilities.ft);
        end
        function [isCast,CDLeft]=UseTakedown(o)
           o.CheckSniperVolley()
           [isCast,CDLeft]=o.ApplyInstantCast(o.abilities.td); 
        end
        function [isCast,CDLeft]=UseSnipe(o)
           o.CheckSniperVolley()
           [isCast,CDLeft]=o.ApplyCastAbilities(o.abilities.sn); 
        end
        function [isCast,CDLeft]=UsePenetratingBlasts(o)
           o.CheckSniperVolley()
           [isCast,CDLeft]=o.ApplyChanneledAbility(o.abilities.pb);
        end
        function [isCast,CDLeft]=UseRifleShot(obj)
            obj.CheckSniperVolley()
            [isCast,CDLeft]=ApplyInstantCast(obj,obj.abilities.rs);
        end
        function [isCast,CDLeft]=UseXSFreighterFlyby(obj)
           obj.CheckSniperVolley()
           [isCast,CDLeft]=ApplyDot(obj,'XS',obj.abilities.xs);
        end
        
%%%%%%%%%%%%%%%%%
%%% PUB ABILITIES
%%%%%%%%%%%%%%%%%

        function [bd, bc,bs,bm]=CalculateBonus(obj,t,it,mhh,ohh)
            bd=0;bc=0;bs=0;bm=1;
            if(strcmp(it.id,'snipe'))
               bc= 0.05*obj.procs.HS.Charges;
               bm= 1+0.05*obj.procs.HS.Charges;
            end
        end

    end
    
    
end

