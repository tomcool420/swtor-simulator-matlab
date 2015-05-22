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
        autocrit_charges;
        autocrit_abilities={};
        autocrit_time_since_proc;
        total_damage=0;
        total_HP=1000000;
        boss_armor=8853;
        boss_def=.1;
        armor_pen=0.20;
        FRprocs=0;
        SAprocs=0;
        nextCast=0;
        act_nb=0;
        out_stats=0;
        dmg_effects=0;
        crits=0;
        damage={};
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
           l=loadjson(fname);
           obj.abilities=l.abilities;
           obj.dots=l.dots;
           obj.procs=l.procs;
           obj.buffs=l.buffs;
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
        function ApplyDot(obj,dname,it)
            t=obj.nextCast;
            DOTCheck(obj,t);
            [mhd,mhh,mhc]=CalculateDamage(obj,t,it);
            AddDamage(obj,{t,it.name,mhd,mhc,mhh},it);
            %double tick chance on CD
            if(strcmp(dname,'CD') && rand()<0.15)
                [mhd,mhh,mhc]=CalculateDamage(obj,t,it);
                AddDamage(obj,{t,it.name,mhd,mhc,mhh},it);
            end
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
        function ApplyInstantCast(obj,it)
            t=obj.nextCast;
            [mhd,mhh,mhc,ohd,ohh,ohc]=CalculateDamage(obj,obj.nextCast,it);
            if(it.ctype==1)
                obj.activations{end+1}={t,it.name};
            end
            AddDamage(obj,{t,it.name,mhd,mhc,mhh},it);
            ac=isAutocrit(obj,it);
            if(ohd>=0)
                AddDamage(obj,{t,['* ' it.name],ohd,ohc,ohh},it);
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
        function ApplyCastAbilities(obj,it)
            obj.activations{end+1}={obj.nextCast,it.name};
            obj.nextCast=obj.nextCast+it.ct*(1-obj.stats.Alacrity);
            t=obj.nextCast;
            DOTCheck(obj,t);
            ac=isAutocrit(obj,it);
            if(isfield(it,'callback'))
                cbfunc=str2func(it.callback);
                cbfunc(obj,t,it);
            end
            [mhd,mhh,mhc,ohd,ohh,ohc]=CalculateDamage(obj,obj.nextCast,it);
            AddDamage(obj,{obj.nextCast,it.name,mhd,mhc,mhh},it);
            if(ohd>=0)
                AddDamage(obj,{t,['* ' it.name],ohd,ohc,ohh},it);
            end
            if(ac==1)
                obj.autocrit_charges=obj.autocrit_charges-1;
            end
        end
        function ApplyChanneledAbility(obj,it)
            obj.activations{end+1}={obj.nextCast,it.name};
            ac=isAutocrit(obj,it);
            castTime=it.ct*(1-obj.stats.Alacrity);
            t=obj.nextCast;
            for i = 1:it.ticks
                DOTCheck(obj,t);
                [mhd,mhh,mhc,ohd,ohh,ohc]=CalculateDamage(obj,t,it,ac);
                AddDamage(obj,{t,it.name,mhd,mhc,mhh},it);
                if(ohd>=0)
                    AddDamage(obj,{t,['* ' it.name],ohd,ohc,ohh},it);
                end
                if(isfield(it,'callback'))
                    cbfunc=str2func(it.callback);
                    cbfunc(obj,t,it);
                end
                t=t+castTime/3;
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
                    if(strcmp(dot,'CD') && rand()<0.15)
                        [mhd,mhh,mhc]=CalculateDamage(obj,tn,it);
                        AddDamage(obj,{tn,it.name,mhd,mhc,mhh},it);
                    end
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
                if(obj.buffs.WB.LastUsed+obj.buffs.WB.Dur>dmg{1}...
                     && obj.buffs.WB.LastUsed>0)
                     [mhd,mhh,mhc]=CalculateDamage(obj,dmg{1},obj.abilities.wb);
                     AddDamage(obj,{dmg{1},obj.abilities.wb.name,mhd,mhc,mhh},obj.abilities.wb);
                end
             elseif(it.dmg_type==1)
                     dmg{3}=dmg{3}*(1-CalculateBossDR(obj,it));
             end
            if(obj.total_damage<obj.total_HP)
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
            ap=obj.armor_pen;
            dr=ar*(1-ap-extra_ap)/(ar*(1-ap-extra_ap)+240*60+800);
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
        function PrintStats(obj)
           total_time=obj.damage{end}{1};
           total_activations=max(size(obj.activations));
           tdmg=obj.total_damage;
           fprintf('STATS: time - %6.3f, damage = %6.3f, DPS = %6.3f, APM = %6.2f, Crit = %4.2f\n',...
               total_time,tdmg,tdmg/total_time,...
               total_activations/total_time*60,...
               obj.crits/obj.dmg_effects);
        end
        function PrintDetailedStats(obj)
            PrintStats(obj);
            fprintf('%s\n',repmat('=',1,110));
            ks=keys(obj.out_stats);
            fprintf('Ability%s#        d         n     nd        avg n    c    cd           cc       avg c       %%\n',repmat(' ',1,17));
            fprintf('%s\n',repmat('=',1,110)); 
            for i = 1:max(size(ks))
               k=obj.out_stats(ks{i});
               fprintf('| %-20s: %-5i  %10.1f  %-3i  %9.2f %8.2f  %-3i %9.2f %9.2f%%  %8.2f    %5.1f',...
                       ks{i},k.hits,k.cd+k.nd,k.hits-k.crits,k.nd,k.nd/(k.hits-k.crits),...
                       k.crits,k.cd,k.crits/k.hits*100,k.cd/k.crits,...
                       (k.cd+k.nd)/obj.total_damage*100);
               fprintf('\n')
                
            end
            fprintf('%s\n',repmat('=',1,110));
            
        end
        
        function [mhd,mhh,mhc,ohd,ohh,ohc] = CalculateDamage(obj,t,it,autocrit)
           %this function does nothing it needs to be s 
            
        end
        
        function AddToStats(obj,dmg)
          if(isKey(obj.out_stats,dmg{2}))
             r=obj.out_stats(dmg{2});
          else
             r=struct('hits',0,'crits',0,'cd',0,'nd',0,'misses',0);
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
              %r.hits=r.hits+1;
          end
          obj.out_stats(dmg{2})=r;
        end
        
    end
    
end

