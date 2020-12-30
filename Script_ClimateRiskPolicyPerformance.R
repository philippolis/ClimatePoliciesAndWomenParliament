install.packages("countrycode")
library(countrycode)
library(tidyr)
library(ggplot2)
library(dplyr)

# Data wrangling Women in Parliament ----
WomenParliament_data <- read.csv("WomenParliament.csv", sep = ";")

## Creating a new column with overall share of women
### Replacing NA with 0 in lower house columns
WomenParliament_data[is.na(WomenParliament_data)] <- 0

WomenParliament_data$Share <- (WomenParliament_data$UpperOrSenate_Women + WomenParliament_data$LowerOrSingleHouse_Women)/
  (WomenParliament_data$UpperOrSenate_Seats + WomenParliament_data$LowerOrSingleHouse_Seats)

## Only selecting variables of interest
WomenParliament_data_small <- WomenParliament_data %>% select(Country, Share)

## Equalizing Country column
for(i in 1:nrow(WomenParliament_data_small)) {
  WomenParliament_data_small[i,"Country"] <- countryname(WomenParliament_data_small[i,"Country"], destination = "iso.name.en", warn = TRUE)
}

# Data wrangling Climate Policy Index ----
ClimatePolicyIndex_data <- read.csv("ClimatePolicyIndex.csv")

## Renaming columns
names(ClimatePolicyIndex_data)[names(ClimatePolicyIndex_data)=="name"] <- "Country"
names(ClimatePolicyIndex_data)[names(ClimatePolicyIndex_data)=="value"] <- "Index"

## Only selecting variables of interest
ClimatePolicyIndex_data_small <- ClimatePolicyIndex_data %>% select(Country, Index)

## Equalizing Country naming
for(i in 1:nrow(ClimatePolicyIndex_data_small)) {
  ClimatePolicyIndex_data_small[i,"Country"] <- countryname(ClimatePolicyIndex_data_small[i,"Country"], destination = "iso.name.en", warn = TRUE)
}

## Adding column with Years
ClimatePolicyIndex_data_small["Year"] <- rep(2020, nrow(ClimatePolicyIndex_data_small))

# Data Wrangling Median Income
MedianIncome_data <- read.csv("MedianIncome.csv")

for(i in 1:nrow(MedianIncome_data)) {
  MedianIncome_data[i,"ï..country"] <- countryname(MedianIncome_data[i,"ï..country"], destination = "iso.name.en", warn = TRUE)
}

names(MedianIncome_data)[names(MedianIncome_data)=="ï..country"] <- "Country"

# Data Wrangling Climate Risk Index ----
## Equalizing Country naming

for(i in 1:nrow(gw2015_final)) {
  gw2015_final[i,"pais"] <- countryname(gw2015_final[i,"pais"], destination = "iso.name.en", warn = TRUE)
}

for(i in 1:nrow(gw2016_final)) {
  gw2016_final[i,"pais"] <- countryname(gw2016_final[i,"pais"], destination = "iso.name.en", warn = TRUE)
}

for(i in 1:nrow(gw2017_final)) {
  gw2017_final[i,"pais"] <- countryname(gw2017_final[i,"pais"], destination = "iso.name.en", warn = TRUE)
}

for(i in 1:nrow(gw2018_final)) {
  gw2018_final[i,"pais"] <- countryname(gw2018_final[i,"pais"], destination = "iso.name.en", warn = TRUE)
}

for(i in 1:nrow(gw2019_final)) {
  gw2019_final[i,"pais"] <- countryname(gw2019_final[i,"pais"], destination = "iso.name.en", warn = TRUE)
}

## Adding columns with Years
gw2015_final["Year"] <- rep(2015, nrow(gw2015_final))
gw2016_final["Year"] <- rep(2016, nrow(gw2016_final))
gw2017_final["Year"] <- rep(2017, nrow(gw2017_final))
gw2018_final["Year"] <- rep(2018, nrow(gw2018_final))
gw2019_final["Year"] <- rep(2019, nrow(gw2019_final))

## Renaming Columns
names(gw2015_final)[names(gw2015_final)=="CRI_ranking"] <- "CRI_ranking_2015"
names(gw2016_final)[names(gw2016_final)=="CRI_ranking"] <- "CRI_ranking_2016"
names(gw2017_final)[names(gw2017_final)=="CRI_ranking"] <- "CRI_ranking_2017"
names(gw2018_final)[names(gw2018_final)=="CRI_ranking"] <- "CRI_ranking_2018"
names(gw2019_final)[names(gw2019_final)=="CRI_ranking"] <- "CRI_ranking_2019"

## Joining the Datasets
ClimateRiskIndex_data = gw2015_final %>%
  full_join(gw2016_final, by = c("pais", "Year")) %>%
  full_join(gw2017_final, by = c("pais", "Year")) %>%
  full_join(gw2018_final, by = c("pais", "Year")) %>%
  full_join(gw2019_final, by = c("pais", "Year"))

ClimateRiskIndex_data <- unite(ClimateRiskIndex_data, CRI_ranking, c(CRI_ranking_2015, CRI_ranking_2016,
                                            CRI_ranking_2017, CRI_ranking_2018,
                                            CRI_ranking_2019), na.rm = TRUE)

## Reordering the Columns
ClimateRiskIndex_data = ClimateRiskIndex_data[, c("pais", "Year", "CRI_ranking")]

## Renaming pais to Country
names(ClimateRiskIndex_data)[names(ClimateRiskIndex_data)=="pais"] <- "Country"

#### Adding an averaged column
##ClimateRiskIndex_data <- ClimateRiskIndex_data %>% 
##  mutate(Mean_Ranking = rowMeans(.[c("CRI_ranking_2015", 
##                                     "CRI_ranking_2016", "CRI_ranking_2017",
##                                     "CRI_ranking_2018", "CRI_ranking_2019")], na.rm = TRUE))

# Joining Climate risk and Policy Performance
data = ClimatePolicyIndex_data_small %>%
  full_join(ClimateRiskIndex_data, by = "Country")

## Dropping year.x column with 2020 repeated
data$Year.x <- NULL

## Reordering the Columns
data = data[, c("Country", "Year.y", "CRI_ranking", "Index")]

## Renaming Year.y to Year and Index to Policy_perf
names(data)[names(data)=="Year.y"] <- "Year"
names(data)[names(data)=="Index"] <- "Policy_perf"

## Adding a column with region
for(i in 1:nrow(data)) {
  data[i,"Region"] <- countryname(data[i,"Country"], destination = "region", warn = TRUE)
}

## Making CRI_ranking numeric
data <- data %>% 
  mutate(CRI_ranking = as.numeric(CRI_ranking))

## Cleaning up the environment
rm(ClimatePolicyIndex_data)
rm(gw2015_final)
rm(gw2016_final)
rm(gw2017_final)
rm(gw2018_final)
rm(gw2019_final)
rm(i)

# Joining the Climate risk historical data with climate index data ----
data_historical <- subset(ClimatePolicyIndex_data_small, select = c(Country, Index)) %>%
  full_join(RiskIndex_data, by = "Country")

## Adding a column with region
for(i in 1:nrow(data_historical)) {
  data_historical[i,"Region"] <- countryname(data_historical[i,"Country"], destination = "region", warn = TRUE)
}

# Joining Climate Risk historical and Climate Index with Median Income data
data_historical <- data_historical %>%
  full_join(MedianIncome_data, by = "Country")

# Joining Risk Policy Income Data with Women in Parliament data
data_historical <- data_historical %>%
  full_join(WomenParliament_data_small, by = "Country")

# Visualising relationships ----
## Risk Index data from 2015 to 2018
### Overall relationship
ggplot(data = data) +
  geom_smooth(method = "lm", aes(x = CRI_ranking, y = Policy_perf))

### Relationship subdivided by Region
#### Shows stronger trends in North America and Middle East & North Africa
ggplot(data = data) +
  geom_smooth(method = "lm", aes(x = CRI_ranking, y = Policy_perf, color = Region), se = F)

### Relationship subdivided by Year
#### Shows that relationship between CRI and Policy_perf gets stronger over the years, 
#### in the sense that countries most affected are the least climate-friendly
ggplot(data = data) +
  geom_smooth(method = "lm", aes(x = CRI_ranking, y = Policy_perf, color = factor(Year)), se = F)

### Relationship subdivided by Year and Region
ggplot(data = data) +
  geom_smooth(method = "lm", aes(x = CRI_ranking, y = Policy_perf, color = factor(Year)), se = F) +
  facet_wrap(~ Region)

### Relationship subdivided by Region and Year
ggplot(data = data) +
  geom_smooth(method = "lm", aes(x = CRI_ranking, y = Policy_perf, color = Region), se = F) +
  facet_wrap(~ factor(Year))

## Historical risk index data from 1999 - 2018
### Fatalities per 100000
ggplot(data = data_historical) +
  geom_point(aes(x = FatalitiesPer100000_Rank, y = Index)) +
  geom_smooth(method = "lm", aes(x = FatalitiesPer100000_Rank, y = Index))

#### By Region
ggplot(data = data_historical) +
  geom_point(aes(x = FatalitiesPer100000_Rank, y = Index)) +
  geom_smooth(method = "lm", aes(x = FatalitiesPer100000_Rank, y = Index)) +
  facet_wrap(~ Region)


### Fatalities total
ggplot(data = data_historical) +
  geom_point(aes(x = FatalitiesTotal_Rank, y = Index)) +
  geom_smooth(method = "lm", aes(x = FatalitiesTotal_Rank, y = Index))

#### By Region
ggplot(data = data_historical) +
  geom_point(aes(x = FatalitiesTotal_Rank, y = Index)) +
  geom_smooth(method = "lm", aes(x = FatalitiesTotal_Rank, y = Index)) +
  facet_wrap(~ Region)

### Losses per GDP
ggplot(data = data_historical) +
  geom_point(aes(x = LossesPerGDP_Rank, y = Index)) +
  geom_smooth(method = "lm", aes(x = LossesPerGDP_Rank, y = Index))

#### By Region
ggplot(data = data_historical) +
  geom_point(aes(x = LossesPerGDP_Rank, y = Index)) +
  geom_smooth(method = "lm", aes(x = LossesPerGDP_Rank, y = Index)) +
  facet_wrap(~ Region)

### Losses per GDP
ggplot(data = data_historical) +
  geom_point(aes(x = LossesTotal_Rank, y = Index)) +
  geom_smooth(method = "lm", aes(x = LossesTotal_Rank, y = Index))

#### By Region
ggplot(data = data_historical) +
  geom_point(aes(x = LossesTotal_Rank, y = Index)) +
  geom_smooth(method = "lm", aes(x = LossesTotal_Rank, y = Index)) +
  facet_wrap(~ Region)

### Get a summary of the risk of each region
data_historical %>%
  group_by(Region) %>%
  summarise(Mean_Risk = mean(CRI_score))

## Median Income Data
### Median per Capita Income and Policy Performance
ggplot(data = data_historical) +
  geom_point(aes(x = medianPerCapitaIncome, y = Index)) +
  geom_smooth(method = "lm", aes(x = medianPerCapitaIncome, y = Index), se = T)

### Is anything significant? No
summary(lm(data = data_historical, Index ~ medianPerCapitaIncome + FatalitiesPer100000_Rank + pop2020))

### Risk Index by medianPerCapitaIncome
summary(lm(data = data_historical, CRI_score ~ medianPerCapitaIncome))

summary(lm(data = data_historical, Index ~ pop2020))

## Quick correlation table
pairs(subset(data_historical, select = c(Index, CRI_score, FatalitiesPer100000_Rank, 
                                       LossesPerGDP_Rank, medianPerCapitaIncome, 
                                       pop2020, Share))) # Only Share and Index seem to be correlated

## Women in Parliament and Index
ggplot(data = data_historical, aes(x = Share, y = Index)) +
  geom_point() +
  geom_smooth(method = "lm")


