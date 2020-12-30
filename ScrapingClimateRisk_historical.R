library(tabulizer)
library(countrycode)
library(dplyr)

# Getting the PDF link
pdf_link <- "https://germanwatch.org/sites/germanwatch.org/files/20-2-01e%20Global%20Climate%20Risk%20Index%202020_14.pdf"

# Preparing the column names
column_names <- c("CRI_Rank", "Country", "CRI_score", "FatalitiesTotal_Rank", "FatalitiesPer100000_Rank", 
                  "LossesTotal_Rank", "LossesPerGDP_Rank")

# Scraping p41
pdf_data_p41 <- as.data.frame(extract_tables(pdf_link, pages = 41, method = "decide"))

pdf_data_p41 <- as.data.frame(pdf_data_p41[2:nrow(pdf_data_p41), ])

colnames(pdf_data_p41) <- column_names

# Scraping p42
pdf_data_p42 <- as.data.frame(extract_tables(pdf_link, pages = 42, method = "decide"))

pdf_data_p42 <- as.data.frame(pdf_data_p42[2:nrow(pdf_data_p42), ])

colnames(pdf_data_p42) <- column_names

# Scraping p43
pdf_data_p43 <- as.data.frame(extract_tables(pdf_link, pages = 43, method = "decide"))

pdf_data_p43 <- as.data.frame(pdf_data_p43[2:nrow(pdf_data_p43), ])

colnames(pdf_data_p43) <- column_names

# Scraping p40
pdf_data_p40 <- as.data.frame(extract_areas(pdf_link, pages = 40, method = "stream"))

colnames(pdf_data_p40) <- column_names

# Joining the three datasets
RiskIndex_data <- rbind(pdf_data_p40, pdf_data_p41, pdf_data_p42, pdf_data_p43)

# Standardizing Country Names
for(i in 1:nrow(RiskIndex_data)) {
  RiskIndex_data[i,"Country"] <- countryname(RiskIndex_data[i,"Country"], destination = "iso.name.en", warn = TRUE)
}

# Making Rankings numeric
RiskIndex_data <- RiskIndex_data %>% 
  mutate(CRI_Rank = as.numeric(CRI_Rank))

RiskIndex_data <- RiskIndex_data %>% 
  mutate(CRI_score = as.numeric(CRI_score))

RiskIndex_data <- RiskIndex_data %>% 
  mutate(FatalitiesTotal_Rank = as.numeric(FatalitiesTotal_Rank))

RiskIndex_data <- RiskIndex_data %>% 
  mutate(FatalitiesPer100000_Rank = as.numeric(FatalitiesPer100000_Rank))

RiskIndex_data <- RiskIndex_data %>% 
  mutate(LossesTotal_Rank = as.numeric(LossesTotal_Rank))

RiskIndex_data <- RiskIndex_data %>% 
  mutate(LossesPerGDP_Rank = as.numeric(LossesPerGDP_Rank))

# Clean up workspace
rm(pdf_data_p40)
rm(pdf_data_p41)
rm(pdf_data_p42)
rm(pdf_data_p43)

rm(column_names)

rm(pdf_link)

