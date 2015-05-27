#Tactis Rotation Simulation
Using the parse and gear provided by Kwerty, The following attempts were made at 1) reproducing the results and 2) predicting future results
Each combination was run 2500 times to provide nice statistics. For each of the tables, 

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

Since tactics does NOT have a sub 30% boost, letting the parse run past the end of the dummy HP is fine.
##Kwerty NO Relic/Adrenal APM Free - Mean Result
Grabbing the rotation straight from Parsely, and then plugging it into the code, we obtain a mean of 4631.83 DPS with a standard deviation of 106.83. 
That means that around 68% of the parses would be between 4524.17 and 4737.83.
This result would be very difficult to replicate as it is near impossible to have no ability delay. That being said, in the future, when testing rotations, this is probably the best way to compare them.
As a sanity check: 158 cast on the GCD, factoring in 8.33% alacrity (158*1.5)/(1+0.0833)=218s
![No Relic, No adrenal](https://raw.githubusercontent.com/tomcool420/swtor-simulator-matlab/master/Simulations%20Results/Tactics_NoDelay_No_Relics_Adrenal.png)
```
STATS: time - 218.191, damage = 1010543.374, DPS = 4631.456, APM =  51.42, Crit = 0.33
===============================================================================================================
| Ability               #        d         n     nd        avg n    c    cd           cc       avg c       %
===============================================================================================================
| Assault_Plastique   : 16        96010.5  11    50690.05  4608.19  5    45320.42     31.25%   9064.08      9.5
| Cell_Burst          : 10        71138.3  7     43773.13  6253.30  3    27365.21     30.00%   9121.74      7.0
| Gut                 : 1          1632.5  1      1632.46  1632.46  0        0.00      0.00%       NaN      0.2
| Gut_DOT             : 113      121393.8  71    56070.08   789.72  42   65323.72     37.17%   1555.33     12.0
| Hammer_Shot         : 77        19842.5  52    13148.95   252.86  16    6693.59     20.78%    418.35      2.0
| High_Impact_Bolt    : 40       284614.1  24   121799.62  5074.98  16  162814.46     40.00%  10175.90     28.2
| Shoulder_Cannon     : 19        50654.7  12    25697.91  2141.49  7    24956.77     36.84%   3565.25      5.0
| Stock_Strike        : 26       133190.5  16    59817.42  3738.59  10   73373.09     38.46%   7337.31     13.2
| Tactical_Surge      : 54       232066.5  35   111745.33  3192.72  19  120321.17     35.19%   6332.69     23.0
===============================================================================================================
```

##Kwerty NO Relic/Adrenal 
To match Kwerty's parse, we add a small delay of 0.237s before each HiB (lines up with his rotation average).
Doing that gives us an average of 4480.37 with a standard deviation of 103.47
![No Relic, No adrenal](https://raw.githubusercontent.com/tomcool420/swtor-simulator-matlab/master/Simulations%20Results/Tactics_HiBDelay_No_Relics_Adrenal.png)

###Best Result
```
STATS: time - 226.871, damage = 1109358.885, DPS = 4889.816, APM =  49.46, Crit = 0.42
===============================================================================================================
| Ability               #        d         n     nd        avg n    c    cd           cc       avg c       %
===============================================================================================================
| Assault_Plastique   : 16       109462.7  8     36957.29  4619.66  8    72505.40     50.00%   9063.17      9.9
| Cell_Burst          : 10       108262.0  1      6285.67  6285.67  9   101976.35     90.00%  11330.71      9.8
| Gut                 : 1          3249.0  0         0.00      NaN  1     3248.97    100.00%   3248.97      0.3
| Gut_DOT             : 113      119905.2  73    57633.43   789.50  40   62271.78     35.40%   1556.79     10.8
| Hammer_Shot         : 77        21919.3  48    11956.76   249.10  24    9962.50     31.17%    415.10      2.0
| High_Impact_Bolt    : 40       296698.0  22   113959.89  5180.00  18  182738.11     45.00%  10152.12     26.7
| Shoulder_Cannon     : 19        54047.5  10    21366.14  2136.61  9    32681.35     47.37%   3631.26      4.9
| Stock_Strike        : 26       140061.1  14    52146.71  3724.76  12   87914.35     46.15%   7326.20     12.6
| Tactical_Surge      : 54       255754.2  27    86312.32  3196.75  27  169441.87     50.00%   6275.62     23.1
===============================================================================================================
```

###Worst Result
```
STATS: time - 226.871, damage = 943824.015, DPS = 4160.174, APM =  49.46, Crit = 0.29
===============================================================================================================
| Ability               #        d         n     nd        avg n    c    cd           cc       avg c       %
===============================================================================================================
| Assault_Plastique   : 16        91504.2  12    55281.69  4606.81  4    36222.55     25.00%   9055.64      9.7
| Cell_Burst          : 10        83734.0  5     31249.42  6249.88  5    52484.57     50.00%  10496.91      8.9
| Gut                 : 1          1623.9  1      1623.91  1623.91  0        0.00      0.00%       NaN      0.2
| Gut_DOT             : 113      112186.6  83    65575.22   790.06  30   46611.36     26.55%   1553.71     11.9
| Hammer_Shot         : 77        22805.4  45    11278.61   250.64  27   11526.80     35.06%    426.92      2.4
| High_Impact_Bolt    : 40       243592.7  32   162751.27  5085.98  8    80841.42     20.00%  10105.18     25.8
| Shoulder_Cannon     : 19        53160.2  11    23869.32  2169.94  8    29290.84     42.11%   3661.36      5.6
| Stock_Strike        : 26       125673.0  18    66914.39  3717.47  8    58758.58     30.77%   7344.82     13.3
| Tactical_Surge      : 54       209544.1  42   134028.34  3191.15  12   75515.74     22.22%   6292.98     22.2
===============================================================================================================
```

###Average Result
````
STATS: time - 226.871, damage = 1016564.765, DPS = 4480.799, APM =  49.46, Crit = 0.34
===============================================================================================================
| Ability               #        d         n     nd        avg n    c    cd           cc       avg c       %
===============================================================================================================
| Assault_Plastique   : 16        96523.1  11    50576.15  4597.83  5    45946.97     31.25%   9189.39      9.5
| Cell_Burst          : 10        83546.4  5     31177.87  6235.57  5    52368.57     50.00%  10473.71      8.2
| Gut                 : 1          1625.3  1      1625.34  1625.34  0        0.00      0.00%       NaN      0.2
| Gut_DOT             : 113      117671.7  76    59931.54   788.57  37   57740.12     32.74%   1560.54     11.6
| Hammer_Shot         : 77        20243.2  49    12155.89   248.08  19    8087.32     24.68%    425.65      2.0
| High_Impact_Bolt    : 40       273174.1  26   132722.35  5104.71  14  140451.79     35.00%  10032.27     26.9
| Shoulder_Cannon     : 19        58961.6  7     15350.33  2192.90  12   43611.23     63.16%   3634.27      5.8
| Stock_Strike        : 26       140212.2  14    52255.95  3732.57  12   87956.30     46.15%   7329.69     13.8
| Tactical_Surge      : 54       224607.0  37   117755.40  3182.58  17  106851.63     31.48%   6285.39     22.1
===============================================================================================================
```
(within 50 dps of his actual parse)

## Adding 2 Revanite Relics + 2 power augments 
Mean is 4784.18 DPS, STD is 112 and the max was 5131 - Unsuprisingly you'd need, ON AVERAGE around 2K parses to have one 3 stdevs above the mean
![No Relic, No adrenal](https://raw.githubusercontent.com/tomcool420/swtor-simulator-matlab/master/Simulations%20Results/Tactics_HiBDelay_Relics_No_Adrenal.png)

```
STATS: time - 226.871, damage = 1085283.186, DPS = 4783.695, APM =  49.46, Crit = 0.35
===============================================================================================================
| Ability               #        d         n     nd        avg n    c    cd           cc       avg c       %
===============================================================================================================
| Assault_Plastique   : 16       107749.2  10    50007.11  5000.71  6    57742.06     37.50%   9623.68      9.9
| Cell_Burst          : 10        89963.7  5     34354.37  6870.87  5    55609.31     50.00%  11121.86      8.3
| Gut                 : 1          1689.7  1      1689.71  1689.71  0        0.00      0.00%       NaN      0.2
| Gut_DOT             : 113      124409.2  79    66917.70   847.06  34   57491.46     30.09%   1690.93     11.5
| Hammer_Shot         : 77        23045.6  43    11192.56   260.29  27   11853.05     35.06%    439.00      2.1
| High_Impact_Bolt    : 40       291893.4  25   134652.77  5386.11  15  157240.62     37.50%  10482.71     26.9
| Shoulder_Cannon     : 19        56612.4  11    25633.37  2330.31  8    30979.00     42.11%   3872.38      5.2
| Stock_Strike        : 26       144377.8  16    62916.22  3932.26  10   81461.54     38.46%   8146.15     13.3
| Tactical_Surge      : 54       245542.3  36   125357.24  3482.15  18  120185.11     33.33%   6676.95     22.6
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
We'd have a mean of 4945 DPS with a standard deviation of 114.93 (obviously almost impossible but best way to compare between specs)
![Relic, No adrenal](https://raw.githubusercontent.com/tomcool420/swtor-simulator-matlab/master/Simulations%20Results/Tactics_NoDelay_Relics_No_Adrenal.png)
```
STATS: time - 218.191, damage = 1079393.412, DPS = 4947.005, APM =  51.42, Crit = 0.34
===============================================================================================================
| Ability               #        d         n     nd        avg n    c    cd           cc       avg c       %
===============================================================================================================
| Assault_Plastique   : 16       101625.9  11    53094.95  4826.81  5    48530.94     31.25%   9706.19      9.4
| Cell_Burst          : 10        94090.0  5     35365.92  7073.18  5    58724.08     50.00%  11744.82      8.7
| Gut                 : 1          3240.6  0         0.00      NaN  1     3240.59    100.00%   3240.59      0.3
| Gut_DOT             : 113      125227.9  77    65051.52   844.82  36   60176.39     31.86%   1671.57     11.6
| Hammer_Shot         : 77        22029.6  47    12339.24   262.54  22    9690.35     28.57%    440.47      2.0
| High_Impact_Bolt    : 40       288956.8  25   136515.60  5460.62  15  152441.23     37.50%  10162.75     26.8
| Shoulder_Cannon     : 19        55269.1  11    25351.31  2304.66  8    29917.80     42.11%   3739.72      5.1
| Stock_Strike        : 26       159217.3  12    48710.30  4059.19  14  110506.96     53.85%   7893.35     14.8
| Tactical_Surge      : 54       229736.2  40   135742.38  3393.56  14   93993.85     25.93%   6713.85     21.3
===============================================================================================================
```