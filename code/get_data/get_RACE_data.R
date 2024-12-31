# Query survey length weight data ----
# Contact: cindyDec 19 2024

# Setup ----
library(c(tidyverse, RODBC))
dbname <- "akfin"
db <- read_csv('database.csv')
database_akfin=db %>% filter(database == dbname) %>% select(database) #need to add filter for AKFIN user/pass only
username_akfin=db %>% filter(database == dbname) %>% select(username)
password_akfin=db %>% filter(database == dbname) %>% select(password)

channel_akfin <- odbcConnect(dbname, uid = username_akfin, pwd = password_akfin, believeNRows=FALSE)

# note that this code doesn't pull ALL data, ask Duane Stevenson for SQL query in racebase
#in the meantime, use file provided by Duane S.
RACE_PSS_LWdat <- sqlQuery(channel_akfin, query = ("
                select * from gap_products.akfin_specimen
                where species_code = 320"))



write_csv(RACE_PSS_LWdat, paste0(getwd(), "/data/RACE_PSSLW_dat.csv")) 
