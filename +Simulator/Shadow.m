classdef Shadow < Simulator.BaseSimulator
    %SHADOW Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        FP_charge_amount=3;
        LastFPChargeUsed=-1;
    end
    
    methods
        function UseForcePotency(obj)
            if(obj.nextCast>=obj.buffs.FP.Available)
                obj.buffs.FP.Available=obj.nextCast+(obj.buffs.FP.CD-15*obj.stats.pc4)/(1+obj.stats.Alacrity);
                obj.buffs.FP.LastUsed=obj.nextCast;
                obj.buffs.FP.Charges=obj.FP_charge_amount;
                obj.activations{end+1}={obj.nextCast,'Force Potency'};
            end
        end
        function UseBattleReadiness(obj)
            if(obj.nextCast>=obj.buffs.FP.Available)
                obj.buffs.BR.Available=obj.nextCast+obj.buffs.BR.CD/(1+obj.stats.Alacrity);
                obj.buffs.BR.LastUsed=obj.nextCast;
                obj.activations{end+1}={obj.nextCast,'Battle Readiness'};
            end
        end
        
        function [bd, bc, bs,bm]=CalculateBonus(obj,t,it,mhh,ohh)
            bd=0;bc=0;bs=0;bm=1;
            if(obj.buffs.FP.Charges>0 && obj.buffs.FP.LastUsed+obj.buffs.FP.Dur>t )
                if(strcmp(it.id,'fib')||strcmp(it.id,'vanquish'))
                    bc=0.6;
                    obj.LastFPChargeUsed=t;
                    obj.buffs.FP.Charges=obj.buffs.FP.Charges-1;
                end
                    
            end
        end
        
        function CritCallback(obj,t,it,bc,mhc,ohc)
           if(obj.LastFPChargeUsed==t&& mhc==0 && (strcmp(it.id,'fib')||strcmp(it.id,'vanquish'))) 
               obj.buffs.FP.Charges=min(obj.buffs.FP.Charges+1,obj.FP_charge_amount);
           end
        end
        
    end
    
end

