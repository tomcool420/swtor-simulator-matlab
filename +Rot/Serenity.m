classdef Serenity <Rot.BaseRotation
    %SERENITY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj=Serenity(opts)
            if(nargin<1)
                obj.options=Rot.RotOptions();
            else
                obj.options=opts;
            end
            obj.imp_json='json/Serenity.json';
            obj.pub_json='json/DirtyFighting.json';
            obj.load_abilities();
        end
        function s=SetupSimulator(obj)
            s = Simulator.Serenity(obj.abilities);
            opts=obj.opts;
            s.continue_past_hp=opts.continue_past_hp;
            s.total_HP=opts.total_HP;
            s.stats=obj.stats;
            if(opts.preload_buffs)
                s.autocrit_charges=1;
            end
            if(opts.use_armor_debuff)
                s.raid_armor_pen=0.2;
            end
            s.use_mean=opts.use_mean;
        end
        function a = RunRotation(obj,rotation)
            a=obj.SetupSimulator();
            a.detailed_stats=0;
            
        end
        
    end
end
