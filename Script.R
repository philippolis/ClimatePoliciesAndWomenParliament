library(ggplot2)
library(dplyr)

# Data wrangling Women in Parliament ----
WomenParliament_data <- read.csv("WomenParliament.csv", sep = ";")

## Creating a new column with overall share of women
### Replacing NA with 0 in lower house columns
WomenParliament_data[is.na(WomenParliament_data)] <- 0

WomenParliament_data$Share <- (WomenParliament_data$UpperOrSenate_Women + WomenParliament_data$LowerOrSingleHouse_Women)/
  (WomenParliament_data$UpperOrSenate_Seats + WomenParliament_data$LowerOrSingleHouse_Seats)

## Only selecting varibles of interest
WomenParliament_data_small <- WomenParliament_data %>% select(Country, Share)

## Only selecting cases of interest
countries_Climate <- unique(ClimatePolicyIndex_data$Country)

WomenParliament_data_small <- WomenParliament_data_small[WomenParliament_data_small$Country %in% countries_Climate,]

### Compare the two Country columns
countries_Women <- unique(WomenParliament_data_small$Country)

setdiff(countries_Climate, countries_Women) # shows which states are in Climate data, that are named differently in women data

WomenParliament_data$Country <- gsub("Russian Federation", "Russia", WomenParliament_data$Country)
WomenParliament_data$Country <- gsub("United States of America", "United States", WomenParliament_data$Country)
WomenParliament_data$Country <- gsub("Republic of Korea", "South Korea", WomenParliament_data$Country)

WomenParliament_data_small <- WomenParliament_data_small[WomenParliament_data_small$Country %in% countries_Climate,]

# Data wrangling Climate Policy Index ----
ClimatePolicyIndex_data <- read.csv("ClimatePolicyIndex.csv")

## Renaming columns
names(ClimatePolicyIndex_data)[names(ClimatePolicyIndex_data)=="name"] <- "Country"
names(ClimatePolicyIndex_data)[names(ClimatePolicyIndex_data)=="value"] <- "Index"

## Only selecting variables of interest
ClimatePolicyIndex_data_small <- ClimatePolicyIndex_data %>% select(Country, Index)

# Joining ClimatePolicy and WomenParliament data ----
data = WomenParliament_data_small %>% 
  full_join(ClimatePolicyIndex_data_small, by = c("Country"))

## Making a test plot
ggplot(data, aes(x = Share, y = Index)) + geom_point() + geom_smooth(method = "lm")

## Checking if linear model is significant
summary(lm(data = data, Index ~ Share))

