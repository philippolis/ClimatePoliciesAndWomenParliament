install.packages("countrycode")
library(countrycode)

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

# Visualising relationships
## Overall relationship
ggplot(data = data) +
  geom_smooth(method = "lm", aes(x = CRI_ranking, y = Policy_perf))

## Relationship subdivided by Region
### Shows stronger trends in North America and Middle East & North Africa
ggplot(data = data) +
  geom_smooth(method = "lm", aes(x = CRI_ranking, y = Policy_perf, color = Region), se = F)

## Relationship subdivided by Year
### Shows that relationship between CRI and Policy_perf gets stronger over the years, 
### in the sense that countries most affected are the least climate-friendly
ggplot(data = data) +
  geom_smooth(method = "lm", aes(x = CRI_ranking, y = Policy_perf, color = factor(Year)), se = F)

## Relationship subdivided by Year and Region
ggplot(data = data) +
  geom_smooth(method = "lm", aes(x = CRI_ranking, y = Policy_perf, color = factor(Year)), se = F) +
  facet_wrap(~ Region)

## Relationship subdivided by Region and Year
ggplot(data = data) +
  geom_smooth(method = "lm", aes(x = CRI_ranking, y = Policy_perf, color = Region), se = F) +
  facet_wrap(~ factor(Year))