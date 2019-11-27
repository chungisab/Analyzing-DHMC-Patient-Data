install.packages(c("SASxport", "Hmisc"))
install.packages(c("DataExplorer", "igraph"))
install.packages("RODBC")
install.packages("dplyr")
install.packages("ggplot2")
library("RODBC")
library(dplyr)
library(ggplot2)
library(SASxport)
library(Hmisc)
library(DataExplorer)
library(igraph)
library(tidyverse)

# Import XPT file
diabetes_xpt <- read.xport(file.choose())
# Save it as a CSV file
write.csv(diabetes_xpt, file = "Desktop\\DIQ.csv", row.names = FALSE)
myconn<-odbcConnect("qbs","ychung","ychung@qbs181")
diabetes <- sqlQuery(myconn, "select * from [qbs181].[ychung].DIQ_I")

head(diabetes, n = 10)

plot_missing(diabetes)

# SKIP PATTERNS
diabetes1 <- diabetes %>% 
  mutate(
    # Take care of skip patterns (skip items)
    # Create new variables derived from variables in skip sequences.
    # In other words, we recode variables to include those who answered "No" in first question of skip sequence
    DIQ180a = case_when(DIQ180 == 1 ~ 1, 
                        DIQ180 <= 2 | DIQ172 == 2 ~ 2),
    DID260a = case_when(DID260 > 0 & DID260 < 16 ~ 1,
                        DID260 <= 2 | DIQ240 == 2 ~ 2),
    DID341a = case_when(DID341 > 0 & DID341 < 35 ~ 1, 
                        (DID341 >= 0 & DID341 <35) | DID320 == 5555 | DID320 == 6666 ~ 2),
    #Take care of skip patterns (check items); respondents were taken to end of survey in these cases
    DIQ080a = case_when(DIQ010 == 1 |DIQ010 == 3 | DIQ160 ~ 1)
  )

# Encode NAs as "2" for the 175 question series EXCEPT THOSE WHO SAID YES WHO 172 
diabetes1[,which(grepl("175", names(diabetes1)))][is.na(diabetes1[,which(grepl("175", names(diabetes1)))])] <- 2

diabetes1[sample(nrow(diabetes1), 10), ]

# Check structure 
str(diabetes1)

# Convert categorical variables to factors
cols <- c("DIQ010", "DIQ160", "DIQ170", "DIQ172", "DIQ175A", "DIQ175B", "DIQ175C", "DIQ175D", "DIQ175E", "DIQ175F", "DIQ175G",
  "DIQ175H", "DIQ175I", "DIQ175J", "DIQ175K", "DIQ175L", "DIQ175M", "DIQ175N", "DIQ175O", "DIQ175P", "DIQ175Q", "DIQ175R",
  "DIQ175S", "DIQ175T", "DIQ175U", "DIQ175V", "DIQ175W", "DIQ175X", "DIQ180", "DIQ050", "DIQ060U", "")
diabetes1[cols] <- lapply(diabetes1[cols], as.factor)


