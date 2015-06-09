classdef OptimizerOptions
    properties
        var;
        dependent;
        var_min=0;
        var_max=200;
        var_inc=10;
    end
    methods
        function obj=OptimizerOptions(var_,dependent_,min,max,increment)
            if(nargin==5)
                obj.var_inc=increment;
            end
            if(nargin>=4)
                obj.var_max=max;
            end
            if(nargin>=3)
                obj.var_min=min;
            end
            obj.var=var_;
            obj.dependent=dependent_;
        end
    end
end
