# Weight-at-length regression for Pacific sleeper shark in the Gulf of Alaska, Bering Sea and Aleutian Islands. 

Data are from the Alaska Fisheries Science Center bottom trawl surveys, fishery at-sea observations and directed surveys.Results will be updated as data are added.

Weight at length parameters are estimated for both total length (from the tip of the snout to the tip of the upper caudal line, in a straight line with the tail in the natural position) and pre-caudal length (from the tip of the snout to the dorsal pre-caudal notch).
<img src="https://raw.githubusercontent.com/CindyTribuzio-NOAA/PSS_LW_regression/main/results/PSS_TL_PCL.png"
     alt="Pacific sleeper shark length types">
     
Total length to pre-caudal length converted using: PCL ~ int + slope * TL. Results here are from [Matta et al. 2024](https://link.springer.com/article/10.1007/s00300-024-03247-8), but with the addition of directed survey data. Parameter results are in [PSS_LL_regression_params.csv](https://github.com/CindyTribuzio-NOAA/PSS_LW_regression/blob/main/results/PSS_LL_regression_params.csv)

<img src="https://raw.githubusercontent.com/CindyTribuzio-NOAA/PSS_LW_regression/main/results/PSS_LL_regression.png"
     alt="Pacific sleeper shark Pre-caudal to Total Length regression">

Length-to-weight parameters were estimated using the formula: weight ~ a * length ^ b, and parameter results, with confidence intervals. Resultant parameters can be found in: 
[PSS_TLLW_regression_params.csv](https://github.com/CindyTribuzio-NOAA/PSS_LW_regression/blob/main/results/PSS_LW_regression_params.csv)
[PSS_PCLLW_regression_params.csv](https://github.com/CindyTribuzio-NOAA/PSS_LW_regression/blob/main/results/PSS_LW_regression_params.csv)

<img src="https://raw.githubusercontent.com/CindyTribuzio-NOAA/PSS_LW_regression/main/results/PSS_TLLW_regression.png"
     alt="Pacific sleeper shark weight-at-TL regression">
     
<img src="https://raw.githubusercontent.com/CindyTribuzio-NOAA/PSS_LW_regression/main/results/PSS_PCLLW_regression.png"
     alt="Pacific sleeper shark weight-at-PCL regression">   
     
<img src="https://raw.githubusercontent.com/CindyTribuzio-NOAA/PSS_LW_regression/main/results/PSS_combinedLW_regression.png"
     alt="Pacific sleeper shark weight-at-length regression">        

# Notes
Data are restricted to animals that can be measured, and or were measured for both total and pre-caudal length. Data are severely limited as length increases. There are no TL-to-PCL or TL-to-weight data for animals greater than 344 cm TL at this time. The maximum unverified length is about 700 cm TL and the maximum verified length is 465 cm TL ([Matta et al. 2024](https://link.springer.com/article/10.1007/s00300-024-03247-8))


Updated 31 Dec 2024 by Cindy Tribuzio, AFSC. cindy.tribuzio@noaa.gov.