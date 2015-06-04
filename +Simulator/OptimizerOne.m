function [ mx,me] = OptimizerOne( base_stats,var_one,var_two,var_one_min,var_one_max,var_one_step,rotation,rotation_func)

lin = (var_one_min:var_one_step:var_one_max)-var_one_min;
diff=base_stats.(var_one)-var_one_min;
base_stats.(var_one)=base_stats.(var_one)-diff;
base_stats.(var_two)=base_stats.(var_two)+diff;
mx=zeros(size(lin));
me=zeros(size(lin));
j=1;
for i=lin
   cp=base_stats;
   cp.(var_one)=cp.(var_one)+i;
   cp.(var_two)=cp.(var_two)-i;
   fprintf('Calculating for (%s:%.0f and %s:%0.f)\n',var_one,cp.(var_one),var_two,cp.(var_two));
   stats=Simulator.StatCalculator(cp);
   [~,dps]=rotation_func(rotation,500,1,stats);
   mx(j)=max(dps);
   me(j)=mean(dps);
end
    

end

