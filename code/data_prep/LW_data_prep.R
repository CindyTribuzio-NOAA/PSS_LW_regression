# Updated Dec 30, 2024 by C. Tribuzio
# import and clean up RACE and OBS data


# To Do ----
# in get_data folder, need to develop queries in RACEBASE to get ALL specimen data, data on AKFIN are filtered for only effective hauls
# develop query in NORPAC to get updated data of actual shark lengths/weights

# Setup ----
libs <- c("tidyverse", "janitor", "googlesheets4")
if(length(libs[which(libs %in% rownames(installed.packages()) == FALSE )]) > 0) {
  install.packages(libs[which(libs %in% rownames(installed.packages()) == FALSE)])}
lapply(libs, library, character.only = TRUE)
'%nin%'<-Negate('%in%') #this is a handy function

# bring in data----
# data provided by Duane Stevenson Dec 2024.
RACE_dat <- read.csv(paste0(getwd(), "/data/RACE_PSSLW_dat.csv")) %>% 
  clean_names %>% 
  mutate(weight = if_else(hauljoin == -3196, 33.60, 
                          if_else(hauljoin == -11395, 114.0, weight))) %>% #two outliers identified as likely typos
  select(length, weight, sex) %>% 
  mutate(source = "RACE")

# data from file used previously
NORPAC_dat <- read.csv(paste0(getwd(), "/data/NORPAC_PSSLW_dat.csv")) %>% 
  clean_names %>% 
  select(length, weight, sex) %>% 
  mutate(sex = if_else(sex == "M", 1,
                       if_else(sex == "F", 2, 3))) %>% 
  mutate(source = "NORPAC")

# EM shark survey data
EM_dat <- read_sheet('1sYmgRYZFR7xiEAluBKcGC1-7LH3P5S70WHGEQcrZiBE', sheet = 'shark_dat_cleaned') %>% clean_names() %>%
  select(sex, x1, weight) %>% 
  rename(length = x1) %>% 
  filter(!is.na(weight)) %>% 
  mutate(sex = if_else(sex == "M", 1,
                       if_else(sex == "F", 2, 3))) %>% 
  mutate(source = "EM_cruise")

# making output data file----
PSS_LW_dat <- RACE_dat %>% 
  bind_rows(NORPAC_dat, EM_dat)

write_csv(PSS_LW_dat, paste0(getwd(), "/data/PSS_LW_dat.csv"))

# quick look for oddballs----
ggplot(PSS_LW_dat, aes(x = length, y = weight, color = source))+
  geom_point()
