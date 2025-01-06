# Updated 2 Jan 2025 by C. Tribuzio
# import and clean up length data


# To Do ----

# Setup ----
libs <- c("tidyverse", "janitor", "googlesheets4")
if(length(libs[which(libs %in% rownames(installed.packages()) == FALSE )]) > 0) {
  install.packages(libs[which(libs %in% rownames(installed.packages()) == FALSE)])}
lapply(libs, library, character.only = TRUE)
'%nin%'<-Negate('%in%') #this is a handy function

# Bring in data----
# Length data from various surveys
# note that two values for PCL were input incorrectly and changed in the datafile (C. Mason dissections)
ll_dat <- read.csv(paste0(getwd(), "/data/S_pacificus_size_summary.csv")) %>% 
  clean_names() %>% 
  filter(pcl_type == "measure",
         tl_type == "measure") %>% 
  select(sex, pcl, t_lcm) %>% 
  rename(tl = t_lcm) %>% 
  mutate(pcl = pcl/10)

# add in EM cruise data
# EM shark survey data
EM_dat <- read_sheet('1sYmgRYZFR7xiEAluBKcGC1-7LH3P5S70WHGEQcrZiBE', sheet = 'shark_dat_cleaned') %>% clean_names() %>%
  select(sex, pre_caudal, x1) %>% 
  rename(tl = x1,
         pcl = pre_caudal) %>% 
  filter(!is.na(pcl),
         !is.na(tl)) %>% 
  mutate(sex = if_else(sex == "M", 1,
                       if_else(sex == "F", 2, 3)))

#write output----
# making output data file----
PSS_LL_dat <- ll_dat %>% 
  bind_rows(EM_dat)

write_csv(PSS_LL_dat, paste0(getwd(), "/data/PSS_LL_dat.csv"))

# quick look for oddballs----
ggplot(PSS_LL_dat, aes(x = tl, y = pcl, color = sex))+
  geom_point()

