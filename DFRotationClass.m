classdef DFRotationClass < handle
    %DFROTATIONCLASS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
%         s=struct('TechBonus', 1937.2,'RangedBonus',1309,...
%                      'CritChance',.2738, 'Surge', .6882, 'Alacrity', .0158,...
%                      'MinMH',886,'MaxMH',1083,'MinOH',0,'MaxOH',0,'Accuracy',1,...
%                   'FR_proc',855,'SA_proc',855);
        s=struct('TechBonus', 2044.8,'RangedBonus',1386.7,...
                  'CritChance',.2743, 'Surge', .6940, 'Alacrity', .0158,...
                  'MinMH',998,'MaxMH',1220,'MinOH',0,'MaxOH',0,'Accuracy',0.1,...
                  'FR_proc',890,'SA_proc',890,'adrenal_amt',750);

        ls_w=struct('c',0.998,'Sm',0.099,'Sx',0.099,'Sh',3185,'Am',-0.34,...
            'w',1,'mult',1.1,'cb',0,'sb',0,'s30',0,'ct',1.5,...
            'base_acc',1,'raid_mult',1.05);
%         
        ls_i=struct('c',0.77,'Sm',0.077,'Sx',0.077,'Sh',3185,'Am',0,...
            'w',0,'mult',1.1025,'cb',0,'sb',0,'s30',0.15,'ct',1.5,...
            'base_acc',1,'raid_mult',1.12);
% %         
        cull=struct('c',0.805,'Sm',0.081,'Sx',0.081,'Sh',3185,'Am',-0.46,...
            'w',1,'mult',1.05,'cb',0.1,'sb',0,'s30',0.0,'ct',3.0,...
            'base_acc',1,'raid_mult',1.05);
%         
        cg=struct('c',0.3,'Sm',0.027,'Sx',0.027,'Sh',3185,'Am',0,...
            'w',0,'mult',1.05,'cb',0.1,'sb',0,'s30',0.15,'ct',0,'int',3,...
            'base_acc',1,'raid_mult',1.19);
% %         
% % %         %Corrosive grenade benefits from aoe dmg increase (somehow)
        cd=struct('c', 0.30 ,'Sm',0.03075,'Sx',0.03075,'Sh',3185,'Am',0,...
            'w',0,'mult',1,'cb',0.1,'sb',0,'s30',0.15,'ct',0,'int',3,...
            'base_acc',1,'raid_mult',1.12);
% %         
        wb=struct('c', 0.153 ,'Sm',0.0153,'Sx',0.0153,'Sh',3185,'Am',-0.9,...
            'w',1,'mult',1,'cb',0,'sb',0,'s30',0.0,'ct',0,...
            'base_acc',1,'raid_mult',1.05);
% % %         
        
        td=struct('c', 2.51 ,'Sm',0.251,'Sx',0.251,'Sh',3185,'Am',0.67,...
            'w',1,'mult',1,'cb',0,'sb',0,'s30',0.0,'ct',0,...
            'base_acc',1,'raid_mult',1.05);
%         
        sos=struct('c', 0.93 ,'Sm',0.093,'Sx',0.093,'Sh',3185,'Am',-0.38,...
            'w',1,'mult',1.1,'cb',0.1,'sb',0,'s30',0.0,'ct',3.0,...
            'base_acc',1,'raid_mult',1.05);
% %         
%         rs=struct('c', 0.5 ,'Sm',0.0,'Sx',0.0,'Sh',3185,'Am',-0.50,...
%             'w',1,'mult',1.0,'cb',0.1,'sb',0,'s30',0.0,'ct',0,...
%             'base_acc',0.9,'raid_mult',1.05);
        
        stats=0;
        crits=0;
        dmg_effects=0;
        laze_off_cd = -1;
        activations={};
        damage={};
        buffs=struct('TA',struct('LastUsed',-1,'Available',0),...
                     'LT',struct('LastUsed',-1,'Available',0),...
                     'AD',struct('LastUsed',-1,'Available',0),...
                     'BARelic',struct('LastUsed',-1,'Available',0));
        dots=struct('CG',struct('LastUsed',-1,'NextTick',-1,...
                                'Expire',-1,'WExpire',-1),...
                    'CD',struct('LastUsed',-1,'NextTick',-1,...
                                'Expire',-1,'WExpire',-1),...
                    'CM',struct('LastUsed',-1,'NextTick',-1,...
                                'Expire',-1,'WExpire',-1));
        procs=struct('FR',struct('LastProc',-1,'Dur',6,'CD',20),...
                     'SR',struct('LastProc',-1,'Dur',6,'CD',20),...
                     'FT',struct('LastProc',-1,'Dur',15,'CD',30))
        lastWeakeningBlast=-1;
        lastCorrosiveGrenade=-1;
        lastCorrosiveDart=-1;
        lastAdrenalUsage=-1;
        lastTargetAcquired=-1;
        lastFRproc=-1;
        lastSAproc=-1;
        lastFTproc=-1;
        CGExpire=-1;
        CDExpire=-1;
        CGWExpire=-1;
        CDWExpire=-1;
        CDala=0;
        CGala=0;
        nextCDTick=-1;
        nextCGTick=-1;
        nextCast=0;
        act_nb=0;
        sub30=false;
        total_damage=0;
        total_HP=1000000;
        laze_target_charges=0;
        boss_armor=8853;
        boss_def=.1;
        armor_pen=0.20;
        FRprocs=0;
        SAprocs=0;
        extra_ranged_dmg=.05;
        extra_internal_dmg=0.07;
        
        
    end
    
    methods
        function obj=DFRotationClass()
            obj@handle();
            obj.CDala=obj.s.Alacrity;
            obj.CGala=obj.s.Alacrity;
            obj.stats=containers.Map();
        end
        function AddDelay(obj,delay)
            obj.nextCast=obj.nextCast+delay;
            DOTCheck(obj,obj.nextCast);
        end
        function dr=CalculateBossDR(obj)
            extra_ap=0.0;
            if(obj.lastTargetAcquired>=0 && obj.lastTargetAcquired+15>obj.nextCast)
                extra_ap=0.15;
            end
            ar=obj.boss_armor;
            ap=obj.armor_pen;
            
            dr=ar*(1-ap-extra_ap)/(ar*(1-ap-extra_ap)+240*60+800);
        end
        function UseRifleShot(obj)
            [mhd,mhh,mhc,ohd,ohh,ohc]=CalculateDamage(obj,obj.nextCast,obj.rs);     
            AddDamage(obj,{obj.nextCast,'Rifle Shot',mhd,mhc,mhh},'energy');
            
            obj.activations{end+1}={obj.nextCast,'Rifle Shot'};
            castTime=1.5*(1-obj.s.Alacrity);
            obj.nextCast=obj.nextCast+castTime;
            DOTCheck(obj,obj.nextCast);
            
        end
        function UseAdrenal(obj)
            obj.lastAdrenalUsage=obj.nextCast;
        end
        function UseTargetAcquired(obj)
           obj.lastTargetAcquired=obj.nextCast; 
        end
        function UseCorrosiveGrenade(obj)
            t=obj.nextCast;
            [mhd,mhh,mhc]=CalculateDamage(obj,obj.nextCast,obj.cg);
            AddDamage(obj,{obj.nextCast,'Corrosive Grenade',mhd,mhc,mhh},'internal');
            obj.activations{end+1}={t,'Corrosive Grenade'};
            CGAla=obj.s.Alacrity;
            obj.lastCorrosiveGrenade=t;
            obj.nextCGTick=t+3*(1-CGAla);
            obj.CGExpire=t+24*(1-CGAla);
            obj.CGWExpire=t+29*(1-CGAla);
            castTime=1.5*(1-obj.s.Alacrity);
            obj.CGala=CGAla;
            obj.nextCast=t+castTime;
        end
        function UseLazeTarget(obj)
           if(obj.nextCast>obj.laze_off_cd)
               obj.laze_target_charges=obj.laze_target_charges+1;
               obj.laze_off_cd=obj.nextCast+60*(1-obj.s.Alacrity);
               obj.activations{end+1}={obj.nextCast,'Laze Target'};
           end
           
        end
        function UseCorrosiveDart(obj)
            t=obj.nextCast;
            [mhd,mhh,mhc]=CalculateDamage(obj,obj.nextCast,obj.cd);
            AddDamage(obj,{obj.nextCast,'Corrosive Dart',mhd,mhc,mhh},'internal');
            obj.activations{end+1}={t,'Corrosive Dart'};
            CDAla=obj.s.Alacrity;
            obj.lastCorrosiveDart=t;
            obj.nextCDTick=t+3*(1-CDAla);
            obj.CDExpire=t+24*(1-CDAla);
            obj.CDWExpire=t+29*(1-CDAla);
            castTime=1.5*(1-obj.s.Alacrity);
            obj.CDala=CDAla;
            obj.nextCast=t+castTime;
        end
        function UseWeakeningBlast(obj)
           t=obj.nextCast;
           [mhd,mhh,mhc]=CalculateDamage(obj,obj.nextCast,obj.cd);
           obj.activations{end+1}={t,'Weakening Blast'};
           AddDamage(obj,{t,'Weakening Blast',mhd,mhc,mhh},'energy');
           castTime=1.5*(1-obj.s.Alacrity);
           obj.lastWeakeningBlast=t;
           obj.nextCast=t+castTime;
           DOTCheck(obj,obj.nextCast);
        end
        function DOTCheck(obj,t)
           CDCheck(obj,t);
           CGCheck(obj,t);
        end
        function CGCheck(obj,t)

            it=obj.cg;
            
            if(obj.nextCGTick>0 && t>obj.nextCGTick)
               [mhd,mhh,mhc]=CalculateDamage(obj,obj.nextCGTick,obj.cg);
               AddDamage(obj, {obj.nextCGTick,'Corrosive Grenade',mhd,mhc,mhh},'internal');
               
               if (t>obj.CGExpire)
                   obj.nextCGTick=-1;
               else
                   obj.nextCGTick=obj.nextCGTick+it.int;
               end
            end
            
        end
        function CDCheck(obj,t)

            it=obj.cd;
            
            if(obj.nextCDTick>0 && t>obj.nextCDTick)
                [mhd,mhh,mhc]=CalculateDamage(obj,obj.nextCDTick,obj.cd);
               AddDamage(obj, {obj.nextCDTick,'Corrosive Dart',mhd,mhc,mhh},'internal');
               if(rand()<0.15)  %Double Tick Chance
                  [mhd,mhh,mhc]=CalculateDamage(obj,obj.nextCDTick,obj.cd); 
                  AddDamage(obj, {obj.nextCDTick,'Corrosive Dart',mhd,mhc,mhh},'internal');
               end
               if (t>obj.CGExpire)
                   obj.nextCDTick=-1;
               else
                   obj.nextCDTick=obj.nextCDTick+it.int;
               end
            end
            
            
        end
        function UseTakedown(obj)
            [mhd,mhh,mhc,ohd,ohh,ohc]=CalculateDamage(obj,obj.nextCast,obj.td);     
            AddDamage(obj,{obj.nextCast,'Takedown',mhd,mhc,mhh},'energy');
            
            obj.activations{end+1}={obj.nextCast,'Takedown'};
            castTime=1.5*(1-obj.s.Alacrity);
            obj.nextCast=obj.nextCast+castTime;
            DOTCheck(obj,obj.nextCast);
            
        end
        function AddToStats(obj,dmg)
          if(isKey(obj.stats,dmg{2}))
             r=obj.stats(dmg{2});
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
          obj.stats(dmg{2})=r;
        end
        function UseLethalShot(obj)
            it=obj.ls_w;
            obj.activations{end+1}={obj.nextCast,'Lethal Shot'};
            
            castTime=it.ct*(1-obj.s.Alacrity);
            
            obj.nextCast=obj.nextCast+castTime;
            DOTCheck(obj,obj.nextCast);
            t=obj.nextCast;
            if(t>=obj.lastFTproc+30|| obj.lastFTproc<0)
                obj.lastFTproc=t;
            end
            [mhd,mhh,mhc,ohd,ohh,ohc]=CalculateDamage(obj,obj.nextCast,obj.ls_w);
            AddDamage(obj,{obj.nextCast,'LethalShot - MH',mhd,mhc,mhh},'energy');
            [mhd,mhh,mhc,ohd,ohh,ohc]=CalculateDamage(obj,obj.nextCast,obj.ls_i);
            AddDamage(obj,{obj.nextCast,'LethalShot - Int',mhd,mhc,mhh},'internal');
            
            %obj.activations{end+1}={obj.nextCast,'Lethal Shot'};
            
        end
        function AddDamage(obj,dmg,type)
            if(strcmp(type,'internal') )
                if(obj.lastWeakeningBlast+10>dmg{1} && obj.lastWeakeningBlast>0)
                    [mhd,mhh,mhc]=CalculateDamage(obj,dmg{1},obj.wb);
                    AddDamage(obj,{dmg{1},'Weakening Blast',mhd,mhc,mhh},'energy');
                end
            elseif(strcmp(type,'energy')||strcmp(type,'kinetic'))
                    dmg{3}=dmg{3}*(1-CalculateBossDR(obj));
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
        
        function PrintDamage(obj,s,e)
            dmg=obj.damage;
           for i = 1:max(size(obj.damage))
               dm=dmg{i};
               fprintf('[%6.2f] %-25s: %.0fDMG\n',dm{1},dm{2},dm{3}); 
           end
        end
        function PrintActivations(obj,s,e)
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
            ks=keys(obj.stats);
            fprintf('Ability%s#        d         n     nd        avg n    c    cd           cc       avg c       %%\n',repmat(' ',1,17));
            fprintf('%s\n',repmat('=',1,110)); 
            for i = 1:max(size(ks))
               k=obj.stats(ks{i});
               fprintf('| %-20s: %-5i  %10.1f  %-3i  %9.2f %8.2f  %-3i %9.2f %9.2f%%  %8.2f    %5.1f',...
                       ks{i},k.hits,k.cd+k.nd,k.hits-k.crits,k.nd,k.nd/(k.hits-k.crits),...
                       k.crits,k.cd,k.crits/k.hits*100,k.cd/k.crits,...
                       (k.cd+k.nd)/obj.total_damage*100);
               fprintf('\n')
                
            end
            fprintf('%s\n',repmat('=',1,110));
            
        end
        function UseSeriesOfShots(obj)
            castTime=obj.sos.ct*(1-obj.s.Alacrity);
            t=obj.nextCast;
            obj.activations{end+1}={obj.nextCast,'Series of Shots'};
            ProcessSOS(obj,t);
            t=t+castTime/3; ProcessSOS(obj,t);
            t=t+castTime/3; ProcessSOS(obj,t);
            t=t+castTime/3; ProcessSOS(obj,t);
            obj.nextCast=t;
            
        end
        function ProcessSOS(obj,t)
           [mhd,mhh,mhc]=CalculateDamage(obj,t,obj.sos);
            AddDamage(obj,{t,'Series of Shots',mhd,mhc,mhh},'energy');
            DOTCheck(obj,t);
        end
        function UseCull(obj)
            castTime=obj.cull.ct*(1-obj.s.Alacrity);
            t=obj.nextCast;
            obj.activations{end+1}={obj.nextCast,'Cull'};
            ProcessCull(obj,t);
            t=t+castTime/3;ProcessCull(obj,t);
            t=t+castTime/3;ProcessCull(obj,t);
            t=t+castTime/3;ProcessCull(obj,t);
            obj.nextCast=t;
            if(obj.laze_target_charges>0)
                obj.laze_target_charges=obj.laze_target_charges-1;
            end
        end
        function ProcessCull(obj,t)
            ac=0;
            if(obj.laze_target_charges>0);ac=1;end
            DOTCheck(obj,t);
           [mhd,mhh,mhc]=CalculateDamage(obj,t,obj.cull,ac);
            AddDamage(obj,{t,'Cull',mhd,mhc,mhh},'energy');
            if(t<obj.CDWExpire)
                [mhd,mhh,mhc]=CalculateDamage(obj,t,obj.cd);
                 AddDamage(obj, {t,'Corrosive Dart',mhd,mhc,mhh},'internal');
            end
            if(t<obj.CGWExpire)
                [mhd,mhh,mhc]=CalculateDamage(obj,t,obj.cg);
                 AddDamage(obj, {t,'Corrosive Grenade',mhd,mhc,mhh},'internal');
            end

        end
        
        function [mhd,mhh,mhc,ohd,ohh,ohc] = CalculateDamage(obj,t,it,autocrit)
            if(nargin<4)
                autocrit = false;
            end
            if(t>obj.lastSAproc+20)
                if(rand()<0.3)
                    obj.SAprocs=obj.SAprocs+1;
                    obj.lastSAproc=t;
                end
            end
            if(t>obj.lastFRproc+20)
                if(rand()<0.3)
                    obj.FRprocs=obj.FRprocs+1;
                    obj.lastFRproc=t;
                end
            end
            bonusdmg=0;
            bonusacc=0;
            %is Focused Retribution Procced
            if(obj.lastFRproc>=0 && obj.lastFRproc+6>t)
                bonusdmg = bonusdmg + obj.s.FR_proc*0.2*1.05*1.05;
            end
            
            %is Serendipidous Procced
            if(obj.lastSAproc>=0 && obj.lastSAproc+6>t)
                bonusdmg = bonusdmg + obj.s.SA_proc*0.23*1.05;
            end
            
            %is Adrenal Used
            if(obj.lastAdrenalUsage>=0 && obj.lastAdrenalUsage+15>t)
                bonusdmg = bonusdmg + obj.s.adrenal_amt*0.23*1.05;
            end
            %is Target Acquired Active
            if(obj.lastTargetAcquired>=0 && obj.lastTargetAcquired+15>t)
                bonusacc=0.3;
            end
            s_=obj.s;
            if(it.w==1)
               rbonus = bonusdmg+obj.s.RangedBonus;
               mhm= (rbonus*it.c+...
                  s_.MinMH*(1+it.Am)+it.Sm*it.Sh)*it.mult;
               mhx= (rbonus*it.c+...
                  s_.MaxMH*(1+it.Am)+it.Sx*it.Sh)*it.mult;
               ohn= (s_.MinOH*(1+it.Am))*it.mult;
               ohx= (s_.MaxOH*(1+it.Am))*it.mult;
               
               ohc = max(autocrit,rand()<(obj.s.CritChance+it.cb));
               ohh = rand()<(it.base_acc-obj.boss_def+obj.s.Accuracy-0.3+bonusacc);
               ohd = (rand()*(ohx-ohn)+ohn)*(1+(s_.Surge+it.sb)*ohc)*ohh;
               
            else
                tbonus = bonusdmg+obj.s.TechBonus;
                mhm=(tbonus*it.c+it.Sm*it.Sh)*it.mult;
                mhx=(tbonus*it.c+it.Sx*it.Sh)*it.mult;
                ohc=0; ohh=0; ohd=0;
            end
            mhc = max(rand()<(obj.s.CritChance+it.cb),autocrit);
            
            mhh = rand()<(obj.s.Accuracy+it.base_acc-obj.boss_def+bonusacc);
            mhd = (rand()*(mhx-mhm)+mhm)*(1+(s_.Surge+it.sb)*mhc)*mhh;
            
            %2PC set bonus
            if(t<obj.lastFTproc+15 && obj.lastFRproc>=0)
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

