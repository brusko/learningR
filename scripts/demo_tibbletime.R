###  demo_week tibbletime

## http://www.business-science.io/code-tools/2017/10/26/demo_week_tibbletime.html

# Get tibbletime version with latest features
## This is good to do as tibbletime is new and changing rapidly
devtools::install_github("business-science/tibbletime")


# Load libraries
library(tibbletime) # Future of tidy time series analysis
library(tidyquant)  # Loads tidyverse, tq_get()

## get Data using tq_get()

# Stock Prices from Yahoo! Finance
FANG_symbols <- c("FB", "AMZN", "NFLX", "GOOG")

FANG_tbl_d <- FANG_symbols %>%
  tq_get(get = "stock.prices", from = "2014-01-01", to = "2016-12-31") 

FANG_tbl_d <- FANG_tbl_d %>%
  group_by(symbol)

FANG_tbl_d

#### Set up a function to be used often

# Setup plotting function that can be reused later:

ggplot_facet_by_symbol <- function(data, x, y, group = NULL) {
  
  # Setup expressions
  x_expr     <- rlang::enquo(x)
  y_expr     <- rlang::enquo(y)
  group_expr <- rlang::enquo(group)
  
  if (group_expr == ~NULL) { 
    # No groups
    g <- data %>%
      ggplot(aes(x = rlang::eval_tidy(rlang::`!!`(x_expr)), 
                 y = rlang::eval_tidy(rlang::`!!`(y_expr)), 
                 color = symbol)) +
      labs(x = quo_name(x_expr),
           y = quo_name(y_expr))
  } else {
    # Deal with groups
    g <- data %>%
      ggplot(aes(x = rlang::eval_tidy(rlang::`!!`(x_expr)), 
                 y = rlang::eval_tidy(rlang::`!!`(y_expr)), 
                 color = symbol,
                 group = rlang::eval_tidy(rlang::`!!`(group_expr)) 
      )
      )  +
      labs(x = quo_name(x_expr),
           y = quo_name(y_expr),
           group = quo_name(group_expr))
  }
  
  # Add faceting and theme
  g <- g +
    geom_line() +
    facet_wrap(~ symbol, ncol = 2, scales = "free_y") +
    scale_color_tq() +
    theme_tq()
  
  return(g)
}

## We can quickly visualize our data with our plotting function, 
## ggplot_facet_by_symbol. 

# Plot adjusted vs date
FANG_tbl_d %>%
  ggplot_facet_by_symbol(date, adjusted) +
  labs(title = "FANG Stocks: Adjusted Prices 2014 through 2016")


## Now the tibbletime DEMO

## •	time_filter: Tidy Time Filtering
## •	time_summarise: Tidy Time-Based Summarization
## •	as_period: Flexible Periodicity Change
## •	rollify: Turn Any Function Into A Rolling Function

## Before we can use these new functions, we need to create a tbl_time object. 
## The new class operates almost identically to a normal tibble object. 
## However, under the hood it tracks the time information.

# Convert to tbl_time
FANG_tbl_time_d <- FANG_tbl_d %>%
  as_tbl_time(index = date) 

FANG_tbl_time_d

## Note that “Index: date” informs us that the ”time tibble” 
## is initialized properly (even though it looks the same.)


# Plot the tbl_time object (same as tbl object)
FANG_tbl_time_d %>%
  ggplot_facet_by_symbol(date, adjusted) +
  labs(title = "Working with tbltime: Reacts same as tbl class")


## Special time series functions

############################# time_filter()
## The time_filter() function is used to succinctly filter a tbl_time object by date. 
## It uses a function format (e.g. “date_operator_start ~ date_operator_end”). 
## functoinal notation is extremely flexible

# time_filter by day
FANG_tbl_time_d %>%
  time_filter(2014-06-01 ~ 2014-06-15) %>%
  # Plotting
  ggplot_facet_by_symbol(date, adjusted) +
  geom_point() +
  labs(title = "Time Filter: Use functional notation to quickly subset by time",
       subtitle = "2014-06-01 ~ 2014-06-15")

# time_filter by month
FANG_tbl_time_d %>%
  time_filter(~ 2014-03) %>%
  # Plotting
  ggplot_facet_by_symbol(date, adjusted) +
  geom_point() +
  labs(title = "Time Filter: Use shorthand for even easier subsetting",
       subtitle = "~ 2014-03")


# time filter bracket [] notation (to get all dates in 2014, for each of the groups)
FANG_tbl_time_d[~ 2014] %>%
  # Plotting
  ggplot_facet_by_symbol(date, adjusted) +
  labs(title = "Time Filter: Bracket Notation Works Too",
       subtitle = "FANG_tbl_time_d[~ 2014]")


############################# time_summarise()
## The time_summarise() function is similar to dplyr::summarise 
## but with the added benefit of being able to summarise by a time period 
## such as “yearly” or “monthly”

# Summarize functions over time periods such as weekly, monthly, etc
FANG_tbl_time_d %>%
  time_summarise(period = "yearly",
                 adj_min   = min(adjusted),
                 adj_max   = max(adjusted),
                 adj_range = adj_max - adj_min
  )

## Can even use functional notation to get things like
## every two months (2~m) or evey 20 days (20~d)

# Summarize by 2-Month periods
FANG_min_max_by_2m <- FANG_tbl_time_d %>%
  time_summarise(period = 2 ~ m,
                 adj_min   = min(adjusted),
                 adj_max   = max(adjusted),
                 adj_med   = median(adjusted)
  ) %>%
  gather(key = key, value = value, adj_min, adj_max, adj_med) 

# Plot using our plotting function, grouping by key (min, max, and median)
FANG_min_max_by_2m %>%
  ggplot_facet_by_symbol(date, value, group = key) +
  geom_point() +
  labs(title = "Summarizing Data By 2-Months (Bi-Monthly)",
       subtitle = "2~m")

############################# as_period()
## The next function, as_period(), enables changing the period of a tbl_time object. 
## flexible with funtional notation

# Convert from daily to monthly periodicity
FANG_tbl_time_d %>%
  as_period(period = "month") %>%
  # Plotting
  ggplot_facet_by_symbol(date, adjusted) +
  labs(title = "Periodicity Change from Daily to Monthly") +
  geom_point()

# Convert from daily to bi-monthly periodicity
FANG_tbl_time_d %>%
  as_period(period = 2~m) %>%
  # Plotting
  ggplot_facet_by_symbol(date, adjusted) +
  labs(title = "Periodicity Change to Daily to Bi-Monthly",
       subtitle = "2~m") +
  geom_point()


# What about quarterly. Set period = 3~m
FANG_tbl_time_d %>%
  as_period(period = 3~m) %>%
  # Plotting
  ggplot_facet_by_symbol(date, adjusted) +
  labs(title = "Periodicity Change to Daily to Bi-Annually",
       subtitle = "6~m") +
  geom_point()


############################# rollify()
## The rollify() function is an adverb (a special type of function in the 
## tidyverse that modifies another function). What rollify() does is turn any 
## function into a rolling version of itself.

# Rolling 60-day mean
roll_mean_60 <- rollify(mean, window = 60)

FANG_tbl_time_d %>%
  mutate(mean_60 = roll_mean_60(adjusted)) %>%
  select(-c(open:volume)) %>%
  # Plot
  ggplot_facet_by_symbol(date, adjusted) +
  geom_line(aes(y = mean_60), color = palette_light()[[6]]) +
  labs(title = "Rolling 60-Day Mean with rollify")


## can get more complicated rolling function, such as correlations
## Use the functional form .f = ~ fun(.x, .y, ...) within rollify().

# Rolling correlation
roll_corr_60 <- rollify(~ cor(.x, .y, use = "pairwise.complete.obs"), window = 60)

FANG_tbl_time_d %>%
  mutate(cor_60 = roll_corr_60(open, close)) %>%
  select(-c(open:adjusted)) %>%
  # Plot
  ggplot_facet_by_symbol(date, cor_60) +
  labs(title = "Rollify: 60-Day Rolling Correlation Between Open and Close Prices")


## We can even return multiple results. For example, we can create a rolling quantile.

## First, create a function that returns a tibble of quantiles.

# Quantile tbl function
quantile_tbl <- function(x) {
  q <- quantile(x) 
  tibble(
    quantile_name  = names(q),
    quantile_value = q
  )
}

# Test the function
quantile_tbl(1:100)


## Next, use rollify to create a rolling version. 
## We set unlist = FALSE to return a list-column.

# Rollified quantile function
roll_quantile_60 <- rollify(quantile_tbl, window = 60, unlist = FALSE)


## Next, apply the rolling quantile function within mutate() to get a rolling quantile. 
## Make sure you select(), filter() and unnest() to remove unnecessary columns, 
## filter NA values, and unnest the list-column (“rolling_quantile”). 
## Each date now has five values for each quantile.

# Apply rolling quantile 
FANG_quantile_60 <- FANG_tbl_time_d %>%
  mutate(rolling_quantile = roll_quantile_60(adjusted)) %>%
  select(-c(open:adjusted)) %>%
  filter(!is.na(rolling_quantile)) %>%
  unnest()

FANG_quantile_60

## Finally, we can plot the results.

FANG_quantile_60 %>%
  ggplot_facet_by_symbol(date, quantile_value, group = quantile_name) +
  labs(title = "Rollify: Create Rolling Quantiles")

