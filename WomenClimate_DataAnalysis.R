library(ggplot2)
library(rstanarm)
library(extrafont)
loadfonts()

data <- read.csv("WomenClimate_Data.csv")

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

## Model with informative priors
### Histogram of PercentWomen-prior of normal[0.5,0.5]

p1 <- data.frame(dist = rnorm(100000, 0.5, 0.5))

ggplot(p1) + geom_density(aes(x=dist), size = 1) + 
  labs(title="Prior for Percentage of Women in Parliament",
       x="Beta value", 
       y="Probability") +
  scale_x_continuous(breaks=seq(-5,3,1), limits = c(-2.5, 2.5)) +
  theme(
    plot.title = element_text(size = 12, face = "bold"),
    text=element_text(family="CMU Sans Serif", size = 12)
  )

### Analysis
stan_model2 <- stan_glm(data = data, PolicyScore ~ PercentWomen, 
                        prior = normal(location = 0.5, scale = 0.5, autoscale = TRUE))

summary(stan_model2)

tidy(stan_model2, conf.int = TRUE, conf.level = 0.90) %>%
  mutate(term = c("Intercept", 
                  "Percentage Women")) %>% 
  mutate_if(is.numeric, round, 3) %>% 
  rename(Term = term, Estimate = estimate,
         `Standard Deviation` = std.error, 
         `Lower 90% CI` = conf.low, `Upper 90% CI` = conf.high)