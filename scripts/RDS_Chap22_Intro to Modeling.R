## from Chapter 22 of R for Data Science
## Model Basics

library(modelr)   ## includes sim1 data set
options(na.action = na.warn)

# EDA tools
library(tidyverse)


## another way to generate a sim data set, linear with wiggles...
## simple, used to help understand basics of modeling...

true_model <- function(x) {
  1 + 2*x + rnorm(length(x), sd=2.5)
}

sim <- data_frame(x = seq(0,10,length = 20),
                 y = true_model(x)
)

##########################################

## how are x and y related?
ggplot(sim1, aes(x, y)) + geom_point()

## using a linear model, generate a bunch (250) of models 
## and overlay them on the data.
## y = a_1 * x + a_2 

models <- tibble(
  a1 = runif(250, -20, 40),   ## y-intercept
  a2 = runif(250, -5, 5)      ## slope
)

ggplot(sim1, aes(x, y)) + 
  geom_abline(aes(intercept = a1, slope = a2), data = models, alpha = 1/4) +
  geom_point() 

## how do we find the "good" models?
## minimize the distance from the data to the line...

