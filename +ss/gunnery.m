function [  ] = gunnery(  )
%GUNNERY Summary of this function goes here
%   Detailed explanation goes here
gra=struct('c',1.502,'Sm',0.130,'Sx',0.170,'Am',0.000,'Sh',3185,...
         'w',0,'long_id','abl.trooper.skill.gunnery.grav_round','id','grav_round','name','Grav Round',...
         'cb',0.0,'sb',0.0,'s30',0.0,'dmg_type',1,'base_acc',1.0,'raid_mult',1.0,...
         'ctype',2,'ct',1.5,'mult',1.0,'CD',0.000000,...
         'raidAOE',0,'raidIE',0,'raidKEFT',1);
dem=struct('c',2.220,'Sm',0.202,'Sx',0.242,'Am',0.000,'Sh',3185,...
         'w',0,'long_id','abl.trooper.skill.gunnery.demolition_round','id','demolition_round','name','Demolition Round',...
         'cb',0.0,'sb',0.0,'s30',0.0,'dmg_type',1,'base_acc',1.0,'raid_mult',1.0,...
         'ctype',1,'ct',0.0,'mult',1.0,'CD',15.000000,...
         'raidAOE',0,'raidIE',0,'raidKEFT',1);
vor=struct('c',2.020,'Sm',0.202,'Sx',0.202,'Am',0.340,'Sh',3185,...
         'w',1,'long_id','abl.trooper.skill.gunnery.vortex_bolt','id','vortex_bolt','name','Vortex Bolt',...
         'cb',0.0,'sb',0.0,'s30',0.0,'dmg_type',1,'base_acc',1.0,'raid_mult',1.0,...
         'ctype',0,'ct',0.0,'mult',1.0,'CD',18.000000,...
         'raidAOE',0,'raidIE',0,'raidKEFT',1);
hig=struct('c',1.970,'Sm',0.197,'Sx',0.197,'Am',0.310,'Sh',3185,...
         'w',1,'long_id','abl.trooper.high_impact_round','id','high_impact_round','name','High Impact Bolt',...
         'cb',0.0,'sb',0.0,'s30',0.0,'dmg_type',1,'base_acc',1.0,'raid_mult',1.0,...
         'ctype',1,'ct',0.0,'mult',1.0,'CD',15.000000,...
         'raidAOE',0,'raidIE',0,'raidKEFT',1); 
ful=struct('c',1.048,'Sm',0.105,'Sx',0.105,'Am',-0.300,'Sh',3185,...
         'w',1,'long_id','abl.trooper.full_auto','id','full_auto','name','Full Auto',...
         'cb',0.0,'sb',0.0,'s30',0.0,'dmg_type',1,'base_acc',1.0,'raid_mult',1.0,...
         'ctype',3,'ct',3.0,'mult',1.0,'CD',15.000000,'ticks',4,...
         'raidAOE',0,'raidIE',0,'raidKEFT',1);
ele=struct('c',0.290,'Sm',0.029,'Sx',0.029,'Am',0.000,'Sh',3185,...
         'w',0,'long_id','abl.trooper.electro_net','id','electro_net','name','Electro Net',...
         'cb',0.0,'sb',0.0,'s30',0.0,'dmg_type',2,'base_acc',1.0,'raid_mult',1.0,...
         'ctype',4,'ct',0.0,'mult',1.0,'CD',90.000000,...
         'raidAOE',0,'raidIE',0,'raidKEFT',1);
ham=struct('c',1.000,'Sm',0.000,'Sx',0.000,'Am',0.000,'Sh',3185,...
         'w',1,'long_id','abl.trooper.hammer_shot','id','hammer_shot','name','Hammer Shot',...
         'cb',0.0,'sb',0.0,'s30',0.0,'dmg_type',1,'base_acc',0.9,'raid_mult',1.0,...
         'ctype',1,'ct',0.0,'mult',1.0,'CD',0.000000,'hits',4,...
         'raidAOE',0,'raidIE',0,'raidKEFT',1);
abilities=struct('gra',gra,'dem',dem,'ful',ful,'ham',ham,'ele',ele,'vor',vor,'hig',hig);
dots=struct('EN',struct('LastUsed',-1,'NextTick',-1,...
                         'Expire',-1,'WExpire',-1,...
                         'Ala',1.0,'it','cd'));
buffs=struct('TA',struct('LastUsed',-1,'Available',0,'Dur',10),...
             'LT',struct('LastUsed',-1,'Available',0,'Dur',20),...
             'AD',struct('LastUsed',-1,'Available',0,'Dur',15),...
             'BARelic',struct('LastUsed',-1,'Available',0,'Dur',30),...
             'WB',struct('LastUsed',-1,'Available',0,'Dur',10));
procs=struct('FR',struct('LastProc',-1,'Dur',6,'CD',20),...
             'SA',struct('LastProc',-1,'Dur',6,'CD',20),...
             'PC2',struct('LastProc',-1,'Dur',15,'CD',30,'Available',0));
z=struct('abilities',abilities,'dots',dots,'buffs',buffs,'procs',procs);
json.savejson('',z,'json/Gunnery.json');

end

