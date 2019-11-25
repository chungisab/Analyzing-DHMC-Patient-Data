

library(rvest)
scraping_wiki <-  read_html("https://en.wikipedia.org/wiki/Web_scraping")
head(scraping_wiki)
h1_text <- scraping_wiki %>% html_nodes("h1") %>%html_text()
h2_text <- scraping_wiki %>% html_nodes("h2") %>%html_text()
length(h2_text)
h3_text <- scraping_wiki %>% html_nodes("h3") %>%html_text()
h4_text <- scraping_wiki %>% html_nodes("h4") %>%html_text()
p_nodes <- scraping_wiki %>%html_nodes("p")
p_nodes[1:6]
p_text <- scraping_wiki %>% html_nodes("p") %>%html_text()
length(p_text)

ul_text <- scraping_wiki %>% html_nodes("ul") %>%html_text()
length(ul_text)

ul_text[1]
substr(ul_text[2],start=5,stop=14)
li_text <- scraping_wiki %>% html_nodes("li") %>%html_text()
length(li_text)
li_text[1:8]
lii_text <- scraping_wiki %>% html_nodes("lii") %>%html_text()
table_text<-scraping_wiki %>% html_nodes("table") %>%html_text()
# all text irrespecive of headings, paragrpahs, lists, ordered list etc..
all_text <- scraping_wiki %>%
  html_nodes("div") %>% 
  html_text()
p_text
clean_text <- scraping_wiki %>% html_nodes("mw-body") %>%html_text()
clean_text

body_text <- scraping_wiki %>%
  html_nodes("#mw-content-text") %>% 
  html_text()

substr(body_text, start = 1, stop = 10)

# Scraping a specific heading
scraping_wiki %>%
  html_nodes("#Controversy_and_litigation") %>% 
  html_text()

# Scraping a specific paragraph
scraping_wiki %>%
  html_nodes("#cite_note-12") %>% 
  html_text()

# Scraping a specific list
scraping_wiki %>%
  html_nodes("#Australia") %>% 
  html_text()

# Scraping a specific reference list item
scraping_wiki %>%
  html_nodes("#cite_note-22") %>% 
  html_text()


# Load packages
library(rvest)
library(stringr)
library(dplyr)
library(lubridate)
library(readr)

# Read web page
webpage <- read_html("https://www.nytimes.com/interactive/2017/06/23/opinion/trumps-lies.html")
webpage
# Extract records info
results <- webpage %>% html_nodes(".short-desc")

# Building the dataset
records <- vector("list", length = length(results))

for (i in seq_along(results)) {
  date <- str_c(results[i] %>% 
                  html_nodes("strong") %>% 
                  html_text(trim = TRUE), ', 2017')
  lie <- str_sub(xml_contents(results[i])[2] %>% html_text(trim = TRUE), 2, -2)
  explanation <- str_sub(results[i] %>% 
                           html_nodes(".short-truth") %>% 
                           html_text(trim = TRUE), 2, -2)
  url <- results[i] %>% html_nodes("a") %>% html_attr("href")
  records[[i]] <- data_frame(date = date, lie = lie, explanation = explanation, url = url)
}

df <- bind_rows(records)

# Transform to datetime format
df$date <- mdy(df$date)

# Export to csv
write_csv(df, "trump_lies.csv")

