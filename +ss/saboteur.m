sabo=struct('c',2.720,'Sm',0.252,'Sx',0.292,'Am',0.000,'Sh',3185,...
         'w',0,'long_id','abl.smuggler.skill.saboteur.sabotage_charge','id','sabotage_charge','name','Sabotage Charge',...
         'cb',0.0,'sb',0.3,'s30',0.,'dmg_type',1,'base_acc',1.0,'raid_mult',1.0,...
         'ctype',1,'ct',0.0,'mult',1.15,'CD',18.000000,'Charges',1,...
         'raidAOE',0,'raidIE',0,'raidKEFT',1);
sho=struct('c',0.400,'Sm',0.040,'Sx',0.040,'Am',0.000,'Sh',3185,...
         'w',0,'long_id','abl.smuggler.skill.saboteur.shock_charge','id','shock_charge','name','Shock Charge',...
         'cb',0.0,'sb',0.3,'s30',0.,'dmg_type',2,'base_acc',1.0,'raid_mult',1.0,...
         'ctype',4,'ct',0.0,'mult',1.0,'CD',0.000000,'int',2,'dur',18,...
         'raidAOE',0,'raidIE',0,'raidKEFT',1);
sab=struct('c',2.270,'Sm',0.207,'Sx',0.247,'Am',0.000,'Sh',3185,...
         'w',0,'long_id','abl.smuggler.skill.saboteur.sabotage','id','sabotage','name','Sabotage',...
         'cb',0.0,'sb',0.3,'s30',0.,'dmg_type',2,'base_acc',1.0,'raid_mult',1.0,...
         'ctype',1,'ct',0.0,'mult',1.0,'CD',18.000000,...
         'raidAOE',0,'raidIE',0,'raidKEFT',1);
inc=struct('c',0.201,'Sm',0.020,'Sx',0.020,'Am',0.000,'Sh',3185,...
         'w',0,'long_id','abl.smuggler.skill.saboteur.incendiary_grenade','id','incendiary_grenade','name','Incendiary Grenade',...
         'cb',0.0,'sb',0.3,'s30',0.,'dmg_type',3,'base_acc',1.0,'raid_mult',1.0,...
         'ctype',4,'ct',0.0,'mult',1.15,'CD',0.000000,'int',1,'dur',9,...
         'raidAOE',1,'raidIE',1,'raidKEFT',1);
spe=struct('c',0.930,'Sm',0.093,'Sx',0.093,'Am',-0.380,'Sh',3185,...
         'w',1,'long_id','abl.smuggler.speed_shot','id','speed_shot','name','Speed Shot',...
         'cb',0.0,'sb',0.0,'s30',0.0,'dmg_type',1,'base_acc',1.0,'raid_mult',1.0,'ticks',4,...
         'ctype',3,'ct',3.0,'mult',1.05,'CD',9,...
         'raidAOE',0,'raidIE',0,'raidKEFT',1);
vit=struct('c',0.308,'Sm',0.031,'Sx',0.031,'Am',0.000,'Sh',3185,...
         'w',0,'long_id','abl.smuggler.vital_shot','id','vital_shot','name','Vital Shot',...
         'cb',0.0,'sb',0.0,'s30',0.0,'dmg_type',4,'base_acc',1.0,'raid_mult',1.0,...
         'ctype',4,'ct',0.0,'mult',1.0,'CD',0.000000,'int',3,'dur',18,...
         'raidAOE',0,'raidIE',1,'raidKEFT',1);
xs=struct('c',0.700,'Sm',0.070,'Sx',0.070,'Am',0.000,'Sh',3185,...
         'w',0,'long_id','abl.smuggler.xs_freighter_flyby','id','xs_freighter_flyby','name','XS Freighter Flyby',...
         'cb',0.0,'sb',0.3,'s30',0.,'dmg_type',3,'base_acc',1.0,'raid_mult',1.0,...
         'ctype',4,'ct',1.0,'mult',1.15,'CD',30.000000,'int',3,'dur',9,'initial_tick',0,'entersCombat',0,...
         'raidAOE',1,'raidIE',1,'raidKEFT',1);
bla=struct('c',0.050,'Sm',0.005,'Sx',0.005,'Am',0.000,'Sh',3185,...
         'w',0,'long_id','abl.smuggler.skill.saboteur.blazing_speed','id','blazing_speed','name','Blazing Speed',...
         'cb',0.0,'sb',0.0,'s30',0.0,'dmg_type',3,'base_acc',1.0,'raid_mult',1.0,...
         'ctype',-1,'ct',0.0,'mult',1.0,'CD',0.000000,'int',2,'dur',6.00,...
         'raidAOE',0,'raidIE',1,'raidKEFT',1,'Stacks',3);
con=struct('c',0.470,'Sm',0.047,'Sx',0.047,'Am',0.000,'Sh',3185,...
         'w',0,'long_id','abl.smuggler.skill.saboteur.contingency_charges','id','contingency_charges','name','Contingency Charges',...
         'cb',0.0,'sb',0.3,'s30',0.0,'dmg_type',1,'base_acc',1.0,'raid_mult',1.0,...
         'ctype',-1,'ct',0.0,'mult',1.15,'CD',0.000000,'Charges',4,...
         'raidAOE',0,'raidIE',0,'raidKEFT',1);
the=struct('c',1.540,'Sm',0.134,'Sx',0.174,'Am',0.000,'Sh',3185,...
         'w',0,'long_id','abl.smuggler.thermal_grenade','id','thermal_grenade','name','Thermal Grenade',...
         'cb',0.1,'sb',0.0,'s30',0.0,'dmg_type',1,'base_acc',1.0,'raid_mult',1.0,...
         'ctype',1,'ct',0.0,'mult',1.15,'CD',6.000000,...
         'raidAOE',0,'raidIE',0,'raidKEFT',1);
flu=struct('c',1.000,'Sm',0.000,'Sx',0.000,'Am',0.000,'Sh',3185,...
         'w',1,'long_id','abl.smuggler.flurry_of_bolts_optimize','id','flurry_of_bolts_optimize','name','Flurry of Bolts',...
         'cb',0.0,'sb',0.0,'s30',0.0,'dmg_type',1,'base_acc',0.9,'raid_mult',1.0,...
         'ctype',1,'ct',0.0,'mult',1.0,'CD',0.000000,...
         'raidAOE',0,'raidIE',0,'raidKEFT',1);
qui=struct('c',1.390,'Sm',0.139,'Sx',0.139,'Am',-0.070,'Sh',3185,...
         'w',1,'long_id','abl.smuggler.quick_shot','id','quick_shot','name','Quick Shot',...
         'cb',0.0,'sb',0.0,'s30',0.0,'dmg_type',1,'base_acc',1.0,'raid_mult',1.0,...
         'ctype',1,'ct',0.0,'mult',1.0,'CD',0.000000,...
         'raidAOE',0,'raidIE',0,'raidKEFT',1);    
qd=struct('c',2.510,'Sm',0.251,'Sx',0.251,'Am',0.670,'Sh',3185,...
         'w',1,'long_id','abl.smuggler.quickdraw','id','quickdraw','name','Quickdraw',...
         'cb',0.0,'sb',0.0,'s30',0.0,'dmg_type',1,'base_acc',1.0,'raid_mult',1.0,...
         'ctype',1,'ct',0.0,'mult',1.0,'CD',12.000000,...
         'raidAOE',0,'raidIE',0,'raidKEFT',1);
abilities=struct('the',the,'con',con,'bla',bla,'xs',xs,'vit',vit,'spe',spe,'inc',inc,'sab',sab,'sho',sho,'sabo',sabo,'flu',flu,'qui',qui,'qd',qd);     
dots=struct('CD',struct('LastUsed',-1,'NextTick',-1,...     %Vital Shot
                         'Expire',-1,'WExpire',-1,...
                         'Ala',1.0,'it','vit'),...
            'XS',struct('LastUsed',-1,'NextTick',-1,...     %XS Freighter Flyby
                         'Expire',-1,'WExpire',-1,...
                         'Ala',1.0,'it','xs'),...
            'IG',struct('LastUsed',-1,'NextTick',-1,...     %Icendiary Grenade
                         'Expire',-1,'WExpire',-1,...
                         'Ala',1.0,'it','inc'),...
            'SC',struct('LastUsed',-1,'NextTick',-1,...     %Shock Charge
                         'Expire',-1,'WExpire',-1,...
                         'Ala',1.0,'it','sho'),...
            'BS',struct('LastUsed',-1,'NextTick',-1,...
                         'Expire',-1,'WExpire',-1,...
                         'Ala',1.0,'it','bla','Stacks',0));
buffs=struct('TA',struct('LastUsed',-1,'Available',0,'Dur',10),...
             'LT',struct('LastUsed',-1,'Available',0,'Dur',20),...
             'AD',struct('LastUsed',-1,'Available',0,'Dur',15),...
             'BARelic',struct('LastUsed',-1,'Available',0,'Dur',30),...
             'SV',struct('LastUsed',-1,'Available',0,'Dur',15));
debuffs=struct('SC',struct('LastApplied',-1,'Dur',20,'Charges',0),...
               'CC',struct('LastApplied',-1,'Dur',20,'Charges',0));
procs=struct('FR',struct('LastProc',-1,'Dur',6,'CD',20),...
             'SA',struct('LastProc',-1,'Dur',6,'CD',20),...
             'PC2',struct('LastProc',-1,'Dur',15,'CD',30,'Available',0),...
             'CC',struct('LastProc',-1,'Dur',15,'CD',30,'Available',0,'Charges',0));
         
z=struct('abilities',abilities,'dots',dots,'buffs',buffs,'procs',procs,'debuffs',debuffs);
json.savejson('',z,'json/Saboteur.json');