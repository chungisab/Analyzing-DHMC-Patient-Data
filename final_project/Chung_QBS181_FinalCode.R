library(tidyverse)
library(dplyr)
### (1)
ic_bp <- read.csv("IC_BP_v2.csv")

# (a)
# Convert BP alerts to BP status
names(ic_bp)[4] <- "BPStatus" 
sample_n(ic_bp, 10) # Print 10 random rows

# (b) Dichotomous outcomes 
# Assign 1 if Hypotension-1 or Normal (controlled blood pressure)
# Assign 0 if Hypotension-2, Hypertension-1, Hypertension-2 or Hypertension-3 (uncontrolled blood pressure)
ic_bp1 <- ic_bp %>% 
  mutate(BPScore = ifelse(BPStatus %in% c("Hypo1", "Normal"), 1, 0))

sample_n(ic_bp1, 10) # Print 10 random rows

# (c)
# Get Demographics table from SQL
myconn<-odbcConnect("qbs","ychung","ychung@qbs181")
demographics <- sqlQuery(myconn, "SELECT * FROM [qbs181].[ychung].Demographics")

dem <- read.csv("Demographics_201911260123.csv")

## Data cleaning
# Rename columns
names(dem) <- c("ID", "GenderCode", "Age", "ParentCustomerIDName", "ImagineCareEnrollmentStatus", "Address", "EmailSentDate", "EnrollmentCompleteDate", "Gender", "Gender_Name")

# Recode variables
dem1 <- dem %>%
  mutate(Sex = case_when(GenderCode == 2 ~ "Female", 
                         GenderCode == 1 ~ "Male", 
                         ImagineCareEnrollmentStatus == 167410000 ~ "Other", 
                         GenderCode == "NULL" ~ "Unknown"), 
         AgeGroup = case_when(Age >= 0 & Age <= 25 ~ "0-25",
                              Age >= 26 & Age <= 50 ~ "26-50", 
                              Age >= 51 & Age <= 75 ~ "51-75",
                              Age >= 76 & Age <= 100 ~ "76-100",
                              Age >= 101 & Age <= 125 ~ "101-125"), 
         # Convert date variables into Date formats
         EmailSentDate = as.Date(EmailSentDate,format="%m/%d/%Y"), 
         EnrollmentCompleteDate = as.Date(EnrollmentCompleteDate,format="%m/%d/%Y")) %>% 
  # Drop repetitive columns 
  select(-c(GenderCode,Gender,Gender_Name))

# Join IC_BP with Demographics table to obtain enrollment dates
join <- inner_join(ic_bp1, dem1) 

sample_n(join, 10) # Print 10 random rows

# (d) Create time intervals
join_time <- join %>% 
  # Convert ObservedTime to POSIXt
  mutate(ObservedTime2 = as.POSIXct(ObservedTime, tz = "EST", origin = EnrollmentCompleteDate)) %>%
  select(ID, BPStatus, BPScore, ObservedTime, ObservedTime2, EnrollmentCompleteDate) %>%
  mutate(week = as.numeric(strftime(as.POSIXct(ObservedTime2), format = "%W"))) %>% 
  group_by(ID, week) %>%
  mutate(Interval = case_when(
    week >=9 & week <= 21 ~ 1,
    week >=22 & week <= 34 ~ 2,
    week >=35 & week <= 47 ~ 3,
    week >=48 & week <= 52 ~ 4,
  )) %>%
  #Calculate average score of each customer in each interval 
  mutate(AvgBPScore = mean(BPScore, na.rm = TRUE)) 

# Print 10 random rows
sample_n(join_time, 10, replace = TRUE)

# (e) Compare the scores from baseline (first week) to follow-up scores (12 weeks)
join_time2 <- join_time %>%
  mutate(ScoreDiff = AvgBPScore - BPScore) %>%
  arrange(Interval)  

# Print 10 random rows
sample_n(join_time2, 10, replace = TRUE)

# (f) How many customers were brought from uncontrolled regime to controlled regime after 12 weeks of intervention?
join_time3 <- join_time2 %>% 
  group_by(ID, Interval) %>% 
  arrange(Interval) %>%
  filter(ScoreDiff > 0 ) %>%
  count(ID)

dim(join_time3) 

# 101 customers were brought from uncontrolled regime to controlled regime after 12 weeks of intervention

### 2. 
demcondtext1 <- sqlQuery(myconn, "SELECT A.*, B.*, C.*
INTO [qbs181].[ychung].DemCondText1 
FROM [qbs181].[ychung].TextMessages A
LEFT JOIN [qbs181].[ychung].Conditions B ON A.tri_contactId = B.tri_patientid 
LEFT JOIN [qbs181].[ychung].Demographics C ON A.tri_contactid = C.ID")
sample_n(demcondtext1, 10)

maxtext <- sqlQuery(myconn, "SELECT ID, MAX(TRY_CONVERT(Date,TextSentDate)) as MaxDate
INTO [qbs181].[ychung].LastTexts
FROM [qbs181].[ychung].DemCondText1 
GROUP BY ID")
sample_n(maxtext, 10)

### 3. 
# ONE Row per ID by choosing on the latest date when the text was sent (if sent on multiple days)
condition <- read.csv("Conditions_201911260229.csv")
text <- read.csv("TextMessages_201911260229.csv")

# Rename variables
names(condition) <- c("ID", "Condition") 
names(text)[1] <- "ID" 

# Merge the tables Demographics, Conditions and TextMessages
textdem <- inner_join(text, dem1)
textdemcond <- inner_join(textdem, condition)

# Convert to Date format & One row per ID by choosing on the latest date when the text was sent (if sent on multiple days)
textdemcond1 <- textdemcond %>% 
  mutate(TextSentDate = as.Date(TextSentDate, format="%m/%d/%y")) %>% # convert to Date format
  group_by(ID) %>%
  mutate(LastTextSentDate = max(TextSentDate)) %>% # make a new variable that keeps track of the latest date when the text was sent for each user
  filter(LastTextSentDate == TextSentDate) %>% # only keep the latest date when the text was sent (if sent on multiple days)
  select(ID, LastTextSentDate) %>% 
  distinct() # remove duplicates 

# Print 10 random rows 
sample_n(textdemcond1, 10, replace = TRUE)

