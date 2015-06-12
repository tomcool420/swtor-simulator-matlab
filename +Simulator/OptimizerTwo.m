function [ mx,me,vx,vy] = OptimizerTwo( base_stats,opts1,opts2,rotation,rotation_func)

%lin = (var_one_min:var_one_step:var_one_max)-var_one_min;
iarr1= 1:round((opts1.var_max-opts1.var_min)/opts1.var_inc);
iarr2= 1:round((opts2.var_max-opts2.var_min)/opts2.var_inc);
diff=base_stats.(opts1.var)-opts1.var_min;
base_stats.(opts1.var)=base_stats.(opts1.var)-diff;
base_stats.(opts1.dependent)=base_stats.(opts1.dependent)+diff;
diff2=base_stats.(opts2.var)-opts2.var_min;
base_stats.(opts2.var)=base_stats.(opts2.var)-diff2;
base_stats.(opts2.dependent)=base_stats.(opts2.dependent)+diff2;
mx=zeros([numel(iarr1) numel(iarr2)]);
me=zeros([numel(iarr1) numel(iarr2)]);
vx=zeros([numel(iarr1) numel(iarr2)]);
vy=zeros([numel(iarr1) numel(iarr2)]);
j=1;
inc1 = opts1.var_inc;
var1 = opts1.var;
dep1 = opts1.dependent;
inc2 = opts2.var_inc;
var2 = opts2.var;
dep2 = opts2.dependent;
l=0;
for i=iarr1
    l=printclean(l,'%.0f/%.0f\n',i,max(iarr1));
    parfor j=iarr2
        val1 = i*inc1;
        cp=base_stats;
        cp.(var1)=cp.(var1)+val1;
        cp.(dep1)=cp.(dep1)-val1;
        val2 = j*inc2;
        cp.(var2)=cp.(var2)+val2;
        cp.(dep2)=cp.(dep2)-val2;
        %fprintf('Calculating for (%s:%.0f and %s:%0.f)\n',var1,cp.(var1),dep,cp.(dep));
        stats=Simulator.StatCalculator(cp);
        [~,~,dmg]=rotation_func(rotation,100,1,stats);
        [~,dps]=rotation_func(rotation,1500,1,stats,mean(dmg));
        mx(i,j)=max(dps);
        me(i,j)=mean(dps);
        vx(i,j)=cp.(var1);
        vy(i,j)=cp.(var2);
    end
    
end
    

end
function l = printclean(length,varargin)
    fprintf(1, repmat('\b',1,length));
    l=fprintf(varargin{:});
end
%[mx,me,v2]=Simulator.OptimizerOne(json.loadjson('gear/Luna_base_6pc.json'),'critical_rating','power',0,500,20,shraps,func);