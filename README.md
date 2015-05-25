# swtor-simulator-matlab
matlab simulator for swtor (was feeling lazy)

#Introduction
This is a simulator for [SWTOR](http://www.swtor.com). It is in the early stages of development so don't expect much to work yet.
It was written in MATLAB because I was feeling too lazy to do it in C. That being said, if i can get all the logic to work i might rewrite it in something faster.

#More details
Currently only Virulence and Dirty Fighting have been implemented with full Dot/relic/adrenal/misc buffs support
Cooldowns (except for Laze Target/Smuggler's Luck) have not been implemented yet because my first goal was grabbing a rotation from parsely and pluggin it in the code
As far as i can tell, it reproduces the results pretty accurately 

#Usage
It's not very user friendly right now BUT 2 example files have been provided
## Hardcoded rotation
```MATLAB
[a,dps]=Cull2(100,1);
```
Inputs:
 1. the number of dummy kills
 2. 0 for Gunslinger 1 for Sniper
 
Ouputs:
 1. a is the object for the best parse
 2. the DPS for each parse
 
## Imported rotation
```MATLAB
[a,dps]=CullRotation(Luna,100,1);
```
Inputs:
 1. A rotation Cell Array (see below)
 2. the number of dummy kills
 3. 0 for Gunslinger 1 for Sniper
 
Ouputs:
 1. a is the object for the best parse
 2. the DPS for each parse
 

Example Data can be loaded:
The data loaded is from [http://parsely.io/parser/view/30627/6](http://parsely.io/parser/view/30627/6)
```MATLAB
load('luna_2ws_rot.mat')  % Will Create a variable called Luna
```

## Getting Parse Info
###Basic Info
```MATLAB
a.PrintStats()
```

returns basic info
```
STATS: time - 202.224, damage = 1001291.361, DPS = 4951.392, APM =  32.64, Crit = 0.35
```

###Detailed Info
```MATLAB 
a.ParseDetailedStats()
```
returns detailed info
```
STATS: time - 202.224, damage = 1001291.361, DPS = 4951.392, APM =  32.64, Crit = 0.35
==============================================================================================================
Ability                 #        d         n     nd        avg n    c    cd           cc       avg c       %
==============================================================================================================
| Vital_Shot          : 174      204036.2  94    82832.92   881.20  80  121203.30     45.98%   1515.04     20.4
| Shrap_Bomb          : 163      200662.3  102  100249.69   982.84  61  100412.66     37.42%   1646.11     20.0
| Hemorrhaging_Blast  : 196       63159.0  154   43372.94   281.64  42   19786.11     21.43%    471.10      6.3
| Hemorrhaging_Blast_OH: 196        3330.7  99     1905.49    19.25  45    1425.18     22.96%     31.67      0.3
| Wounding_Shots      : 88       174216.7  53    81745.42  1542.37  35   92471.31     39.77%   2642.04     17.4
| Wounding_Shots_OH   : 88        10102.3  41     4375.44   106.72  31    5726.81     35.23%    184.74      1.0
| Dirty_Blast_Int     : 24        77294.2  16    41290.68  2580.67  8    36003.52     33.33%   4500.44      7.7
| Dirty_Blast         : 24        60225.8  16    32993.78  2062.11  8    27232.02     33.33%   3404.00      6.0
| Dirty_Blast_OH      : 23         2564.0  11     1514.15   137.65  4     1049.89     17.39%    262.47      0.3
| Quickdraw           : 21       123373.4  13    60036.96  4618.23  8    63336.48     38.10%   7917.06     12.3
| Quickdraw_OH        : 21         5064.4  13     4092.00   314.77  2      972.44      9.52%    486.22      0.5
| Series_of_Shots     : 28        73829.4  13    24765.19  1905.01  15   49064.18     53.57%   3270.95      7.4
| Series_of_Shots_OH  : 28         3432.8  11     1391.70   126.52  9     2041.08     32.14%    226.79      0.3
==============================================================================================================
```
##Getting a list of the activations
```MATLAB
a.PrintActivations
```

```
[  0.00] Laze Target              
[  0.00] Vital Shot               
[  1.48] Shrap Bomb               
[  2.95] Hemorrhaging Blast       
[  4.43] Wounding Shots           
[  7.58] Dirty Blast              
[  9.06] Dirty Blast              
[ 10.53] Dirty Blast              
...
```
##Getting a list of all damaging effects
```MATLAB
a.PrintDamage()
```
will give something like
```
...
[ 11.81] Hemorrhaging Blast OH    : 0DMG
[ 11.81] Vital Shot               : 855DMG
[ 12.01] Hemorrhaging Blast       : 282DMG
[ 12.01] Hemorrhaging Blast OH    : 0DMG
[ 12.01] Dirty Blast Int          : 2411DMG
[ 12.01] Dirty Blast              : 2034DMG
[ 12.01] Dirty Blast OH           : 0DMG
[ 12.01] Quickdraw                : 4998DMG
[ 12.01] Quickdraw OH             : 313DMG
[ 13.29] Shrap Bomb               : 939DMG
[ 13.49] Wounding Shots           : 1699DMG
...
```
#Ability JSON File
the JSON Ability file has all the abilities likes this 
```JSON
		"ls_w": {
			"c": 0.988,
			"Sm": 0.099,
			"Sx": 0.099,
			"Sh": 3185,
			"Am": -0.34,
			"w": 1,
			"mult": 1.1,
			"cb": 0,
			"sb": 0,
			"s30": 0,
			"ctype": 2,
			"ct": 1.5,
			"base_acc": 1,
			"raid_mult": 1.05,
			"name": "Dirty Blast",
			"callback": "LSCallback",
			"id": "lethalweap",
			"dmg_type": 1,
			"hits": 1,
			"ticks": 1
		}
```

* c is the coefficient
* Sm = Standard Health Min
* Sx = Standard Health Max
* Sh = basically a constant 3185 now
* Am = AmountModifier
* w = is it white damage
* mult = multiplier based on passives in skill tree AND class passives
* cb = crit boost from class/spec 0.2=20%
* sb = surge boost from class/spec 0.2 = 20%
* s30 = sub 30% damage boost
* ctype = ability type 
      * 0 is an OFF CGD Instant (second hit of dirty blast) 
      * 1 is an Instant Cast (Quickdraw)
      * 2 is a Cast Ability  (Dirty Blast)
      * 3 is a Channeled Ability (Speed Shot / Wounding Shots)
      * 4 is a Dot
* ct = cast time
* base_acc = 1 for all move, 0.9 for free attacks
* raid_mult = multiplier from raid buffs
* name = Just a Pretty Name
* callback = callback function special usages (giving DB a second hit, having Cull proc dots)
* dmg_type = 
      1 energy
      2 kinetic
      3 internal
      4 elemental
* hits = number of unique hits per ability usage (2 for double strike, 3 for saber strike)
* ticks= number of hits the damage is divided by (7 for hammer shot). if ticks is present but hits isn't, hits= ticks

#TODO:
*[X]Add Ability Cooldown support
*[ ]Add Energy support
*[ ]Add Other Classes

