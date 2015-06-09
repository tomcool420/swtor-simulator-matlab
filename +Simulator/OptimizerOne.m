function [ mx,me,v2] = OptimizerOne( base_stats,opts,rotation,rotation_func)

%lin = (var_one_min:var_one_step:var_one_max)-var_one_min;
iarr= 1:round((opts.var_max-opts.var_min)/opts.var_inc);
diff=base_stats.(opts.var)-opts.var_min;
base_stats.(opts.var)=base_stats.(opts.var)-diff;
base_stats.(opts.dependent)=base_stats.(opts.dependent)+diff;
mx=zeros(size(iarr));
me=zeros(size(iarr));
v2=zeros(size(iarr));
j=1;
inc = opts.var_inc;
var = opts.var;
dep = opts.dependent;

parfor i=iarr
   val = i*inc;
   cp=base_stats;
   cp.(var)=cp.(var)+val;
   cp.(dep)=cp.(dep)-val;
   fprintf('Calculating for (%s:%.0f and %s:%0.f)\n',var,cp.(var),dep,cp.(dep));
   stats=Simulator.StatCalculator(cp);
   [~,~,dmg]=rotation_func(rotation,100,1,stats);
   [~,dps]=rotation_func(rotation,1000,1,stats,mean(dmg));
   mx(i)=max(dps);
   me(i)=mean(dps);
   v2(i)=cp.(var);
end
    

end

%[mx,me,v2]=Simulator.OptimizerOne(json.loadjson('gear/Luna_base_6pc.json'),'critical_rating','power',0,500,20,shraps,func);