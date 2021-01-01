library(rstanarm)
library(extrafont)
loadfonts()

data <- read.csv("WomenClimate_Data.csv")

# Bivariate plot

ggplot(data = data) +
  geom_point(aes(x = PercentWomen, y = PolicyScore), alpha = 0.5) +
  geom_smooth(aes(x = PercentWomen, y = PolicyScore), method = "lm") +
  xlab("Share of Women in Parliament") +
  ylab("Climate Policy Index") +
  scale_x_continuous(labels = scales::percent_format(accuracy = 1), 
                     breaks = scales::pretty_breaks(n = 6)) +
  ggtitle("Share of Women in Parliament and Climate Policy Index") +
  theme(
     plot.title = element_text(size = 11, face = "bold")
  )


# Bayesian Regression analysis
stan_model <- stan_glm(data = data, Score ~ Total_PercWomen)

summary(stan_model) # Rhat below 1.1, so model converged