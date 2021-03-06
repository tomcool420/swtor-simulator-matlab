function infiltration()
sht=struct('c',0.450,'Sm',0.045,'Sx',0.045,'Am',0.000,'Sh',3185,...
    'w',0,'long_id','abl.jedi_consular.skill.infiltration.shadow_technique','id','shadow_technique','name','Shadow Technique',...
    'cb',0.0,'sb',0.0,'s30',0.05,'dmg_type',4,'base_acc',1.0,'raid_mult',1.0,...
    'ctype',1,'ct',0.0,'mult',1.0,'CD',1.500000,...
    'raidAOE',0,'raidIE',1,'raidKEFT',1);
psy=struct('c',2.060,'Sm',0.186,'Sx',0.226,'Am',0.000,'Sh',3185,...
    'w',0,'long_id','abl.jedi_consular.skill.infiltration.psychokinetic_blast','id','psychokinetic_blast','name','Psychokinetic Blast',...
    'cb',0.0,'sb',0.3,'s30',0.05,'dmg_type',1,'base_acc',1.0,'raid_mult',1.0,...
    'ctype',1,'ct',0.0,'mult',1.0,'CD',6.000000,...
    'raidAOE',0,'raidIE',0,'raidKEFT',1,'callback','PSYCallback');
psyu=struct('c',2.060,'Sm',0.186,'Sx',0.226,'Am',0.000,'Sh',3185,...
    'w',0,'long_id','abl.jedi_consular.skill.infiltration.psychokinetic_blast','id','psychokinetic_blast_upheaval','name','PB Upheaval',...
    'cb',0.0,'sb',0.3,'s30',0.05,'dmg_type',1,'base_acc',1.0,'raid_mult',1.0,...
    'ctype',0,'ct',0.0,'mult',1.0,'CD',6.000000,'divider',2,...
    'raidAOE',0,'raidIE',0,'raidKEFT',1);
cla=struct('c',0.810,'Sm',0.081,'Sx',0.081,'Am',-0.460,'Sh',3185,...
    'w',1,'long_id','abl.jedi_consular.skill.infiltration.clairvoyant_strike','id','clairvoyant_strike','name','Clairvoyant Strike',...
    'cb',0.0,'sb',0.0,'s30',0.05,'dmg_type',1,'base_acc',1.0,'raid_mult',1.0,...
    'ctype',1,'ct',0.0,'mult',1.15,'CD',0.000000,'hits',2,...
    'raidAOE',0,'raidIE',0,'raidKEFT',1);
ss=struct('c',0.330,'Sm',0.000,'Sx',0.000,'Am',-0.660,'Sh',3185,...
    'w',1,'long_id','abl.flurry.jedi_consular.saber_strike_optimize','id','saber_strike_optimize','name','Saber Strike',...
    'cb',0.0,'sb',0.0,'s30',0.05,'dmg_type',1,'base_acc',0.9,'raid_mult',1.0,...
    'ctype',1,'ct',0.0,'mult',1.0,'CD',0.000000,'hits',3,...
    'raidAOE',0,'raidIE',0,'raidKEFT',1);
shs=struct('c',2.310,'Sm',0.231,'Sx',0.231,'Am',0.540,'Sh',3185,...
    'w',1,'long_id','abl.jedi_consular.shadow_strike','id','shadow_strike','name','Shadow Strike',...
    'cb',0.0,'sb',0.3,'s30',0.05,'dmg_type',1,'base_acc',1.0,'raid_mult',1.0,...
    'ctype',1,'ct',0.0,'mult',1.0,'CD',0.000000,...
    'raidAOE',0,'raidIE',0,'raidKEFT',1);
sps=struct('c',2.657,'Sm',0.266,'Sx',0.266,'Am',0.770,'Sh',3185,...
    'w',1,'long_id','abl.jedi_consular.spinning_strike','id','spinning_strike','name','Spinning Strike',...
    'cb',0.0,'sb',0.0,'s30',0.05,'dmg_type',1,'base_acc',1.0,'raid_mult',1.0,...
    'ctype',1,'ct',0.0,'mult',1.1,'CD',6.000000,...
    'raidAOE',0,'raidIE',0,'raidKEFT',1);
fb=struct('c',0.730,'Sm',0.053,'Sx',0.093,'Am',0.000,'Sh',3185,...
         'w',0,'long_id','abl.jedi_consular.force_breach','id','force_breach','name','Force Breach',...
         'cb',0.0,'sb',0.3,'s30',0.05,'dmg_type',4,'base_acc',1.0,'raid_mult',1.0,...
         'ctype',1,'ct',0.0,'mult',1.0,'CD',0.000000,...
         'raidAOE',0,'raidIE',1,'raidKEFT',1);
abilities=struct('sht',sht,'psy',psy,'psyu',psyu,'cls',cla,'ss',ss,'shs',shs,'sps',sps,'fb',fb);

dots=struct();
buffs=struct('BR',struct('LastUsed',-1,'Available',0,'Dur',15,'CD',120),...
             'AD',struct('LastUsed',-1,'Available',0,'Dur',15),...
             'BARelic',struct('LastUsed',-1,'Available',0,'Dur',30),...
             'FP',struct('LastUsed',-1,'Available',0,'Dur',20,'CD',90,'Charges',0),...
             'BS',struct('LastUsed',-1,'Available',-1,'Dur',15,'Charges',0));
procs=struct('FR',struct('LastProc',-1,'Dur',6,'CD',20),...
             'SA',struct('LastProc',-1,'Dur',6,'CD',20),...
             'PC2',struct('LastProc',-1,'Dur',15,'CD',30,'Available',0),...             %Stakler set bonus
             'FS',struct('LastProc',-1,'Dur',10,'CD',0),...                             %Force Synergy
             'ST',struct('LastProc',-1,'Dur',15,'CD',6,'Available',0.0),...             %Shadow Technique
             'IT',struct('LastProc',-1,'Dur',15,'CD',10,'Available',0),...               %Infiltration Tactics
             'CS',struct('LastProc',-1,'Dur',15,'CD',1.5,'Available',0,'Charges',0),...             %Clairvoyance
             'ShT',struct('LastProc',-1,'Dur',0,'CD',1.5,'Available',0));               %Shadow Technique proc
z=struct();
z.abilities=abilities;
z.dots=dots;
z.buffs=buffs;
z.procs=procs;
json.savejson('',z,'json/Infiltration.json');
end