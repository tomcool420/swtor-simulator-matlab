classdef RotOptions < handle
    %ROTOPTIONS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        continue_past_hp=0;
        total_HP=1e6;
        use_mean=0;
        use_armor_debuff=1;
        preload_buffs=1;
        detailed_stats=1;
    end
    
    methods
        function obj=RotOptions(cont_past,hp,mean)
            if(nargin<3)
                mean=0;
            end
            if(nargin<2)
                hp=1e6;
            end
            if(nargin<1)
                cont_past=0;
            end
           obj.continue_past_hp=cont_past;
           obj.total_HP=hp;
           obj.use_mean=mean;
        end
    end
    
end

