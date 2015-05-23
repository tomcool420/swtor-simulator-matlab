classdef Marksman < BaseSimulator
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
            if(obj.stats.pc2 &&(t>=(obj.procs.FT.LastProc+obj.procs.FT.CD) ...
                            || obj.procs.FT.LastProc<0))
                obj.procs.FT.LastProc=t;
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
        function UseTargetAcquired(obj,name)
            if(nargin<2)
                name='Target Acquired';
            end
            obj.buffs.TA.LastUsed=obj.nextCast;
            %Take into account the 4pc/old2pc for CD
            baseCD=120-15*obj.stats.old2pc-15*obj.stats.pc4;
            obj.buffs.AD.Available=obj.nextCast+baseCD*(1-obj.stats.Alacrity);
            obj.activations{end+1}={obj.nextCast,name};
        end
        function UseLazeTarget(obj,name)
            if(nargin<2)
                name='Laze Target';
            end
            if(obj.nextCast>=obj.buffs.LT.Available)
                obj.autocrit_charges=obj.autocrit_charges+1+obj.stats.pc6;
                obj.buffs.LT.Available=obj.nextCast+60*(1-obj.stats.Alacrity);
                obj.buffs.LT.LastUsed=obj.nextCast;
                obj.activations{end+1}={obj.nextCast,name};
            else
                %disp('LT is not up yet');
            end
        end
        function UseSniperVolley(obj,name)
            if(nargin<2)
                name='Sniper Volley';
            end
           sv=obj.buffs.SV;
           if(obj.nextCast>sv.Available)
               obj.activations{end+1}={obj.nextCast,name};
               sv.LastUsed=obj.nextCast();
               sv.Available = 45*(1-obj.stats.Alacrity);
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
        
%%%%%%%%%%%%%%%%%
%%% PUB ABILITIES
%%%%%%%%%%%%%%%%%
        function [isCast,CDLeft]=UseSmugglersLuck(obj)
            [isCast,CDLeft]=obj.UseLazeTarget('Smuggler''s Luck');
        end
        function [isCast,CDLeft]=UseIllegalMods(obj)
           [isCast,CDLeft]=obj.UseTargetAcquired('Illegal Mods'); 
        end
        
        
        function [mhd,mhh,mhc,ohd,ohh,ohc] = CalculateDamage(obj,t,it,autocrit)
            if(nargin<4)
                autocrit = false;
            end
            if(t>obj.procs.SA.LastProc+obj.procs.SA.CD)
                if(rand()<0.3)
                    obj.SAprocs=obj.SAprocs+1;
                    obj.procs.SA.LastProc=t;
                end
            end
            if(t>obj.procs.FR.LastProc+obj.procs.FR.CD)
                if(rand()<0.3)
                    obj.FRprocs=obj.FRprocs+1;
                    obj.procs.FR.LastProc=t;
                end
            end
            
            bonusdmg=0;
            bonusacc=0;
            bonuscrit=0;
            bonusmult=0;
            if(isfield(it,'id') && strcmp(it.id,'snipe'))
                bonuscrit = 0.05*obj.procs.HS.Charges;
                bonusmult = 0.05*obj.procs.HS.Charges;
            end
            %is Focused Retribution Procced
            if(obj.procs.FR.LastProc>=0 && obj.procs.FR.LastProc+6>t)
                bonusdmg = bonusdmg + obj.stats.FR_proc*0.2*1.05*1.05;
            end
            
            %is Serendipidous Procced
            if(obj.procs.SA.LastProc>=0 && obj.procs.SA.LastProc+6>t)
                bonusdmg = bonusdmg + obj.stats.SA_proc*0.23*1.05;
            end
            
            %is Adrenal Used
            if(obj.buffs.AD.LastUsed>=0 && obj.buffs.AD.LastUsed+15>t)
                bonusdmg = bonusdmg + obj.stats.adrenal_amt*0.23*1.05;
            end
            %is Target Acquired Active
            if(obj.buffs.TA.LastUsed>=0 && obj.buffs.TA.LastUsed+15>t)
                bonusacc=0.3;
            end
            s_=obj.stats;
            if(it.w==1)
               rbonus = bonusdmg+obj.stats.RangedBonus;
               mhm= (rbonus*it.c+...
                  s_.MinMH*(1+it.Am)+it.Sm*it.Sh)*it.mult;
               mhx= (rbonus*it.c+...
                  s_.MaxMH*(1+it.Am)+it.Sx*it.Sh)*it.mult;
               ohn= (s_.MinOH*(1+it.Am))*it.mult;
               ohx= (s_.MaxOH*(1+it.Am))*it.mult;
               
               ohc = max(autocrit,rand()<(obj.stats.CritChance+it.cb+bonuscrit));
               ohh = rand()<(it.base_acc-obj.boss_def+obj.stats.Accuracy-0.3+bonusacc);
               ohd = (rand()*(ohx-ohn)+ohn)*(1+(s_.Surge+it.sb)*ohc)*ohh*0.3*(1+bonusmult);
               if(ohn==0 || ohx==0)
                   ohd=-1;
               end
               %fprintf('%f %f %f\n',mhm,mhx,rbonus);
            else
                tbonus = bonusdmg+obj.stats.TechBonus;
                mhm=(tbonus*it.c+it.Sm*it.Sh)*it.mult;
                mhx=(tbonus*it.c+it.Sx*it.Sh)*it.mult;
                ohc=0; ohh=0; ohd=-1;
            end
            mhc = max(rand()<(obj.stats.CritChance+it.cb+bonuscrit),autocrit);
            
            mhh = rand()<(obj.stats.Accuracy+it.base_acc-obj.boss_def+bonusacc);
            mhd = (rand()*(mhx-mhm)+mhm)*(1+(s_.Surge+it.sb)*mhc)*mhh*(1+bonusmult);
            %fprintf('%f %f %f\n',mhm,mhx,mhd);
            %2PC set bonus

            if(t<obj.procs.FR.LastProc+15 && obj.procs.FR.LastProc>=0)
                mhd=mhd*1.02;
                ohd=ohd*1.02;
            end;
            %Apply Raid multipliers
            mhd=mhd*it.raid_mult;
            ohd=ohd*it.raid_mult;
            %Sub 30% damage multiplier
            if(obj.total_damage>obj.total_HP*0.7)
               mhd=mhd*(1+it.s30);
               ohd=ohd*(1+it.s30);
            end
            
            
        end

    end
    
    
end

