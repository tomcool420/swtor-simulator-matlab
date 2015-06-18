function [ mx,me,v2] = OptimizerOne( base_stats,opts,rotation,rotation_class,rotation_opts,pre_calculate,loops)

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
cHandle = rotation_class;
parfor i=iarr
   val = i*inc;
   cp=base_stats;
   cp.(var)=cp.(var)+val;
   cp.(dep)=cp.(dep)-val;
   fprintf('Calculating for (%s:%.0f and %s:%0.f)\n',var,cp.(var),dep,cp.(dep));
   stats=Simulator.StatCalculator(cp);
   %[~,~,dmg]=fHandle(rotation,100,1,stats);
   %[~,dps]=fHandle(rotation,1500,1,stats);
   
   ropts=rotation_opts;
   %fprintf('Calculating for (%s:%.0f and %s:%0.f)\n',var1,cp.(var1),dep,cp.(dep));
   stats=Simulator.StatCalculator(cp);
   a=rotation_class(ropts);
   a.stats=stats;
   if(pre_calculate)
       [~,~,dmg]=a.RunLoops(100,rotation);  %rotation_func(rotation,100,1,stats);
       ropts.total_HP=mean(dmg);
       a.options=ropts;
   end
   
   [~,dps]=a.RunLoops(loops,rotation);
        
   mx(i)=max(dps);
   me(i)=mean(dps);
   v2(i)=cp.(var);
end
    

end

%[mx,me,v2]=Simulator.OptimizerOne(json.loadjson('gear/Luna_base_6pc.json'),'critical_rating','power',0,500,20,shraps,func);