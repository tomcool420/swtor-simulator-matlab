#Plasmatech Rotation Simulation
Using the parse and gear provided by Kwerty, The following attempts were made at 1) reproducing the results and 2) predicting future results
Each combination was run 2500 times to provide nice statistics. For each of the tables, 
```
#     number of hits for an ability
d     total damage
n     non crit hits
nd    normal damage
avg n average normal hit
c     number of crits
cd    total critical damage
cc    crit percentage
avg c average crit
%     percentage of total damage
```
Since tactics does NOT have a sub 30% boost, letting the parse run past the end of the dummy HP is fine.
##Kwerty NO Relic/Adrenal APM Free - Mean Result
Grabbing the rotation straight from Parsely, and then plugging it into the code, we obtain a mean of 4621.4 DPS with a standard deviation of 73.7. 
That means that around 68% of the parses would be between 4545.7 and 4697.1.
This result would be very difficult to replicate as it is near impossible to have no ability delay. That being said, in the future, when testing rotations, this is probably the best way to compare them.
As a sanity check: 125 cast on the GCD +48s of Pulse Cannon, factoring in 8.33% alacrity (125*1.5 + 16*3)/(1+0.0833)=217.3913s

![No Relic, No adrenal](https://raw.githubusercontent.com/tomcool420/swtor-simulator-matlab/master/Simulations%20Results/Plasmatech_NoDelay_NoRelics_Adrenal.png)
```
STATS: time - 217.391, damage = 1001432.902, DPS = 4606.591, APM =  43.06, Crit = 0.35
===============================================================================================================
| Ability               #        d         n     nd        avg n    c    cd           cc       avg c       %
===============================================================================================================
| Pulse Cannon        : 64       212406.5  39    93001.60  2384.66  25  119404.89     39.06%   4776.20     21.2
| Plasmatize          : 84       107743.3  56    54485.95   972.96  28   53257.36     33.33%   1902.05     10.8
| High Implact Bolt   : 16       106684.4  0         0.00      NaN  16  106684.44    100.00%   6667.78     10.7
| Shockstrike         : 24       106118.3  16    53260.28  3328.77  8    52857.97     33.33%   6607.25     10.6
| Ion Pulse           : 29        99210.1  19    53218.33  2800.96  10   45991.80     34.48%   4599.18      9.9
| Plasma Cell         : 123       92205.0  72    42122.61   585.04  51   50082.39     41.46%    982.01      9.2
| Fire Pulse          : 15        90264.6  10    45561.04  4556.10  5    44703.60     33.33%   8940.72      9.0
| Incendiary Round DOT: 73        79049.2  50    44529.79   890.60  23   34519.46     31.51%   1500.85      7.9
| Shockstrike ele     : 24        36073.8  18    21787.03  1210.39  6    14286.73     25.00%   2381.12      3.6
| Hammer Shot         : 119       33067.6  91    21696.64   238.42  28   11371.00     23.53%    406.11      3.3
| Incendiary Round    : 16        21661.0  10    11011.71  1101.17  6    10649.25     37.50%   1774.87      2.2
| Shoulder Cannon     : 8         16949.0  5      8549.31  1709.86  3     8399.73     37.50%   2799.91      1.7
===============================================================================================================
```

##Kwerty NO Relic/Adrenal 
Doing that gives us an average of 4480.37 with a standard deviation of 75.3714

![No Relic, No adrenal](https://raw.githubusercontent.com/tomcool420/swtor-simulator-matlab/master/Simulations%20Results/Plasmatech_Delay_NoRelics_Adrenal.png)


###Average Result
````
STATS: time - 224.891, damage = 1008014.379, DPS = 4483.8, APM =  41.62, Crit = 0.35
===============================================================================================================
| Ability               #        d         n     nd        avg n    c    cd           cc       avg c       %
===============================================================================================================
| Pulse Cannon        : 64       203488.2  42    99794.08  2376.05  22  103694.15     34.38%   4713.37     20.2
| Plasmatize          : 86       108902.6  58    55948.43   964.63  28   52954.14     32.56%   1891.22     10.8
| Shockstrike         : 24       106225.9  16    53565.11  3347.82  8    52660.75     33.33%   6582.59     10.5
| High Implact Bolt   : 16       105543.1  0         0.00      NaN  16  105543.13    100.00%   6596.45     10.5
| Ion Pulse           : 29       102342.9  17    47224.46  2777.91  12   55118.39     41.38%   4593.20     10.2
| Fire Pulse          : 15        99716.1  8     35573.08  4446.64  7    64143.06     46.67%   9163.29      9.9
| Incendiary Round DOT: 78        88754.0  45    39823.85   884.97  33   48930.17     42.31%   1482.73      8.8
| Plasma Cell         : 125       87685.6  87    50550.95   581.05  38   37134.63     30.40%    977.23      8.7
| Shockstrike ele     : 24        34201.7  19    22572.72  1188.04  5    11628.97     20.83%   2325.79      3.4
| Hammer Shot         : 119       33974.5  84    19861.24   236.44  35   14113.25     29.41%    403.24      3.4
| Incendiary Round    : 16        19053.0  13    13931.14  1071.63  3     5121.87     18.75%   1707.29      1.9
| Shoulder Cannon     : 8         18126.8  4      6773.24  1693.31  4    11353.56     50.00%   2838.39      1.8
===============================================================================================================
```


## Adding 2 Revanite Relics + 2 power augments 
Mean is 4865 DPS, STD is 74.97 

![No Relic, No adrenal](https://raw.githubusercontent.com/tomcool420/swtor-simulator-matlab/master/Simulations%20Results/Plasmatech_Delay_Relics_NoAdrenal.png)

```
STATS: time - 224.891, damage = 1094589.055, DPS = 4867.192, APM =  41.62, Crit = 0.37
===============================================================================================================
| Ability               #        d         n     nd        avg n    c    cd           cc       avg c       %
===============================================================================================================
| Pulse Cannon        : 64       211502.5  45   115613.31  2569.18  19   95889.16     29.69%   5046.80     19.3
| Plasmatize          : 86       120213.4  55    57952.64  1053.68  31   62260.77     36.05%   2008.41     11.0
| Shockstrike         : 24       116921.0  15    53937.93  3595.86  9    62983.09     37.50%   6998.12     10.7
| Fire Pulse          : 15       116301.0  6     29924.49  4987.41  9    86376.49     60.00%   9597.39     10.6
| High Implact Bolt   : 16       111458.5  0         0.00      NaN  16  111458.50    100.00%   6966.16     10.2
| Ion Pulse           : 29       110072.9  16    48016.43  3001.03  13   62056.44     44.83%   4773.57     10.1
| Plasma Cell         : 125       97866.7  79    49490.54   626.46  46   48376.15     36.80%   1051.66      8.9
| Incendiary Round DOT: 78        92067.1  51    48709.75   955.09  27   43357.33     34.62%   1605.83      8.4
| Shockstrike ele     : 24        39097.6  17    21906.76  1288.63  7    17190.86     29.17%   2455.84      3.6
| Hammer Shot         : 119       36794.2  83    21019.41   253.25  36   15774.75     30.25%    438.19      3.4
| Incendiary Round    : 16        22577.4  10    11574.38  1157.44  6    11003.02     37.50%   1833.84      2.1
| Shoulder Cannon     : 8         19716.9  3      5235.47  1745.16  5    14481.39     62.50%   2896.28      1.8
===============================================================================================================
```

###Max
```
STATS: time - 226.871, damage = 1164297.662, DPS = 5131.974, APM =  49.46, Crit = 0.38
===============================================================================================================
| Ability               #        d         n     nd        avg n    c    cd           cc       avg c       %
===============================================================================================================
| Assault_Plastique   : 16       121687.1  7     36958.59  5279.80  9    84728.54     56.25%   9414.28     10.5
| Cell_Burst          : 10       120033.0  1      6937.42  6937.42  9   113095.60     90.00%  12566.18     10.3
| Gut                 : 1          1670.1  1      1670.06  1670.06  0        0.00      0.00%       NaN      0.1
| Gut_DOT             : 113      124824.0  78    66645.07   854.42  35   58178.94     30.97%   1662.26     10.7
| Hammer_Shot         : 77        22954.5  46    12300.87   267.41  24   10653.62     31.17%    443.90      2.0
| High_Impact_Bolt    : 40       310640.1  22   120101.17  5459.14  18  190538.92     45.00%  10585.50     26.7
| Shoulder_Cannon     : 19        56671.4  10    22208.72  2220.87  9    34462.66     47.37%   3829.18      4.9
| Stock_Strike        : 26       157843.4  12    48334.94  4027.91  14  109508.46     53.85%   7822.03     13.6
| Tactical_Surge      : 54       247974.1  35   119234.02  3406.69  19  128740.05     35.19%   6775.79     21.3
===============================================================================================================
```

##No Delay+Relics (still no adrenal)
We'd have a mean of 5002.9 DPS with a standard deviation of 80.93 (obviously almost impossible but best way to compare between specs)

![Relic, No adrenal](https://raw.githubusercontent.com/tomcool420/swtor-simulator-matlab/master/Simulations%20Results/Plasmatech_NoDelay_Relics_NoAdrenal.png)
```
STATS: time - 217.391, damage = 1083181.992, DPS = 4982.637, APM =  43.06, Crit = 0.38
===============================================================================================================
| Ability               #        d         n     nd        avg n    c    cd           cc       avg c       %
===============================================================================================================
| Pulse Cannon        : 64       217627.5  43   109302.38  2541.92  21  108325.13     32.81%   5158.34     20.1
| Shockstrike         : 24       117533.6  15    53267.00  3551.13  9    64266.62     37.50%   7140.74     10.9
| Plasmatize          : 84       116259.9  55    57989.67  1054.36  29   58270.27     34.52%   2009.32     10.7
| High Implact Bolt   : 16       113740.0  0         0.00      NaN  16  113739.96    100.00%   7108.75     10.5
| Fire Pulse          : 15       106918.3  8     40010.29  5001.29  7    66907.98     46.67%   9558.28      9.9
| Ion Pulse           : 29       104305.8  20    59174.71  2958.74  9    45131.13     31.03%   5014.57      9.6
| Plasma Cell         : 124       99871.1  73    45765.46   626.92  51   54105.59     41.13%   1060.89      9.2
| Incendiary Round DOT: 73        87170.0  47    44783.13   952.83  26   42386.89     35.62%   1630.26      8.0
| Shockstrike ele     : 24        42817.4  14    17643.69  1260.26  10   25173.68     41.67%   2517.37      4.0
| Hammer Shot         : 119       36483.2  82    20879.57   254.63  37   15603.65     31.09%    421.72      3.4
| Incendiary Round    : 16        23009.3  10    11998.85  1199.88  6    11010.44     37.50%   1835.07      2.1
| Shoulder Cannon     : 8         17445.9  5      8707.41  1741.48  3     8738.51     37.50%   2912.84      1.6
===============================================================================================================
```
