function [ mx,me,vx,vy,stdev] = OptimizerTwo( base_stats,opts1,opts2,rotation,rotation_class,rotation_opts,pre_calculate,loops)

%lin = (var_one_min:var_one_step:var_one_max)-var_one_min;
iarr1= 1:(round((opts1.var_max-opts1.var_min)/opts1.var_inc)+1);
iarr2= 1:(round((opts2.var_max-opts2.var_min)/opts2.var_inc)+1);
diff=base_stats.(opts1.var)-opts1.var_min;
base_stats.(opts1.var)=base_stats.(opts1.var)-diff;
base_stats.(opts1.dependent)=base_stats.(opts1.dependent)+diff;
diff2=base_stats.(opts2.var)-opts2.var_min;
base_stats.(opts2.var)=base_stats.(opts2.var)-diff2;
base_stats.(opts2.dependent)=base_stats.(opts2.dependent)+diff2;
n1=numel(iarr1);
n2=numel(iarr2);
sz=[n1*n2 1];
mx=zeros(sz);
me=zeros(sz);
vx=zeros(sz);
vy=zeros(sz);
stdev=zeros(sz);
j=1;
inc1 = opts1.var_inc;
var1 = opts1.var;
dep1 = opts1.dependent;
inc2 = opts2.var_inc;
var2 = opts2.var;
dep2 = opts2.dependent;
l=0;
s=tic;
p = TimedProgressBar( n1*n2, 30, ...
                     'Computing, please wait for ', ...
                     ', already completed ', ...
                     'Concluded in ' );


parfor tl=1:n1*n2
    %l=printclean(l,'%.0f/%.0f\n',i,max(iarr1));
    %fprintf('\n%.2f %.0f/%.0f\n',toc(s),i,max(iarr1)
    [i,j]=ind2sub([n1 n2],tl);
    val1 = (i-1)*inc1;
    cp=base_stats;
    cp.(var1)=cp.(var1)+val1;
    cp.(dep1)=cp.(dep1)-val1;
    val2 = (j-1)*inc2;
    cp.(var2)=cp.(var2)+val2;
    cp.(dep2)=cp.(dep2)-val2;
    ropts=rotation_opts;
    
    stats=Simulator.StatCalculator(cp);
    a=rotation_class(ropts);
    a.stats=stats;
    if(pre_calculate)
        [~,~,dmg]=a.RunLoops(100,rotation);  
        ropts.total_HP=mean(dmg);
        a.options=ropts;
    end
    [~,dps]=a.RunLoops(loops,rotation);
    mx(tl)=max(dps);
    me(tl)=mean(dps);
    vx(tl)=cp.(var1);
    vy(tl)=cp.(var2);
    stdev(tl)=std(dps);
    p.progress;
end
p.stop;
mx=reshape(mx,[n1 n2]);
me=reshape(me,[n1 n2]);
vx=reshape(vx,[n1 n2]);
vy=reshape(vy,[n1 n2]);
stdev=reshape(stdev,[n1 n2]);

end
function l = printclean(length,varargin)
fprintf(1, repmat('\b',1,length));
l=fprintf(varargin{:});
end
%[mx,me,v2]=Simulator.OptimizerOne(json.loadjson('gear/Luna_base_6pc.json'),'critical_rating','power',0,500,20,shraps,func);