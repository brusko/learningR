## tidy time-series analysis
## Matt Dancho

library(tidyverse)
library(tidyquant)  # Loads tidyverse, tidquant, financial pkgs, xts/zoo
library(cranlogs)   # For inspecting package downloads over time

library(zoo)
library(xts)
library(TTR)

## look at trends in package popularity (on CRAN)
## specifically, tidyverse packages

pkgs <- c(
  "tidyr", "lubridate", "dplyr", 
  "broom", "tidyquant", "ggplot2", "purrr", 
  "stringr", "knitr"
)

## using "cran_downloads" from cranlogs pkg

tidyverse_downloads <- cran_downloads(packages = pkgs,
  from     = "2017-01-01",
  to       = "2017-07-31") %>%
  tibble::as_tibble() %>%
  group_by(package)

## plot this using ggplot2

tidyverse_downloads %>% 
  ggplot(aes(x=date, y=count, color = package)) + geom_point() +
  labs(title = 'tidyverse packages: Daily downloads', x = '') +
  facet_wrap(~package, ncol = 3, scale = 'free_y') +
  scale_color_tq() +
  theme_tq() +
  theme(legend.position = 'none')

## we will start with the "Period Apply Functions" from xts
## The period apply functions are helper functions that enable the 
## application of other functions by common intervals. 

## We can see which apply functions will work by investigating the 
## list of available functions returned by tq_transmute_fun_options().

## "apply" functions from xts
tq_transmute_fun_options()$xts %>%
  stringr::str_subset("^apply")

## A SIMPLE CASE: INSPECTING THE AVERAGE DAILY DOWNLOADS BY WEEK.

mean_tidyverse_downloads_w <- tidyverse_downloads %>% 
  tq_transmute(
    select     = count,
    mutate_fun = apply.weekly,
    FUN        = mean,
    na.rm      = TRUE,
    col_rename = "mean_count"
  )

mean_tidyverse_downloads_w

## better looking trends

mean_tidyverse_downloads_w %>%
  ggplot(aes(x = date, y = mean_count, color = package)) +
  geom_point() +
  geom_smooth(method = "loess") + 
  labs(title = "tidyverse packages: Average daily downloads by week", x = "", 
       y = "Mean Daily Downloads by Week") +
  facet_wrap(~ package, ncol = 3, scale = "free_y") +
  expand_limits(y = 0) + 
  scale_color_tq() +
  theme_tq() +
  theme(legend.position="none")


## Custom function to return mean, sd, quantiles
custom_stat_fun <- function(x, na.rm = TRUE, ...) {
  # x     = numeric vector
  # na.rm = boolean, whether or not to remove NA's
  # ...   = additional args passed to quantile
  c(mean    = mean(x, na.rm = na.rm),
    stdev   = sd(x, na.rm = na.rm),
    quantile(x, na.rm = na.rm, ...)) 
}
  

## Testing custom_stat_fun
options(digits = 4)
set.seed(3366)
nums  <- c(10 + 1.5*rnorm(10), NA)
probs <- c(0, 0.025, 0.25, 0.5, 0.75, 0.975, 1)
custom_stat_fun(nums, na.rm = TRUE, probs = probs)

## Now for the fun part
stats_tidyverse_downloads_w <- tidyverse_downloads %>%
  tq_transmute(
    select = count,
    mutate_fun = apply.weekly, 
    FUN = custom_stat_fun,
    na.rm = TRUE,
    probs = probs
  )

stats_tidyverse_downloads_w


## volatility ??

stats_tidyverse_downloads_w %>%
  ggplot(aes(x = date, y = `50%`, color = package)) +
  # Ribbon
  geom_ribbon(aes(ymin = `25%`, ymax = `75%`), 
              color = palette_light()[[1]], fill = palette_light()[[1]], alpha = 0.5) +
  # Points
  geom_point() +
  geom_smooth(method = "loess", se = FALSE) + 
  # Aesthetics
  labs(title = "tidyverse packages: Median daily downloads by week", x = "",
       subtitle = "Range of 1st and 3rd quartile to show volatility",
       y = "Median Daily Downloads By Week") +
  facet_wrap(~ package, ncol = 3, scale = "free_y") +
  expand_limits(y = 0) + 
  scale_color_tq(theme = "dark") +
  theme_tq() +
  theme(legend.position="none")

  
## We can also investigate how the mean and standard deviation relate to each other. 

stats_tidyverse_downloads_w %>%
  ggplot(aes(x = stdev, y = mean, color = package)) +
  geom_point() +
  geom_smooth(method = "lm") + 
  labs(title = "tidyverse packages: Mean vs standard deviation of daily downloads by week") +
  facet_wrap(~ package, ncol = 3, scale = "free") +
  scale_color_tq() +
  theme_tq() +
  theme(legend.position="none")


########################################################################
#### PART 2 - Rolling Functions
########################################################################

## using "rollapply" from zoo

# "roll" functions from zoo
tq_mutate_fun_options()$zoo %>%
  stringr::str_subset("^roll")

# "run" functions from TTR
tq_mutate_fun_options()$TTR %>%
  stringr::str_subset("^run")

## We’ll investigate the rollapply function from the zoo package because 
## it allows us to use custom functions that we create!

# Condensed function options... lot's of 'em
tq_mutate_fun_options() %>%
  str()


## ROLLING MEAN: INSPECTING FAST AND SLOW MOVING AVERAGES

# Rolling mean
tidyverse_downloads_rollmean <- tidyverse_downloads %>%
  tq_mutate(
    # tq_mutate args
    select     = count,
    mutate_fun = rollapply, 
    # rollapply args
    width      = 28,
    align      = "right",
    FUN        = mean,
    # mean args
    na.rm      = TRUE,
    # tq_mutate args
    col_rename = "mean_28"
  ) %>%
  tq_mutate(
    # tq_mutate args
    select     = count,
    mutate_fun = rollapply,
    # rollapply args
    width      = 84,
    align      = "right",
    FUN        = mean,
    # mean args
    na.rm      = TRUE,
    # tq_mutate args
    col_rename = "mean_84"
  )

# ggplot
tidyverse_downloads_rollmean %>%
  ggplot(aes(x = date, y = count, color = package)) +
  # Data
  geom_point(alpha = 0.1) +
  geom_line(aes(y = mean_28), color = palette_light()[[1]], size = 1) +
  geom_line(aes(y = mean_84), color = palette_light()[[2]], size = 1) +
  facet_wrap(~ package, ncol = 3, scale = "free_y") +
  # Aesthetics
  labs(title = "tidyverse packages: Daily Downloads", x = "",
       subtitle = "28 and 84 Day Moving Average") +
  scale_color_tq() +
  theme_tq() +
  theme(legend.position="none")


## to detect momentum. Let’s drop the “count” data from the plots and 
## inspect just the moving averages. What we are looking for are points 
## where the fast trend is above (has momentum) or below (is slowing) the 
## slow trend. In addition, we want to inspect for cross-over, which 
## indicates shifts in trend.

tidyverse_downloads_rollmean %>%
  ggplot(aes(x = date, color = package)) +
  # Data
  # geom_point(alpha = 0.5) +  # Drop "count" from plots
  geom_line(aes(y = mean_28), color = palette_light()[[1]], linetype = 1, size = 1) +
  geom_line(aes(y = mean_84), color = palette_light()[[2]], linetype = 1, size = 1) +
  facet_wrap(~ package, ncol = 3, scale = "free_y") +
  # Aesthetics
  labs(title = "tidyverse packages: Daily downloads", x = "", y = "",
       subtitle = "Zoomed In: 28 and 84 Day Moving Average") +
  scale_color_tq() +
  theme_tq() +
  theme(legend.position="none")


## ROLLING CUSTOM FUNCTIONS

# Custom function to return mean, sd, 95% conf interval
custom_stat_fun_2 <- function(x, na.rm = TRUE) {
  # x     = numeric vector
  # na.rm = boolean, whether or not to remove NA's
  
  m  <- mean(x, na.rm = na.rm)
  s  <- sd(x, na.rm = na.rm)
  hi <- m + 2*s
  lo <- m - 2*s
  
  ret <- c(mean = m, stdev = s, hi.95 = hi, lo.95 = lo) 
  return(ret)
}

## Now for the fun part: performing the “tidy” rollapply. 
## similar to above, except we need to set by.column = FALSE 
## to prevent a “length of dimnames [2]” error. 


# Roll apply using custom stat function
tidyverse_downloads_rollstats <- tidyverse_downloads %>%
  tq_mutate(
    select     = count,
    mutate_fun = rollapply, 
    # rollapply args
    width      = 28,
    align      = "right",
    by.column  = FALSE,
    FUN        = custom_stat_fun_2,
    # FUN args
    na.rm      = TRUE
  )

tidyverse_downloads_rollstats

## (see Bollinger Bands)

tidyverse_downloads_rollstats %>%
  ggplot(aes(x = date, color = package)) +
  # Data
  geom_point(aes(y = count), color = "grey40", alpha = 0.5) +
  geom_ribbon(aes(ymin = lo.95, ymax = hi.95), alpha = 0.4) +
  geom_point(aes(y = mean), size = 1, alpha = 0.5) +
  facet_wrap(~ package, ncol = 3, scale = "free_y") +
  # Aesthetics
  labs(title = "tidyverse packages: Volatility and Trend", x = "",
       subtitle = "28-Day Moving Average with 95% Confidence Interval Bands (+/-2 Standard Deviations)") +
  scale_color_tq(theme = "light") +
  theme_tq() +
  theme(legend.position="none")


######################################################################
####  Part 3 - the Rolling Correlation
######################################################################

## using the "runCor" function from TTR to investigate rolling (dynamic) correlations

library(corrr)
library(cowplot)

## we already have the tidyverse packages download data
## Now we need the total CRAN downloads over time

# Get data for total CRAN downloads
all_downloads <- cran_downloads(from = "2017-01-01", to = "2017-06-30") %>%
  tibble::as_tibble()

# Visualize the downloads
all_downloads %>%
  ggplot(aes(x = date, y = count)) +
  # Data
  geom_point(alpha = 0.5, color = palette_light()[[1]], size = 2) +
  # Aesthetics
  labs(title = "Total CRAN Packages: Daily downloads", x = "",
       subtitle = "2017-01-01 through 2017-06-30",
       caption = "Downloads data courtesy of cranlogs package") +
  scale_y_continuous(labels = scales::comma) +
  theme_tq() +
  theme(legend.position="none")

## Rolling Correlations

## One of the most important calculations in time series analysis is 
## the rolling correlation. Rolling correlations are simply applying 
## a correlation between two time series (say sales of product x and 
## product y) as a rolling window calculation.

## Correlations in time series are very useful because if a relationship 
## exists, you can actually model/predict/forecast using the correlation. 
## However, there’s one issue: a correlation is NOT static! It changes 
## over time. Even the best models can be rendered useless during periods 
## when correlation is low.

# "run" functions from TTR
tq_mutate_fun_options()$TTR %>%
  stringr::str_subset("^run")


# If first arg is x (and no y) --> us tq_mutate()
args(runSD)

# If first two arguments are x and y --> use tq_mutate_xy()
args(runCor)

## Static Correlations

## We’ll use the correlate() and shave() functions from the
## corrr package to output a tidy correlation table. 

# Correlation table
tidyverse_static_correlations <- tidyverse_downloads %>%
  # Data wrangling
  spread(key = package, value = count) %>%
  left_join(all_downloads, by = "date") %>%
  rename(all_cran = count) %>%
  select(-date) %>%
  # Correlation and formating
  correlate() 

# Pretty printing
tidyverse_static_correlations %>%
  shave(upper = F)

## The correlation table is nice, but the outliers don’t exactly 
## jump out. For instance, it’s difficult to see that tidyquant 
## is low compared to the other packages withing the “all_cran” column.

## Fortunately, the corrr package has a nice visualization called a 
## network_plot(). It helps to identify strength of correlation. 

# Network plot
gg_all <- tidyverse_static_correlations %>%
  network_plot(colours = c(palette_light()[[2]], "white", palette_light()[[4]]), legend = TRUE) +
  labs(
    title = "Correlations of tidyverse Package Downloads to Total CRAN Downloads",
    subtitle = "Looking at January through June, tidyquant is a clear outlier"
  ) +
  expand_limits(x = c(-0.75, 0.25), y = c(-0.4, 0.4)) +
  theme_tq() +
  theme(legend.position = "bottom")

gg_all

## We can see that tidyquant has a very low correlation to “all_cran” and the rest 
## of the “tidyverse” packages. This would lead us to believe that tidyquant 
## is trending abnormally with respect to the rest, and thus is possibly not 
## as associated as we think. Is this really the case?

## Rolling Correlations

# Get rolling correlations
tidyverse_rolling_corr <- tidyverse_downloads %>%
  # Data wrangling
  left_join(all_downloads, by = "date") %>%
  select(date, package, count.x, count.y) %>%
  # Mutation
  tq_mutate_xy(
    x          = count.x,
    y          = count.y,
    mutate_fun = runCor, 
    # runCor args
    n          = 30,
    use        = "pairwise.complete.obs",
    # tq_mutate args
    col_rename = "rolling_corr"
  )

# Join static correlations with rolling correlations
tidyverse_static_correlations <- tidyverse_static_correlations %>%
  select(rowname, all_cran) %>%
  rename(package = rowname)

tidyverse_rolling_corr <- tidyverse_rolling_corr %>%
  left_join(tidyverse_static_correlations, by = "package") %>%
  rename(static_corr = all_cran)

# Plot
tidyverse_rolling_corr %>%
  ggplot(aes(x = date, color = package)) +
  # Data
  geom_line(aes(y = static_corr), color = "red") +
  geom_point(aes(y = rolling_corr), alpha = 0.5) +
  facet_wrap(~ package, ncol = 3, scales = "free_y") +
  # Aesthetics
  scale_color_tq() +
  labs(
    title = "tidyverse: 30-Day Rolling Download Correlations, Package vs Total CRAN",
    subtitle = "Relationships are dynamic vs static correlation (red line)",
    x = "", y = "Correlation"
  ) +
  theme_tq() +
  theme(legend.position="none")



# Redrawing Network Plot from April through June
gg_subset <- tidyverse_downloads %>%
  # Filter by date >= April 1, 2017
  filter(date >= ymd("2017-04-01")) %>%
  # Data wrangling
  spread(key = package, value = count) %>%
  left_join(all_downloads, by = "date") %>%
  rename(all_cran = count) %>%
  select(-date) %>%
  # Correlation and formating
  correlate() %>%
  # Network Plot
  network_plot(colours = c(palette_light()[[2]], "white", palette_light()[[4]]), legend = TRUE) +
  labs(
    title = "April through June (Last 3 Months)",
    subtitle = "tidyquant correlation is increasing"
  ) +
  expand_limits(x = c(-0.75, 0.25), y = c(-0.4, 0.4)) +
  theme_tq() +
  theme(legend.position = "bottom")

# Modify the January through June network plot (previous plot)
gg_all <- gg_all +
  labs(
    title = "January through June (Last 6 months)",
    subtitle = "tidyquant is an outlier"
  )

# Format cowplot
cow_net_plots <- plot_grid(gg_all, gg_subset, ncol = 2)
title <- ggdraw() + 
  draw_label(label = 'tidyquant is getting "tidy"-er',
             fontface = 'bold', size = 18)
cow_out <- plot_grid(title, cow_net_plots, ncol=1, rel_heights=c(0.1, 1))
cow_out


