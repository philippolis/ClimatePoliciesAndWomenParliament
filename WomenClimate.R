library(dplyr)
library(ggplot2)
library(countrycode)
library(tidyr)
library(tabulizer)
library(rstanarm)

# Women in Parliament ----
## Loading data
WomenParliament_2018 <- read.csv("WomenParliament_20171201.csv", sep = ";")
WomenParliament_2019 <- read.csv("WomenParliament_20181201.csv", sep = ";")
WomenParliament_2020 <- read.csv("WomenParliament_20191201.csv", sep = ";")

## Equalizing Country columns
for(i in 1:nrow(WomenParliament_2018)) {
  WomenParliament_2018[i,"Country"] <- countryname(WomenParliament_2018[i,"Country"], destination = "iso.name.en", warn = TRUE)
}

for(i in 1:nrow(WomenParliament_2019)) {
  WomenParliament_2019[i,"Country"] <- countryname(WomenParliament_2019[i,"Country"], destination = "iso.name.en", warn = TRUE)
}

for(i in 1:nrow(WomenParliament_2020)) {
  WomenParliament_2020[i,"Country"] <- countryname(WomenParliament_2020[i,"Country"], destination = "iso.name.en", warn = TRUE)
}

## Selecting only columns of interest
WomenParliament_2018 <- WomenParliament_2018 %>% select(Country, Year, Total_PercWomen)
WomenParliament_2019 <- WomenParliament_2019 %>% select(Country, Year, Total_PercWomen)
WomenParliament_2020 <- WomenParliament_2020 %>% select(Country, Year, Total_PercWomen)

## Joining the Datasets
WomenParliament <- rbind(WomenParliament_2018, WomenParliament_2019, WomenParliament_2020)

# Policy Performance ----
pdf_link_2018 <- "https://germanwatch.org/sites/germanwatch.org/files/publication/20503.pdf"
pdf_link_2019 <- "https://germanwatch.org/sites/germanwatch.org/files/CCPI-2019-Results-190614-WEB-A4.pdf"
pdf_link_2020 <- "https://germanwatch.org/sites/germanwatch.org/files/CCPI-2020-Results_1.pdf"


## Scraping the data 
### Scraping Index 2018
pdf_data_2018 <- as.data.frame(extract_areas(pdf_link_2018, pages = 10, method = "stream"))

colnames(pdf_data_2018) <- c("Rank", "Country")

pdf_data_2018 <- pdf_data_2018 %>% 
  mutate(Rank = as.numeric(Rank))

for (i in 1:nrow(pdf_data_2018)) {
  pdf_data_2018[i, "Score"] <- round(100 - i/length(pdf_data_2018$Rank) * 100, digits = 1)
}

### Scraping Index 2019
pdf_data_2019 <- as.data.frame(extract_areas(pdf_link_2019, pages = 15, method = "stream"))

colnames(pdf_data_2019) <- c("Rank", "Country", "Score")

### Scraping Index 2020
pdf_data_2020 <- as.data.frame(extract_areas(pdf_link_2020, pages = 17, method = "stream"))

colnames(pdf_data_2020) <- c("Rank", "Country", "Score")

## Equalizing Country columns
for(i in 1:nrow(pdf_data_2018)) {
  pdf_data_2018[i,"Country"] <- countryname(pdf_data_2018[i,"Country"], destination = "iso.name.en", warn = TRUE)
}

for(i in 1:nrow(pdf_data_2019)) {
  pdf_data_2019[i,"Country"] <- countryname(pdf_data_2019[i,"Country"], destination = "iso.name.en", warn = TRUE)
}

for(i in 1:nrow(pdf_data_2020)) {
  pdf_data_2020[i,"Country"] <- countryname(pdf_data_2020[i,"Country"], destination = "iso.name.en", warn = TRUE)
}

## Adding columns with year of observation
for(i in 1:nrow(pdf_data_2018)) {
  pdf_data_2018[i,"Year"] <- 2018
}

for(i in 1:nrow(pdf_data_2019)) {
  pdf_data_2019[i,"Year"] <- 2019
}

for(i in 1:nrow(pdf_data_2020)) {
  pdf_data_2020[i,"Year"] <- 2020
}

## Joining the Policy Performance datasets
ClimatePerformance <- rbind(pdf_data_2018, pdf_data_2019, pdf_data_2020)

ClimatePerformance$Rank <- NULL

# Joining Policy Performance and Women in Parliament datasets
data <- ClimatePerformance %>% 
  full_join(WomenParliament, by = c("Country", "Year"))

## Making Score and Total_PercWomen numeric again
data <- data %>% 
  mutate(Score = as.numeric(Score))

data <- data %>% 
  mutate(Total_PercWomen = as.numeric(Total_PercWomen))

## Adding a column with region
for(i in 1:nrow(data)) {
  data[i,"Region"] <- countryname(data[i,"Country"], destination = "region", warn = TRUE)
}

data <- data[complete.cases(data$Country),]

## Summarizing the regions
data$Region <- gsub("\\<East Asia & Pacific\\>", "South Asia, East Asia & Pacific", data$Region)
data$Region <- gsub("\\<South Asia\\>", "South Asia, East Asia & Pacific", data$Region)
data$Region <- gsub("\\<Latin America & Caribbean\\>", "Americas", data$Region)
data$Region <- gsub("\\<Middle East & North Africa\\>", "Middle East & Africa", data$Region)
data$Region <- gsub("\\<Sub-Saharan Africa\\>", "Middle East & Africa", data$Region)
data$Region <- gsub("\\<North America\\>", "Americas", data$Region)
data$Region <- gsub("\\<South Asia, East Asia & Pacific, East Asia & Pacific\\>", "South Asia, East Asia & Pacific", data$Region)

# Visualizing the relationship
ggplot(data = data) +
  geom_point(aes(x = Total_PercWomen, y = Score, color = Region)) +
  geom_smooth(aes(x = Total_PercWomen, y = Score), method = "lm") +
  xlab("Share of Women in Parliament") +
  ylab("Climate Policy Index")

summary(lm(data = data, Score ~ Total_PercWomen)) # Statistische Signifikanz

ggplot(data = data) +
  geom_point(aes(x = Total_PercWomen, y = Score)) +
  geom_smooth(aes(x = Total_PercWomen, y = Score, color = factor(Year)), method = "lm", se = F) +
  facet_wrap(~ Region)

ggplot(data = data) +
  geom_point(aes(x = Total_PercWomen, y = Score, color = Region)) +
  geom_smooth(aes(x = Total_PercWomen, y = Score), method = "lm") +
  facet_wrap(~ factor(Year))

lm_model <- lm(data = data, Score ~ Total_PercWomen + factor(Year) + Region)

summary(lm_model) # Statistische Signifikanz

# Bayesian Regression analysis
stan_model <- stan_glm(data = data, Score ~ Total_PercWomen)

summary(stan_model) # Rhat below 1.1, so model converged
