## from Chapter 23 of R for Data Science
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

## To compute the distance, first turn the model family into an R function.
## This takes the model parameters and the data as inputs, and gives values
## predicted by the model as output.

model1 <- function(a, data) {
  a[1] + data$x*a[2]
}

model1(c(7, 1.5), sim1)


## this is 30 distances; how do we collapse that into a single number??
## RMS deviation !

measure_distance <- function(mod, data) {
  diff <- data$y - model1(mod,data)
  sqrt(mean(diff^2))
}

measure_distance(c(7,1.5), sim1)  ## 2.67

## Now we can use purrr to compute the distance for all 250 models.
## We need a helper function because our distance function expects
## the model as a numeric vector of length two.

sim1_dist <- function(a1,a2) {
  measure_distance(c(a1,a2), sim1)
}


models <- models %>% mutate(dist = purrr::map2_dbl(a1,a2, sim1_dist))
models

## Let's overlay the 10 best models on the data
## colored by -dist (easy way to make sure the best models/smallest dist)
## get the brightest colors...

ggplot(sim1, aes(x,y)) +
         geom_point(size = 2, color = 'grey30') +
         geom_abline(
           aes(intercept = a1, slope = a2, color = -dist),
               data = filter(models ,rank(dist) <= 10)
)

## We can also think about these models as observations,and visualizing
## with a scatterplot of a1 vs a2, again colored by distance.