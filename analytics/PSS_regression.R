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

# LL regression with combined sexes, which includes unknowns----
start_values <- c(a = 0.000007, b = 3)
LW_fit <- lw_dat %>% nls(weight ~ a * length ^ b, start = start_values, data = .)
alevel <- 0.75
CI_fit <- as.data.frame(confint(LW_fit, level = alevel))
names(CI_fit) <- c("ll", "ul")
matrix_coef <- summary(LW_fit)$coefficients %>% 
  bind_cols(CI_fit) %>% 
  select(Estimate, ll, ul) %>% 
  clean_names() %>% 
  rownames_to_column() %>% 
  rename(parameter = rowname)
write_csv(matrix_coef, paste0(getwd(),"/results/PSS_LW_regression_params.csv"))
lw_mod <- function(x){(matrix_coef[1,2]) * (x^matrix_coef[2,2])}
lw_ll <- function(x){(matrix_coef[1,3]) * (x^matrix_coef[2,3])}
lw_ul <- function(x){(matrix_coef[1,4]) * (x^matrix_coef[2,4])}

lw_plot <- ggplot(lw_dat, aes(x = length, y = weight))+
  geom_point(alpha=0.3, size=2)+
  #geom_point(aes(x = length, y = estW))+
  stat_function(fun = lw_mod, linetype = "solid", color = "black", size=1.2) +
  stat_function(fun = lw_ll, linetype="dashed", color="grey50", size=1) +
  stat_function(fun = lw_ul, linetype="dashed", color="grey50", size=1) +
  #stat_function(fun=PSS_Orlov2014, linetype="dotdash", color="#32a852", size=1) +
  #stat_function(fun=PSS_Yano, linetype="longdash", color="#c42f52", size=1) +
  labs(x="Total length (cm)", y= "Weight (kg)") +
  coord_cartesian(ylim=c(0,1000)) +
  annotate("text", x=20, y=1000, 
           label= bquote("W = "~ .(round(matrix_coef[1,2]*10^6, 2))~e^-06~ " * " ~ 
                           TL^.(round(matrix_coef[2,2], 2))~ "alpha = " ~.(alevel)), 
           hjust=0, size=3)+
  theme_pubr(legend="none", base_size = 11) +
  theme(plot.margin=grid::unit(c(0,0,0,0), "mm"))

ggsave(path = paste0(getwd(), "/results/"),
       "PSS_LW_regression.png", plot= lw_plot, dpi=600, width = 4, height = 4)

