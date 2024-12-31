Weight-at-length regression for Pacific sleeper shark in the Gulf of Alaska, Bering Sea and Aleutian Islands. Data are from the Alaska Fisheries Science Center bottom trawl surveys, fishery at-sea observations and directed surveys.

Results will be updated as data are added.

Parameters were estimated using the formula: weight ~ a * length ^ b, and parameter results, with confidence intervals can be found in: 
PSS_LW_regression_params.csv

Notes:
Data are restricted to animals that can be measured, therefore, data are limited as length increases. There are no length and weight data for animals greater than XXX TLcm at this time. The maximum unverified length is about 700 cm TL and the maximum verified length is 465 cm TL (Matta et al. 2024)

```{r, echo=FALSE, warning=FALSE}
library(flextable) #you can use another table library, if you want
flextable(read.csv(paste0(getwd(), "\results\PSS_LW_regression_params.csv"))
```

<img src="https://ai.github.io/size-limit/logo.svg" align="right"
     alt="Pacific sleeper shark weight-at-length regression" width="120" height="178">
     
Updated XXXX by Cindy Tribuzio, AFSC. cindy.tribuzio@noaa.gov.