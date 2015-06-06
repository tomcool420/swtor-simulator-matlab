function [ stats ] = StatCalculator( base_stats)
%STATCALCULATOR Summary of this function goes here
%   Detailed explanation goes here
mstat='aim';
a=base_stats.aim;
c=base_stats.cunning;
s=base_stats.strength;
w=base_stats.willpower;
mx=base_stats.aim;
if(c>mx)
    mstat='cunning';
    mx=c;
end
if(s>mx)
    mstat='strength';
    mx=s;
end
if(w>mx)
    mstat='willpower';
    mx=w;
end
%fprintf('Main Stat is %s\n',mstat);
if(~isfield(base_stats,'force_power'))
    base_stats.force_power=0;
end
if(~isfield(base_stats,'tech_power'))
    base_stats.tech_power=0;
end
if(~isfield(base_stats,'alacrity_rating'))
    fprintf('No Alacrity Rating Defined\n');
   base_stats.alacrity_rating=0; 
end
if(~isfield(base_stats,'critical_rating'))
    fprintf('No Critical Rating Defined\n');
   base_stats.critical_rating=0; 
end
if(~isfield(base_stats,'surge_rating'))
    fprintf('No Surge Rating Defined\n');
   base_stats.surge_rating=0; 
end
if(~isfield(base_stats,'surge_rating'))
    fprintf('No Surge Rating Defined\n');
   base_stats.surge_rating=0; 
end
if(~isfield(base_stats,'alacrity_buffs'))
   base_stats.alacrity_buffs=0; 
end
if(~isfield(base_stats,'critical_buffs'))
   base_stats.critical_buffs=0.06; 
end
if(~isfield(base_stats,'surge_buffs'))
   base_stats.surge_buffs=0.01; 
end
ms=0;
if(strcmpi(mstat,'aim'))
   ms=base_stats.aim; 
elseif(strcmpi(mstat,'cunning'))
   ms=base_stats.cunning;
elseif(strcmpi(mstat,'willpower'))
   ms=base_stats.willpower;
elseif(strcmpi(mstat,'strength'))
   ms=base_stats.strength;
end
bs = base_stats;
tech_bonus = (bs.power*0.23+bs.tech_power*0.23+bs.cunning*0.2)*1.05;
range_bonus= (bs.power*0.23+bs.aim*0.2)*1.05;
melee_bonus= (bs.power*0.23+bs.strength*0.2)*1.05;
force_bonus= (bs.power*0.23+bs.force_power*0.23+bs.willpower*0.2)*1.05;

crit_rating_crit = 30 * ( 1 - ( 1 - ( 0.01 / 0.3 ) )^( (bs.critical_rating  / 60 ) / 0.9 ) )/100;
aim_crit = 20 * ( 1 - ( 1 - ( 0.01 / 0.2 ) )^( (bs.aim  / 60 ) / 5.5 ) )/100;
strength_crit = 20 * ( 1 - ( 1 - ( 0.01 / 0.2 ) )^( (bs.strength  / 60 ) / 5.5 ) )/100;
cunning_crit = 20 * ( 1 - ( 1 - ( 0.01 / 0.2 ) )^( (bs.cunning  / 60 ) / 5.5 ) )/100;
willpower_crit = 20 * ( 1 - ( 1 - ( 0.01 / 0.2 ) )^( (bs.willpower  / 60 ) / 5.5 ) )/100;
range_crit = 0; force_crit = 0; melee_crit = 0; tech_crit = 0;
if(strcmpi(mstat,'aim'))
    tech_bonus = tech_bonus+bs.aim*0.2*1.05;
    range_crit= crit_rating_crit + 0.05 + bs.critical_buffs+ aim_crit;
    tech_crit = range_crit+cunning_crit;
elseif(strcmpi(mstat,'cunning'))
    range_bonus = range_bonus + bs.cunning*0.2*1.05;
    tech_crit= crit_rating_crit + 0.05 + bs.critical_buffs+ cunning_crit;
    range_crit = tech_crit+aim_crit;
elseif(strcmpi(mstat,'strength'))
    force_bonus = force_bonus + bs.strength*0.2*1.05;
    melee_crit = crit_rating_crit + 0.05 + bs.critical_buffs +strength_crit;
    force_crit = melee_crit + willpower_crit;
elseif(strcmpi(mstat,'willpower'))
    melee_bonus = melee_bonus + bs.willpower*0.2*1.05;
    force_crit = crit_rating_crit + 0.05 + bs.critical_buffs +willpower_crit;
    melee_crit = force_crit + strength_crit;
end

alacrity = bs.alacrity_buffs+ 30*(1-(1-(0.01/0.3))^((bs.alacrity_rating/60)/1.25))/100;
surge = 0.5+bs.surge_buffs+30*(1 - ( 1 - ( 0.01 / 0.3 ) )^( ( bs.surge_rating/ 60) / 0.22 ) )/100;

stats= base_stats;
stats.Alacrity = alacrity;
stats.Surge = surge;
stats.TechBonus = tech_bonus;
stats.RangedBonus = range_bonus;
stats.MeleeBonus = melee_bonus;
stats.ForceBonus = force_bonus;
stats.RangedCrit = range_crit;
stats.TechCrit = tech_crit;
stats.ForceCrit = force_crit;
stats.MeleeCrit = melee_crit;

stats.WeaponCrit = max(melee_crit,range_crit);
stats.SecondCrit = max(tech_crit,force_crit);
stats.WeaponBonus= max(range_bonus,melee_bonus);
stats.SecondBonus= max(tech_bonus,force_bonus);
end

