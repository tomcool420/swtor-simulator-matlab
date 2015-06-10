classdef Guardian <Simulator.BaseSimulator
    %GUARDIAN Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function [isCast,CDLeft]=ApplyMasterStrike(obj,it)
            [isCast,CDLeft]=isAvailable(obj,it);
            if(~isCast)
                return;
            end
            obj.AddToActivations({obj.nextCast,it.name});
            ac=isAutocrit(obj,it);
            t=obj.nextCast;
            ala=obj.GetAla(t);
            castTime=it.ct/(1+ala);
            
            obj.avail.(it.id)=t+it.CD/(1+ala);
            ticks=[0.370,.686,2.78]/(1+ala);
            for i = 1:3
                t=obj.nextCast+ticks(i);
                DOTCheck(obj,t);
                [mhd,mhh,mhc,ohd,ohh,ohc]=CalculateDamage(obj,t,it,ac);
                if(i<3)
                    mhd=mhd/2;
                    ohd=ohd/2;
                end
                AddDamage(obj,{t,it.name,mhd,mhc,mhh},it);
                if(ohd>=0)
                    AddDamage(obj,{t,[it.name ' OH'],ohd,ohc,ohh},it);
                end
                if(isfield(it,'callback'))
                    cbfunc=str2func(it.callback);
                    cbfunc(obj,t,it);
                end
            end

            
            obj.nextCast=obj.nextCast+castTime;
        end
    end
    
end

