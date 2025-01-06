# Updated Dec 30, 2024 by C. Tribuzio
# import and clean up RACE and OBS data

# To Do ----

# Setup ----
libs <- c("tidyverse", "janitor", "ggpubr", "broom")
if(length(libs[which(libs %in% rownames(installed.packages()) == FALSE )]) > 0) {
  install.packages(libs[which(libs %in% rownames(installed.packages()) == FALSE)])}
lapply(libs, library, character.only = TRUE)
'%nin%'<-Negate('%in%') #this is a handy function

# bring in data----
# data provided by Duane Stevenson Dec 2024.
lw_dat <- read.csv(paste0(getwd(), "/data/PSS_LW_dat.csv"))

# check for sig diff in sex----
lnLW_sex <- lm(log(weight) ~ log(length) * sex, data = lw_dat)
summary(lnLW_sex) #sex not significant

ggplot(lw_dat, aes(log(length), log(weight), color=factor(sex))) +
  geom_point(alpha=0.3, size=2) +
  geom_smooth(method="lm",se=FALSE) +
  labs(x="ln Total length (cm)", y="ln Weight (kg)", color = "") +
  scale_color_manual(values = c("#0073cf", "#b8023e", "grey50"), labels = c("Male", "Female", "Unknown")) +
  theme_pubr(base_size = 11) +
  theme(legend.position = c(0.2,0.9),
        legend.background = element_blank(),
        plot.margin=grid::unit(c(0,0,0,0), "mm"))

# TL LW regression with combined sexes, which includes unknowns----
start_values <- c(a = 0.000007, b = 3)
TLLW_fit <- lw_dat %>% nls(weight ~ a * length ^ b, start = start_values, data = .)
alevel <- 0.75
TLCI_fit <- as.data.frame(confint(TLLW_fit, level = alevel))
names(TLCI_fit) <- c("ll", "ul")
TLmatrix_coef <- summary(TLLW_fit)$coefficients %>% 
  bind_cols(TLCI_fit) %>% 
  select(Estimate, ll, ul) %>% 
  clean_names() %>% 
  rownames_to_column() %>% 
  rename(parameter = rowname)
write_csv(TLmatrix_coef, paste0(getwd(),"/results/PSS_TLLW_regression_params.csv"))
TLlw_mod <- function(x){(TLmatrix_coef[1,2]) * (x^TLmatrix_coef[2,2])}
TLlw_ll <- function(x){(TLmatrix_coef[1,3]) * (x^TLmatrix_coef[2,3])}
TLlw_ul <- function(x){(TLmatrix_coef[1,4]) * (x^TLmatrix_coef[2,4])}

TLlw_plot <- ggplot(lw_dat, aes(x = length, y = weight))+
  geom_point(alpha=0.3, size=2)+
  #geom_point(aes(x = length, y = estW))+
  stat_function(fun = TLlw_mod, linetype = "solid", color = "black", size=1.2) +
  stat_function(fun = TLlw_ll, linetype="dashed", color="grey50", size=1) +
  stat_function(fun = TLlw_ul, linetype="dashed", color="grey50", size=1) +
  #stat_function(fun=PSS_Orlov2014, linetype="dotdash", color="#32a852", size=1) +
  #stat_function(fun=PSS_Yano, linetype="longdash", color="#c42f52", size=1) +
  labs(x="Total length (cm)", y= "Weight (kg)") +
  coord_cartesian(ylim=c(0,1000)) +
  annotate("text", x=20, y=1000, 
           label= bquote("W = "~ .(round(TLmatrix_coef[1,2]*10^6, 2))~e^-06~ " * " ~ 
                           TL^.(round(TLmatrix_coef[2,2], 2))~ "alpha = " ~.(alevel)), 
           hjust=0, size=3)+
  theme_pubr(legend="none", base_size = 11) +
  theme(plot.margin=grid::unit(c(0,0,0,0), "mm"))

ggsave(path = paste0(getwd(), "/results/"),
       "PSS_TLLW_regression.png", plot= TLlw_plot, dpi=600, width = 4, height = 4)

# PCL LW regression----
# step 1 - convert TL to PCL
ll_dat <- read.csv(paste0(getwd(), "/data/PSS_LL_dat.csv"))
LL_sex_fit <- lm(pcl ~ tl * sex, data = ll_dat)
summary(LL_sex_fit) #sex not significant

# linear regression with sexes combined
LL_fit <- lm(pcl ~ tl, data = ll_dat)
summary(LL_fit)

tl_pcl_plot <- ggplot(ll_dat, aes(tl, pcl)) +
  geom_point(alpha=0.3, size=2) +
  geom_smooth(method="lm", se=FALSE) +
  labs(x="Total length (cm)", y="Pre-caudal Length (cm)", color = "") +
  stat_cor(aes(label = paste(after_stat(rr.label))), # adds R^2 value
           r.accuracy = 0.01,
           label.x = 0, label.y = 375, size = 4) +
  stat_regline_equation(aes(label = after_stat(eq.label)), # adds equation to linear regression
                        label.x = 0, label.y = 400, size = 4)+
  theme_pubr(base_size = 11) +
  theme(legend.position = c(0.2,0.9),
        legend.background = element_blank(),
        plot.margin=grid::unit(c(0,0,0,0), "mm"))

ggsave(path = paste0(getwd(), "/results/"),
       "PSS_TLPCL_regression.png", plot= tl_pcl_plot, dpi=600, width = 4, height = 4)

alevel2 <- 0.95
LLCI_fit <- as.data.frame(confint(LL_fit, level = alevel2))
names(LLCI_fit) <- c("ll", "ul")
LLmatrix_coef <- summary(LL_fit)$coefficients %>% 
  bind_cols(LLCI_fit) %>% 
  select(Estimate, ll, ul) %>% 
  clean_names() %>% 
  rownames_to_column() %>% 
  mutate(parameter = c("int", "slope")) %>% 
  select(!rowname)
write_csv(LLmatrix_coef, paste0(getwd(),"/results/PSS_LL_regression_params.csv"))

# convert LW TL to PCL
pclw_dat <- lw_dat %>% 
  mutate(pcl = LLmatrix_coef[1,1] + LLmatrix_coef[2,1] * length)

# PCL to weight regression----
start_values <- c(a = 0.000007, b = 3)
PCLLW_fit <- pclw_dat %>% nls(weight ~ a * pcl ^ b, start = start_values, data = .)
alevel <- 0.75
PCLCI_fit <- as.data.frame(confint(PCLLW_fit, level = alevel))
names(PCLCI_fit) <- c("ll", "ul")
PCLmatrix_coef <- summary(PCLLW_fit)$coefficients %>% 
  bind_cols(PCLCI_fit) %>% 
  select(Estimate, ll, ul) %>% 
  clean_names() %>% 
  rownames_to_column() %>% 
  rename(parameter = rowname)
write_csv(PCLmatrix_coef, paste0(getwd(),"/results/PSS_PCLLW_regression_params.csv"))
PCLlw_mod <- function(x){(PCLmatrix_coef[1,2]) * (x^PCLmatrix_coef[2,2])}
PCLlw_ll <- function(x){(PCLmatrix_coef[1,3]) * (x^PCLmatrix_coef[2,3])}
PCLlw_ul <- function(x){(PCLmatrix_coef[1,4]) * (x^PCLmatrix_coef[2,4])}

PCLlw_plot <- ggplot(pclw_dat, aes(x = pcl, y = weight))+
  geom_point(alpha=0.3, size=2)+
  #geom_point(aes(x = length, y = estW))+
  stat_function(fun = PCLlw_mod, linetype = "solid", color = "black", size=1.2) +
  stat_function(fun = PCLlw_ll, linetype="dashed", color="grey50", size=1) +
  stat_function(fun = PCLlw_ul, linetype="dashed", color="grey50", size=1) +
  #stat_function(fun=PSS_Orlov2014, linetype="dotdash", color="#32a852", size=1) +
  #stat_function(fun=PSS_Yano, linetype="longdash", color="#c42f52", size=1) +
  labs(x="Pre-caudal length (cm)", y= "Weight (kg)") +
  coord_cartesian(ylim=c(0,1000)) +
  annotate("text", x=20, y=1000, 
           label= bquote("W = "~ .(round(PCLmatrix_coef[1,2]*10^6, 2))~e^-06~ " * " ~ 
                           TL^.(round(PCLmatrix_coef[2,2], 2))~ "alpha = " ~.(alevel)), 
           hjust=0, size=3)+
  theme_pubr(legend="none", base_size = 11) +
  theme(plot.margin=grid::unit(c(0,0,0,0), "mm"))

ggsave(path = paste0(getwd(), "/results/"),
       "PSS_PCLLW_regression.png", plot= PCLlw_plot, dpi=600, width = 4, height = 4)

# combined TL and PCL graph----
ldat <- pclw_dat %>% 
  rename(TL = length,
         PCL = pcl) %>% 
  select(!c(sex, source)) %>% 
  pivot_longer(!weight, names_to = "length_type", values_to = "length_cm")

comb_LW_plot <- ggplot(ldat, aes(x = length_cm, y = weight, shape = length_type))+
  geom_point(alpha=0.3, size=2)+
  #geom_point(aes(x = length, y = estW))+
  stat_function(fun = PCLlw_mod, linetype = "solid", color = "black", size=1.2) +
  stat_function(fun = PCLlw_ll, linetype="dashed", color="grey50", size=1) +
  stat_function(fun = PCLlw_ul, linetype="dashed", color="grey50", size=1) +
  stat_function(fun = TLlw_mod, linetype = "solid", color = "black", size=1.2) +
  stat_function(fun = TLlw_ll, linetype="dashed", color="grey50", size=1) +
  stat_function(fun = TLlw_ul, linetype="dashed", color="grey50", size=1) +
  #stat_function(fun=PSS_Orlov2014, linetype="dotdash", color="#32a852", size=1) +
  #stat_function(fun=PSS_Yano, linetype="longdash", color="#c42f52", size=1) +
  labs(x="Length (cm)", y= "Weight (kg)") +
  coord_cartesian(ylim=c(0,1000)) +
  theme_pubr(legend="none", base_size = 11) +
  theme(plot.margin=grid::unit(c(0,0,0,0), "mm"))

ggsave(path = paste0(getwd(), "/results/"),
       "PSS_combinedLW_regression.png", plot= comb_LW_plot, dpi=600, width = 4, height = 4)
