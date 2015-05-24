classdef Shadow < BaseSimulator
    %SHADOW Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function [bd, bc, bs, baac,bmult]=CalculateBonus(obj,t,it)
           %No Need to calculate adrenals or relics here
           bd=0;bc=0;bs=0;baac=0;bmult=0;
        end
        
        function [mhd,mhh,mhc,ohd,ohh,ohc] = CalculateDamage(obj,t,it,autocrit)
            if(nargin<4)
                autocrit = false;
            end
            [bd_, bc_,bs_,baac_,bm_]=CalculateBonus(obj,t,it);
            
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
            bonusdmg=0+bd_;
            bacc=0+baac_;
            bc=0+bc_;    %Bonus Crit
            bs=0+bs_;   %Bonus Surge
            bm=0+bm_;   %Bonus Mult
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

            s_=obj.stats;
            if(it.w==1)
                rbonus = bonusdmg+obj.stats.RangedBonus;
                mhm= (rbonus*it.c+...
                    s_.MinMH*(1+it.Am)+it.Sm*it.Sh)*it.mult;
                mhx= (rbonus*it.c+...
                    s_.MaxMH*(1+it.Am)+it.Sx*it.Sh)*it.mult;
                ohn= (s_.MinOH*(1+it.Am))*it.mult;
                ohx= (s_.MaxOH*(1+it.Am))*it.mult;
                
                ohc = max(autocrit,rand()<(obj.stats.CritChance+bc+it.cb));
                ohh = rand()<(it.base_acc-obj.boss_def+obj.stats.Accuracy-0.3+bacc);
                ohd = (rand()*(ohx-ohn)+ohn)*(1+(s_.Surge+bs+it.sb)*ohc)*ohh*bm;
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
            mhc = max(rand()<(obj.stats.CritChance+it.cb+bc),autocrit);
            %mhc=0;
            mhh = rand()<(obj.stats.Accuracy+it.base_acc-obj.boss_def+bacc);
            mhd = (rand()*(mhx-mhm)+mhm)*(1+(s_.Surge+it.sb)*mhc)*mhh*bm;
            if(isfield(it,'charges'))
                mhd=mhd*it.charges;
            end
            %fprintf('%f %f %f\n',mhm,mhx,mhd);
            %2PC set bonus
            if(t<obj.procs.ST.LastProc+15 && obj.procs.ST.LastProc>=0)
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

