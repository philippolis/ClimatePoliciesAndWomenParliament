# Joining years of Climate Risk Index ----
## Equalizing Country naming
gw2015_final$pais <- gsub("Bosnia and\rHerzegovina", "Bosnia and Herzegovina", gw2015_final$pais)
gw2016_final$pais <- gsub("Antigua", "Antigua and Barbuda", gw2016_final$pais)
gw2016_final$pais <- gsub("Bosnia", "Bosnia and Herzegovina", gw2016_final$pais)
gw2015_final$pais <- gsub("Brunei Darussalam", "Brunei", gw2015_final$pais)
gw2016_final$pais <- gsub("Burkina", "Burkina Faso", gw2016_final$pais)
gw2016_final$pais <- gsub("Cape", "Cape Verde", gw2016_final$pais)
gw2015_final$pais <- gsub("Former Yugoslav\rRepublic of\rMacedonia", "Macedonia", gw2015_final$pais)
gw2016_final$pais <- gsub("Former Yugoslav\rRepublic of Macedonia", "Macedonia", gw2016_final$pais)

## Renaming Columns
names(gw2015_final)[names(gw2015_final)=="CRI_ranking"] <- "CRI_ranking_2015"
names(gw2016_final)[names(gw2016_final)=="CRI_ranking"] <- "CRI_ranking_2016"
names(gw2017_final)[names(gw2017_final)=="CRI_ranking"] <- "CRI_ranking_2017"
names(gw2018_final)[names(gw2018_final)=="CRI_ranking"] <- "CRI_ranking_2018"
names(gw2019_final)[names(gw2019_final)=="CRI_ranking"] <- "CRI_ranking_2019"

## Joining the Datasets
ClimateRiskIndex_data = gw2015_final %>%
  full_join(gw2016_final, by = "pais") %>%
  full_join(gw2017_final, by = "pais") %>%
  full_join(gw2018_final, by = "pais") %>%
  full_join(gw2019_final, by = "pais")

## Reordering the Columns
ClimateRiskIndex_data = ClimateRiskIndex_data[, c("pais", "CRI_ranking_2015", 
                                                  "CRI_ranking_2016", "CRI_ranking_2017",
                                                  "CRI_ranking_2018", "CRI_ranking_2019")]

## Renaming pais to Country
names(ClimateRiskIndex_data)[names(ClimateRiskIndex_data)=="pais"] <- "Country"

## Adding an averaged column
ClimateRiskIndex_data <- ClimateRiskIndex_data %>% 
  mutate(Mean_Ranking = rowMeans(.[c("CRI_ranking_2015", 
                                     "CRI_ranking_2016", "CRI_ranking_2017",
                                     "CRI_ranking_2018", "CRI_ranking_2019")], na.rm = TRUE))

# Quickly testing the relationship
test_data <- data %>%
  full_join(ClimateRiskIndex_data, by = "Country")

test_data <- test_data %>% select(Country, Share, Index, CRI_ranking_2015)

ggplot(data = test_data, aes(x = CRI_ranking_2015, y = Index)) + geom_point() +
  geom_smooth(method = "lm")

summary(lm(data = test_data, Index ~ CRI_ranking_2015 + Share))

test_data_2 <- data %>%
  full_join(ClimateRiskIndex_data, by = "Country")

## This plot shows that each year, the slope increased
ggplot(data = test_data_2) +
  geom_smooth(aes(x = CRI_ranking_2015, y = Index), method = "lm", color = "blue", se = F) +
  geom_smooth(aes(x = CRI_ranking_2016, y = Index), method = "lm", color = "red", se = F) +
  geom_smooth(aes(x = CRI_ranking_2017, y = Index), method = "lm", color = "green", se = F) +
  geom_smooth(aes(x = CRI_ranking_2018, y = Index), method = "lm", color = "cyan", se = F) +
  geom_smooth(aes(x = CRI_ranking_2019, y = Index), method = "lm", color = "magenta", se = F)
