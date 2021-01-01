library(rstanarm)

data <- read.csv("data.csv")

# Bayesian Regression analysis
stan_model <- stan_glm(data = data, Score ~ Total_PercWomen)

summary(stan_model) # Rhat below 1.1, so model converged