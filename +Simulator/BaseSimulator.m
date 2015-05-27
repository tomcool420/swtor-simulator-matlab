classdef BaseSimulator < handle
    %BASESIMULATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        stats=struct();
        abilities=struct();
        dots=struct();
        buffs=struct();
        procs=struct();
        activations={};
        log={};
        autocrit_charges=0;
        autocrit_abilities={};
        autocrit_last_proc=-1;
        autocrit_proc_duration=0;
        total_damage=0;
        total_HP=1000000;
        boss_armor=8853;
        boss_def=.1;
        armor_pen=0.00;
        raid_armor_pen=0.0;
        FRprocs=0;
        SAprocs=0;
        nextCast=0;
        act_nb=0;
        out_stats=0;
        dmg_effects=0;
        crits=0;
        damage={};
        bonus_alacrity=0.0;
        out_stats_new=struct();
        fresh_abilities=struct();
        avail=struct();
        extra_abilities=0;
        allow_dmg_past_total_HP=0;
        energy = struct('me',0,'ce',0,'next_tick',0);
        energy_enabled = 0;
        cooldown_enabled = 1;
    end
    
    methods
        function obj=BaseSimulator()
           obj.out_stats=containers.Map(); 
        end
%%%%%%%%%%%%%%
%%%Callbacks to subclass
%%%%%%%%%%%%%%
        function EnergyCheck(obj,t)
            
        end
        function DOTCheckCB(obj,t,it,dot)
            %Callback right AFTER a dot has ticked and the damage is
            %applied (used for double tick dart in virulence)
            obj;t;it;dot;
        end
        function bonuspen = CalculateBonusPen(obj,t,it)
            %Right before DR is calculated, check for bonus armor pen 
            %only use for cooldowns (illegal mods or target acquired
            bonuspen=0;
        end
        function AddDamageCB(obj,t,dmg,it)
            %"CallBack" (not) called right before the damage is applied
            %A good time to either proc on hit abilities (force technique) 
            %or on hit procs (force synergy)
            obj;t;it;dmg;
        end
        function bacc=CalculateBonusAccuracy(obj,t,it) 
            %Check if you have an accuracy debuff up;
            bacc=0;
        end
        function [bd, bc,bs,bm]=CalculateBonus(obj,t,it,mhh,ohh)
            bd=0;bc=0;bs=0;bm=1;
        end
        function CritCallback(obj,t,it,bc,mhc,ohc)
            %Function that gets called in case something special needs to
            %be done after a crit (quickly)
        end
        function SaveStats(obj,fname)
           savejson('',obj.stats,fname) 
        end
        function LoadStats(obj,fname)
           obj.stats=json.loadjson(fname);
        end
        function LoadAbilities(obj,fname)
            if(size(strfind(fname,'bin')))
                z=json.loadubjson(fname);
            else
                z=json.loadjson(fname);
            end
           LoadAbilities_(obj,z);
        end
        function LoadAbilities_(obj,z)
           obj.fresh_abilities=z;
           abl=obj.fresh_abilities.abilities;
           z=struct();
           fn=fieldnames(abl);
           for i = 1:max(size(fn))
              ab=abl.(fn{i});
              z.(ab.id)=0;
           end
           obj.avail=z;
           obj.abilities=obj.fresh_abilities.abilities;
           obj.dots=obj.fresh_abilities.dots;
           obj.procs=obj.fresh_abilities.procs;
           obj.buffs=obj.fresh_abilities.buffs;
        end
        function RefreshSimulator(obj)
           obj.abilities=obj.fresh_abilities.abilities;
           obj.dots=obj.fresh_abilities.dots;
           obj.procs=obj.fresh_abilities.procs;
           obj.buffs=obj.fresh_abilities.buffs;
           obj.total_damage=0;
           obj.crits=0;
           obj.damage={};
           obj.activations={};
           obj.act_nb;
           obj.autocrit_charges=0;
           obj.autocrit_abilities={};
           obj.autocrit_last_proc=-1;
        end
        function UseAdrenal(obj)
            obj.buffs.AD.LastUsed=obj.nextCast;
            obj.buffs.AD.Available=obj.nextCast+180/(1+obj.stats.Alacrity);
        end
        function r = isAutocrit(obj,it)
            r=0;
            if(sum(strcmp(obj.autocrit_abilities,it.name)))
                if(obj.autocrit_charges>0 && ...
                        obj.autocrit_proc_duration+obj.autocrit_last_proc>obj.nextCast)
                    r=1;
                end
            end
        end
        function [isAv,CDLeft]=isAvailable(obj,it)
            t=obj.nextCast;
            CDLeft=max(obj.avail.(it.id)-t,0);
            if(CDLeft<0.05)
                CDLeft=0;
            end
            isAv=(CDLeft==0);
        end
        function [isCast,CDLeft]=ApplyDot(obj,dname,it,offGCD)
            if (nargin<4)
                offGCD = false;
            end
            if(~offGCD)
                [isCast,CDLeft]=isAvailable(obj,it);
                if(~isCast)
                    return;
                end
            end
            t=obj.nextCast;
            obj.avail.(it.id)=t+it.CD/(1+obj.stats.Alacrity);
            DOTCheck(obj,t);
            
            if(~offGCD)
                obj.AddToActivations({t,it.name});
            end
            
            if(isfield(it,'initial_tick') && it.initial_tick==0)
            else
                [mhd,mhh,mhc]=CalculateDamage(obj,t,it);
                AddDamage(obj,{t,it.name,mhd,mhc,mhh},it);
            end

            obj.dots.(dname).Ala=obj.stats.Alacrity;
            obj.dots.(dname).LastUsed=t;
            obj.dots.(dname).NextTick=t+it.int/(1+obj.stats.Alacrity);
            obj.dots.(dname).Expire=t+it.dur/(1+obj.stats.Alacrity)*1.001;
            obj.dots.(dname).WExpire=t+(it.dur+5)/(1+obj.stats.Alacrity);
            if(~offGCD)
                GCD=1.5/(1+obj.stats.Alacrity);
                DOTCheck(obj,t+GCD);
                obj.nextCast=t+GCD;
            end
        end
        function [isCast,CDLeft]=ApplyInstantCast(obj,it)
            [isCast,CDLeft]=isAvailable(obj,it);
            if(~isCast)
                return;
            end
            t=obj.nextCast;
            obj.avail.(it.id)=t+it.CD/(1+obj.stats.Alacrity);
            
            if(it.ctype~=0)
                obj.AddToActivations({t,it.name});
            end
            ticks = 1;
            hits=1;
            if(isfield(it,'ticks'))
                ticks=it.ticks;
                hits=it.ticks;
            end
            if(isfield(it,'hits'))
                hits=it.hits;
            end
            for i = 1:hits
                ac=isAutocrit(obj,it);
                [mhd,mhh,mhc,ohd,ohh,ohc]=CalculateDamage(obj,obj.nextCast,it,ac);
                mhd=mhd/ticks;
                ohd=ohd/ticks;
                AddDamage(obj,{t,it.name,mhd,mhc,mhh},it);
                
                if(ohd>=0)
                    AddDamage(obj,{t,[it.name ' OH'],ohd,ohc,ohh},it);
                end
                if(isfield(it,'callback'))
                    cbfunc=str2func(it.callback);
                    cbfunc(obj,t,it);
                end
            end
            if(it.ctype>0)
                t=obj.nextCast+1.5/(1+obj.stats.Alacrity);
                DOTCheck(obj,t);
                obj.nextCast=t;
            end
            if(ac==1)
                obj.autocrit_charges=obj.autocrit_charges-1;
            end
        end  
        function [isCast,CDLeft]=ApplyCastAbilities(obj,it,ct_red)
            [isCast,CDLeft]=isAvailable(obj,it);
            if(~isCast)
                return;
            end
            if(nargin<3)
                ct_red=0;
            end
            obj.AddToActivations({obj.nextCast,it.name});
            obj.nextCast=obj.nextCast+(it.ct-ct_red)/(1+obj.stats.Alacrity);
            obj.avail.(it.id)=obj.nextCast+it.CD/(1+obj.stats.Alacrity);
            t=obj.nextCast;
            DOTCheck(obj,t);
            ac=isAutocrit(obj,it);
            if(isfield(it,'callback'))
                cbfunc=str2func(it.callback);
                cbfunc(obj,t,it);
            end
            [mhd,mhh,mhc,ohd,ohh,ohc]=CalculateDamage(obj,obj.nextCast,it,ac);
            AddDamage(obj,{obj.nextCast,it.name,mhd,mhc,mhh},it);
            if(ohd>=0)
                AddDamage(obj,{t,[it.name ' OH'],ohd,ohc,ohh},it);
            end
            if(ac==1)
                obj.autocrit_charges=obj.autocrit_charges-1;
            end
        end
        function [isCast,CDLeft]=ApplyChanneledAbility(obj,it)
            [isCast,CDLeft]=isAvailable(obj,it);
            if(~isCast)
                return;
            end
            obj.AddToActivations({obj.nextCast,it.name});
            ac=isAutocrit(obj,it);
            castTime=it.ct/(1+obj.stats.Alacrity);
            t=obj.nextCast;
            obj.avail.(it.id)=t+it.CD/(1+obj.stats.Alacrity);
            for i = 1:it.ticks
                DOTCheck(obj,t);
                [mhd,mhh,mhc,ohd,ohh,ohc]=CalculateDamage(obj,t,it,ac);
                AddDamage(obj,{t,it.name,mhd,mhc,mhh},it);
                if(ohd>=0)
                    AddDamage(obj,{t,[it.name ' OH'],ohd,ohc,ohh},it);
                end
                if(isfield(it,'callback'))
                    cbfunc=str2func(it.callback);
                    cbfunc(obj,t,it);
                end
                t=t+castTime/(it.ticks-1);
            end
            if(ac==1)
                obj.autocrit_charges=obj.autocrit_charges-1;
            end
            
            obj.nextCast=obj.nextCast+castTime;
        end

        function DOTCheck(obj,t)
           EnergyCheck(obj,t);
           fn=fieldnames(obj.dots);
           for i = 1:size(fn,1)
              dot = fn{i};
              tn=obj.dots.(dot).NextTick;
              while(tn>0 && tn<=t) 
                    it=obj.abilities.(obj.dots.(dot).it);
                    [mhd,mhh,mhc]=CalculateDamage(obj,tn,it);
                    AddDamage(obj, {obj.dots.(dot).NextTick,it.name,mhd,mhc,mhh},it);
                    DOTCheckCB(obj,t,it,dot);
                    dt=obj.dots.(dot);
%                     if(strcmp(dot,'FB'))
%                        fprintf('FB dot: %.2f lu %.1f nt %.1f nte %.1f exp %.1f\n',tn,dt.LastUsed,dt.NextTick,tn+it.int/(1+obj.dots.(dot).Ala)*.999,dt.Expire); 
%                     end
                    obj.dots.(dot).NextTick=tn+it.int/(1+obj.dots.(dot).Ala);
                    if(obj.dots.(dot).NextTick>obj.dots.(dot).Expire)
                        obj.dots.(dot).NextTick=-1;
                    end
                    tn=obj.dots.(dot).NextTick;
              end
           end
        end 

        function AddDamage(obj,dmg,it)
            AddDamageCB(obj,dmg{1},dmg,it);
            if(true)%obj.total_damage<obj.total_HP)
                if(dmg{4}>0)
                    obj.crits=obj.crits+1;
                end
                obj.dmg_effects=obj.dmg_effects+1;
                obj.total_damage=obj.total_damage+dmg{3};
                obj.damage{end+1}=dmg;
                AddToStats(obj,dmg);
            end
        end
        
        function AddDelay(obj,delay)
            obj.nextCast=obj.nextCast+delay;
            DOTCheck(obj,obj.nextCast);
        end
        function dr=CalculateBossDR(obj,it,t)
            extra_ap=0.0;
            ar=obj.boss_armor;
            bp= CalculateBonusPen(obj,it,t);
            ap=obj.armor_pen+obj.raid_armor_pen+bp;
            if(isfield(it,'armor_pen'))
                extra_ap=it.armor_pen;
            end
            ap=ap+extra_ap;
            if(ap>1);ap=1;end;
            dr=ar*(1-ap)/(ar*(1-ap)+240*60+800);
        end
        function PrintDamage(obj)
            dmg=obj.damage;
           for i = 1:max(size(obj.damage))
               dm=dmg{i};
               fprintf('[%6.2f] %-25s: %.0fDMG\n',dm{1},dm{2},dm{3}); 
           end
        end
        function PrintActivations(obj)
            act=obj.activations;
           for i = 1:max(size(obj.activations))
               ac=act{i};
               fprintf('[%6.2f] %-25s\n',ac{1},ac{2}); 
           end
        end
        function [tt,dps,apm,cc]=GetStats(obj)
            tt=obj.damage{end}{1}-obj.damage{1}{1};
            apm=max(size(obj.activations)+obj.extra_abilities)/tt*60;
            dps=obj.total_damage/tt;
            cc=obj.crits/obj.dmg_effects;
        end
        function MatchAPM(obj,target_apm)
            [tt,~,~,~]=GetStats(obj);
            act=max(size(obj.activations)+obj.extra_abilities);
            time=act/target_apm*60+obj.damage{1}{1};
            obj.damage{end+1}={time,'Dummy APM Padding'};
        end
        function PrintStats(obj)
           [tt,dps,apm,cc]=obj.GetStats();
           fprintf('STATS: time - %6.3f, damage = %6.3f, DPS = %6.3f, APM = %6.2f, Crit = %4.2f\n',...
               tt,obj.total_damage,dps,apm,cc);
        end
        function PrintDetailedStats(obj)
            PrintStats(obj);
            fprintf('%s\n',repmat('=',1,110));
            ks=fieldnames(obj.out_stats_new);
            fprintf('Ability%s#        d         n     nd        avg n    c    cd           cc       avg c       %%\n',repmat(' ',1,17));
            fprintf('%s\n',repmat('=',1,110)); 
            for i = 1:max(size(ks))
               k=obj.out_stats_new.(ks{i});
               fprintf('| %-20s: %-5i  %10.1f  %-3i  %9.2f %8.2f  %-3i %9.2f %9.2f%%  %8.2f    %5.1f',...
                       ks{i},k.hits,k.cd+k.nd,k.hits-k.crits-k.misses,k.nd,k.nd/(k.hits-k.crits-k.misses),...
                       k.crits,k.cd,k.crits/k.hits*100,k.cd/k.crits,...
                       (k.cd+k.nd)/obj.total_damage*100);
               fprintf('\n')
                
            end
            fprintf('%s\n',repmat('=',1,110));
            
        end
        function AddToActivations(obj,act)
            obj.log{end+1}=act;
            obj.activations{end+1}=act;
        end
       function PrintLogAbility(obj,it)
           counter=0;
          for i = 1:numel(obj.log)
              o=obj.log{i};
              
             if(strcmp(o{2},it.name))
                 if(numel(o)>2)
                     counter=counter+1;
                     fprintf('%.0f     [%6.2f] %-25s: %.0fDMG\n',counter,o{1},o{2},o{3});
                 else
                     fprintf('[%6.2f] %-25s\n',o{1},o{2});
                     counter=0;
                 end
                 
                 
             end
          end
       end
       function [mhd,mhh,mhc,ohd,ohh,ohc] = CalculateDamage(obj,t,it,autocrit)
            if(nargin<4)
                autocrit = false;
            end
            mhd=0;mhc=0;ohd=0;ohc=0;
            s_=obj.stats;
%             if(autocrit)
%                fprintf('woo autocrit\n'); 
%             end
            %Check if there is an accuracy boost - 
            [bacc]=CalculateBonusAccuracy(obj,t,it);
            %Calculate Hit Checks
            ohh = rand()<(it.base_acc-obj.boss_def+obj.stats.Accuracy-0.3+bacc);
            mhh = rand()<(obj.stats.Accuracy+it.base_acc-obj.boss_def+bacc);
            if(mhh==0 && ohc == 0) % missed, no point in continuing
                if(s_.MinOH==0)
                    ohd=-1;
                end
                return;
            end
            %Calculate Bonuses (passed hit check)
            [bd_, bc_,bs_,bm_]=CalculateBonus(obj,t,it,mhh,ohh);
            
            %Calculate Relic Procs (SA and FR)
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
            
            bd=0+bd_;
            bc=0+bc_;       %Bonus Crit    10% = 0.1
            bs=0+bs_;       %Bonus Surge   10% = 0.1
            bm=0+bm_;       %Bonus Mult    10% = 0.1
                            % Dots under Fib Debuff = 10% boost
                            % Tactics CellBurst = 0-3 depending on
                            % lodes

            
            %is Focused Retribution Procced
            if(obj.procs.FR.LastProc>=0 && obj.procs.FR.LastProc+6>t)
                bd = bd + obj.stats.FR_proc*0.2*1.05*1.05;
            end
            
            %is Serendipidous Procced
            if(obj.procs.SA.LastProc>=0 && obj.procs.SA.LastProc+6>t)
                bd = bd + obj.stats.SA_proc*0.23*1.05;
            end
            
            %is Adrenal Used
            if(obj.buffs.AD.LastUsed>=0 && obj.buffs.AD.LastUsed+15>t)
                bd = bd + obj.stats.adrenal_amt*0.23*1.05;
            end

            
            if(it.w==1)                              %is a weapon attack
                rbonus = bd+obj.stats.RangedBonus;
                mhm= (rbonus*it.c+...                %Main Hand Min
                    s_.MinMH*(1+it.Am)+it.Sm*it.Sh)*it.mult;
                mhx= (rbonus*it.c+...                %Main Hand Max
                    s_.MaxMH*(1+it.Am)+it.Sx*it.Sh)*it.mult;
                ohn= (s_.MinOH*(1+it.Am))*it.mult;   %Off Hand Min
                ohx= (s_.MaxOH*(1+it.Am))*it.mult;   %Off Hand Min
                
                ohc = max(autocrit,rand()<(obj.stats.CritChance+bc+it.cb));
                ohh = rand()<(it.base_acc-obj.boss_def+obj.stats.Accuracy-0.3+bacc);
                ohd = (rand()*(ohx-ohn)+ohn)*(1+(s_.Surge+bs+it.sb)*ohc)*ohh*bm*0.3;
                if(ohn==0 || ohx==0)
                    ohd=-1;
                end
            else                                     %Force/Tech Attack
                tbonus = bd+obj.stats.TechBonus;
                mhm=(tbonus*it.c+it.Sm*it.Sh)*it.mult;
                mhx=(tbonus*it.c+it.Sx*it.Sh)*it.mult;
                ohc=0; ohh=0; ohd=-1;
            end
            
            %Calculate Crit Chance
            nm=it.name;
            mhc = min(max(rand()<(obj.stats.CritChance+it.cb+bc),autocrit),1);
            CritCallback(obj,t,it,bc,mhc,ohc)
            mhd = (rand()*(mhx-mhm)+mhm)...    %Randomize hit between max and min
                  *(1+(s_.Surge+it.sb)*mhc)... %Apply Crit Multiplier
                  *mhh...                      %Is it a hit?
                  *bm;                         %Apply the multiplier
            

            %2PC set bonus
            if(isfield(obj.procs,'PC2') && ...
                t<obj.procs.PC2.LastProc+15 && obj.procs.PC2.LastProc>=0)
                mhd=mhd*1.02;
                ohd=ohd*1.02;
            end;
            
            %Sub 30% damage multiplier
            if(obj.total_damage>obj.total_HP*0.7)
                mhd=mhd*(1+it.s30);
                ohd=ohd*(1+it.s30);
            end
%             mhd=round(mhd);
%             ohd=round(ohd);
            %Apply Raid multipliers
            mhd=mhd*it.raid_mult;
            ohd=ohd*it.raid_mult;
            

            
            %Apply Boss Damage Reduction 
            if(it.dmg_type==1||it.dmg_type==2)
               dr=obj.CalculateBossDR(it,t);
               mhd=mhd*(1-dr);
               ohd=ohd*(1-dr);
            end
       end

       function [mhd,ohd] = CalculateBaseDamage(obj,it,crit)
            if(nargin<3)
                crit=0;
            end
            bonusdmg=0;
            bonusmult=0;
            s_=obj.stats;
            if(it.w==1)
               rbonus = bonusdmg+obj.stats.RangedBonus;
               mhm= (rbonus*it.c+...
                  s_.MinMH*(1+it.Am)+it.Sm*it.Sh)*it.mult;
               mhx= (rbonus*it.c+...
                  s_.MaxMH*(1+it.Am)+it.Sx*it.Sh)*it.mult;
               ohn= (s_.MinOH*(1+it.Am))*it.mult;
               ohx= (s_.MaxOH*(1+it.Am))*it.mult;
               
              
               ohd = (rand()*(ohx-ohn)+ohn)*(1+(s_.Surge+it.sb)*crit)*0.3*(1+bonusmult);
               if(ohn==0 || ohx==0)
                   ohd=-1;
               end
               %fprintf('%f %f %f\n',mhm,mhx,rbonus);
            else
                tbonus = bonusdmg+obj.stats.TechBonus;
                mhm=(tbonus*it.c+it.Sm*it.Sh)*it.mult;
                mhx=(tbonus*it.c+it.Sx*it.Sh)*it.mult;
                ohd=-1;
            end
            
            
            mhd = (rand()*(mhx-mhm)+mhm)*(1+(s_.Surge+it.sb)*crit);
            mn=mhm*(1+(s_.Surge+it.sb)*crit);
            mx=mhx*(1+(s_.Surge+it.sb)*crit);
            if(it.ctype==3)
                mn=mn*it.ticks;
                mx=mx*it.ticks;
            elseif(it.ctype==4)
                s=1;
                if(isfield(it,'initial_tick')&&it.initial_tick==0)
                    s=0;
                end
                mn=mn*(it.dur/it.int+s);
                mx=mx*(it.dur/it.int+s);
            end
            
            fprintf('%.1f %.1f %.1f\n',mn,mx,mhd);
        end
        function AddToStats(obj,dmg)
            obj.log{end+1}=dmg;
            str_save=strrep(dmg{2},' ','_');
          if(isfield(obj.out_stats_new,str_save))
             r=obj.out_stats_new.(str_save);
           else
              r=struct('hits',0,'crits',0,'cd',0,'nd',0,'misses',0,'PrettyName','');
           end 
          r.hits=r.hits+1;
          if(dmg{5}==0)
              r.misses=r.misses+1;
          else
              if(dmg{4}>0)
                  r.crits=r.crits+1;
                  r.cd=r.cd+dmg{3};
              else
                  r.nd=r.nd+dmg{3};
              end
          end
          obj.out_stats_new.(str_save)=r;
        end
        
        function GetSize(this)
            props = properties(this);
            totSize = 0;
            for ii=1:length(props)
                currentProperty = getfield(this, char(props(ii)));
                s = whos('currentProperty');
                totSize = totSize + s.bytes;
            end
            fprintf(1, '%d bytes\n', totSize);
        end
    end
    
end

