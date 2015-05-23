classdef BaseSimulator <handle
    %BASESIMULATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        stats=struct();
        abilities=struct();
        dots=struct();
        buffs=struct();
        procs=struct();
        activations={};
        autocrit_charges=0;
        autocrit_abilities={};
        autocrit_time_since_proc;
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
    end
    
    methods
        function obj=BaseSimulator()
           obj.out_stats=containers.Map(); 
        end
        function SaveStats(obj,fname)
           savejson('',obj.stats,fname) 
        end
        function LoadStats(obj,fname)
           obj.stats=loadjson(fname);
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
           obj.autocrit_time_since_proc=-1;
        end
        function UseAdrenal(obj)
            obj.buffs.AD.LastUsed=obj.nextCast;
            obj.buffs.AD.Available=obj.nextCast+180*(1-obj.stats.Alacrity);
        end
        function r = isAutocrit(obj,it)
            r=0;
            if(sum(strcmp(obj.autocrit_abilities,it.name))&&...
               obj.autocrit_charges>0)
               r=1;
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
        function [isCast,CDLeft]=ApplyDot(obj,dname,it)
            [isCast,CDLeft]=isAvailable(obj,it);
            if(~isCast)
                return;
            end
            t=obj.nextCast;
            obj.avail.(it.id)=t+it.CD*(1-obj.stats.Alacrity);
            DOTCheck(obj,t);
            [mhd,mhh,mhc]=CalculateDamage(obj,t,it);
            AddDamage(obj,{t,it.name,mhd,mhc,mhh},it);
            obj.activations{end+1}={t,it.name};
            obj.dots.(dname).Ala=obj.stats.Alacrity;
            obj.dots.(dname).LastUsed=t;
            obj.dots.(dname).NextTick=t+it.int*(1-obj.stats.Alacrity);
            obj.dots.(dname).Expire=t+it.dur*(1-obj.stats.Alacrity);
            obj.dots.(dname).WExpire=t+(it.dur+5)*(1-obj.stats.Alacrity);
            GCD=1.5*(1-obj.stats.Alacrity);
            DOTCheck(obj,t+GCD);
            obj.nextCast=t+GCD;
        end
        function [isCast,CDLeft]=ApplyInstantCast(obj,it)
            [isCast,CDLeft]=isAvailable(obj,it);
            if(~isCast)
                return;
            end
            t=obj.nextCast;
            obj.avail.(it.id)=t+it.CD*(1-obj.stats.Alacrity);
            [mhd,mhh,mhc,ohd,ohh,ohc]=CalculateDamage(obj,obj.nextCast,it);
            if(it.ctype==1)
                obj.activations{end+1}={t,it.name};
            end
            AddDamage(obj,{t,it.name,mhd,mhc,mhh},it);
            ac=isAutocrit(obj,it);
            if(ohd>=0)
                AddDamage(obj,{t,[it.name ' OH'],ohd,ohc,ohh},it);
            end
            if(isfield(it,'callback'))
                cbfunc=str2func(it.callback);
                cbfunc(obj,t,it);
            end
            if(it.ctype==1)
                t=obj.nextCast+1.5*(1-obj.stats.Alacrity);
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
            obj.activations{end+1}={obj.nextCast,it.name};
            obj.nextCast=obj.nextCast+(it.ct-ct_red)*(1-obj.stats.Alacrity);
            obj.avail.(it.id)=obj.nextCast+it.CD*(1-obj.stats.Alacrity);
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
            obj.activations{end+1}={obj.nextCast,it.name};
            ac=isAutocrit(obj,it);
            castTime=it.ct*(1-obj.stats.Alacrity);
            t=obj.nextCast;
            obj.avail.(it.id)=t+it.CD*(1-obj.stats.Alacrity);
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
           fn=fieldnames(obj.dots);
           for i = 1:size(fn,1)
              dot = fn{i};
              tn=obj.dots.(dot).NextTick;
              if(tn>0 && tn<=t) 
                    it=obj.abilities.(obj.dots.(dot).it);
                    [mhd,mhh,mhc]=CalculateDamage(obj,tn,it);
                    AddDamage(obj, {obj.dots.(dot).NextTick,it.name,mhd,mhc,mhh},it);

                    if(t>=obj.dots.(dot).Expire)
                        obj.dots.(dot).NextTick=-1;
                    else
                        obj.dots.(dot).NextTick=tn+it.int*(1-obj.dots.(dot).Ala);
                    end
              end
           end
        end 
        function AddDamage(obj,dmg,it)
            if(it.dmg_type==3 )
            elseif(it.dmg_type==1)
                     dmg{3}=dmg{3}*(1-CalculateBossDR(obj,it));
            end
            if(obj.total_damage<obj.total_HP)
            %if(true)
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
        function dr=CalculateBossDR(obj,it)
            extra_ap=0.0;
            ar=obj.boss_armor;
            ap=obj.armor_pen+obj.raid_armor_pen;
            if(isfield(it,'armor_pen'))
                extra_ap=it.armor_pen;
            end
            dr=ar*(1-min(ap+extra_ap,1))/(ar*(1-min(ap+extra_ap,1))+240*60+800);
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
            apm=max(size(obj.activations))/tt*60;
            dps=obj.total_damage/tt;
            cc=obj.crits/obj.dmg_effects;
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
        
        function [mhd,mhh,mhc,ohd,ohh,ohc] = CalculateDamage(obj,t,it,autocrit)
           %this function does nothing it needs to be s 
            
        end
        function [mhd,ohd] = CalculateBaseDamage(obj,it,crit)
            if(nargin<3)
                crit=0;
            end
            bonusdmg=0;
            bonusacc=0;
            bonuscrit=0;
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
                ohc=0; ohh=0; ohd=-1;
            end
            
            
            mhd = (rand()*(mhx-mhm)+mhm)*(1+(s_.Surge+it.sb)*crit);
            mn=mhm*(1+(s_.Surge+it.sb)*crit);
            mx=mhx*(1+(s_.Surge+it.sb)*crit);
            if(it.ctype==3)
                mn=mn*it.ticks;
                mx=mx*it.ticks;
            elseif(it.ctype==4)
                mn=mn*(it.dur/it.int+1);
                mx=mx*(it.dur/it.int+1);
            end
            
            fprintf('%.1f %.1f %.1f\n',mn,mx,mhd);
        end
        function AddToStats(obj,dmg)
            str_save=strrep(dmg{2},' ','_');
%           if(isKey(obj.out_stats,dmg{2}))
%              r=obj.out_stats(dmg{2});
%           else
%              r=struct('hits',0,'crits',0,'cd',0,'nd',0,'misses',0);
%           end
          if(isfield(obj.out_stats_new,str_save))
             r=obj.out_stats_new.(str_save);
           else
              r=struct('hits',0,'crits',0,'cd',0,'nd',0,'misses',0);
           end 
              
          % r=struct('hits',0,'crits',0,'cd',0,'nd',0,'misses',0);
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
              %r.hits=r.hits+1;
          end
          obj.out_stats_new.(str_save)=r;
          %obj.out_stats(dmg{2})=r;
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

