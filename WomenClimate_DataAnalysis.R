library(ggplot2)
library(rstanarm)
library(bayesplot)
library(dplyr)
library(broom.mixed)

data <- read.csv("data/WomenClimate_Data.csv")

# Bivariate plot ----

ggplot(data = data) +
  geom_point(aes(x = PercentWomen, y = PolicyScore), alpha = 0.5) +
  geom_smooth(aes(x = PercentWomen, y = PolicyScore), method = "lm") +
  xlab("Share of Women in Parliament") +
  ylab("Climate Policy Index") +
  scale_x_continuous(labels = scales::percent_format(accuracy = 1), 
                     breaks = scales::pretty_breaks(n = 6)) +
  ggtitle("Share of Women in Parliament and Climate Policy Index") +
  theme(
     plot.title = element_text(size = 11, face = "bold"),
     text=element_text(family="CMU Sans Serif")
  )

# Including Region?
region_data <- data %>% group_by(Region) %>% summarize(Mean = round(mean(PolicyScore, na.rm = TRUE),1))

# Frequentist analysis ----
lm_model <- lm(data = data, PolicyScore ~ PercentWomen + factor(Year) + Region)

summary(lm_model)

# Bayesian Regression analysis ----
## Model with default priors ----
### The default priors in the rstanarm package are normal[0,2.5]. 
### Let's run a model with these (and all default iteration and seed options) 
### and see what the results look like.
stan_model1 <- stan_glm(data = data, PolicyScore ~ PercentWomen)

prior_summary(stan_model1) # as we can see, the priors are set to Intercept[0, 10] and Coefficients[0, 2.5]

summary(stan_model1) # Rhat below 1.1, so model converged, we have enough iterations

### Construct tidy table 
tidy(stan_model1, conf.int = TRUE, conf.level = 0.90) %>%
  mutate(term = c("Intercept", 
                  "Percentage Women")) %>% 
  mutate_if(is.numeric, round, 3) %>% 
  rename(Term = term, Estimate = estimate,
         `Standard Deviation` = std.error, 
         `Lower 90% CI` = conf.low, `Upper 90% CI` = conf.high) # Credible Intervals for Year and Region cross 0

## Model with informative priors ----
### Histogram of PercentWomen-prior of normal[0.5,0.5]

p1 <- data.frame(dist = rnorm(100000, 0.5, 0.5))

ggplot(p1) + geom_density(aes(x=dist), size = 1, color = "#0072B2", fill = "#cce2ef") + 
  labs(title="Prior for Percentage of Women in Parliament",
       x="Beta value", 
       y="Probability") +
  scale_x_continuous(breaks=seq(-5,3,1), limits = c(-2.5, 2.5)) +
  theme(
    plot.title = element_text(size = 11, face = "bold"),
    text=element_text(size = 11)
  )

### Analysis
stan_model2 <- stan_glm(data = data, PolicyScore ~ PercentWomen, 
                        prior = normal(location = 0.5, scale = 0.5, autoscale = TRUE))

prior_summary(stan_model2)

tidy(stan_model2, conf.int = TRUE, conf.level = 0.90) %>%
  mutate(term = c("Intercept", 
                  "Percentage Women")) %>% 
  mutate_if(is.numeric, round, 3) %>% 
  rename(Term = term, Estimate = estimate,
         `Standard Deviation` = std.error, 
         `Lower 90% CI` = conf.low, `Upper 90% CI` = conf.high)

### Getting the adjusted scale with the priors
prior_summary(stan_model2)

### Visualising the posterior distribution of Percent Women
mcmc_areas(stan_model2,
           pars = "PercentWomen",
           prob = 0.90) + 
  labs(
    title = "Posterior Distribution for the Coefficient of\nPercentage of Women in Parliament",
    subtitle = "with medians and 90% credible intervals"
  ) +
  panel_bg(fill = "gray95", color = NA) +
  grid_lines(color = "white") +
  ggplot2::theme(
    plot.title = element_text(size = 11, face = "bold"),
    text=element_text(size = 11, family = "Calibri")
  )

## Getting the R² Statistic
ss_res2 <- var(residuals(stan_model2))
ss_total2 <- var(fitted(stan_model2)) + var(residuals(stan_model2))
1- (ss_res2 / ss_total2)

### Visualising the R²-distribution
ggplot(data = data.frame(bayes_R2(stan_model2))) + 
  geom_histogram(aes(x=bayes_R2.stan_model2.), size = 1, color = "#0072B2", fill = "white") + 
  labs(title="R²-Statistic",
       x="Variance in Policy Performance explained by Model", 
       y="Probability") +
  scale_x_continuous(labels = scales::percent_format(accuracy = 1), 
                     breaks = scales::pretty_breaks(n = 6)) +
  theme(
    plot.title = element_text(size = 11, face = "bold"),
    text=element_text(size = 11),
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank()
    )

## Making a model prediction
prediction <- posterior_predict(stan_model2, newdata = data.frame(PercentWomen = 0.5))

ggplot(data = data.frame(prediction)) + 
  geom_density(aes(x=X1), size = 1, color = "#0072B2") + 
  labs(title="Prediction for the Climate Policy Performance of a Country\nwith a Genderbalanced Parliament",
       x="Climate Policy Performance Score", 
       y="Probability") +
  theme(
    plot.title = element_text(size = 11, face = "bold"),
    text=element_text(size = 11),
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank()
    )

head(data.frame(prediction))

sum((data.frame(prediction))$X1 > 98.7) / length((data.frame(prediction))$X1)
