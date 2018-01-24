## demo_week tidyquant

# Load libraries
library(tidyquant) # Loads tidyverse, financial pkgs, used to get and manipulate data


## Getting Data: tq_get

# Get Stock Prices from Yahoo! Finance

# Create a vector of stock symbols
FANG_symbols <- c("FB", "AMZN", "NFLX", "GOOG")

# Pass symbols to tq_get to get daily prices
FANG_data_d <- FANG_symbols %>%
  tq_get(get = "stock.prices", from = "2014-01-01", to = "2016-12-31")

# Show the result
FANG_data_d


# Plot data
FANG_data_d %>%
  ggplot(aes(x = date, y = adjusted, color = symbol)) + 
  geom_line() +
  facet_wrap(~ symbol, ncol = 2, scales = "free_y") +
  theme_tq() +
  scale_color_tq() +
  labs(title = "Visualize Financial Data")


# Economic Data from the FRED

# Create a vector of FRED symbols
FRED_symbols <- c('ETOTALUSQ176N',    # All housing units
                  'EVACANTUSQ176N',   # Vacant
                  'EYRVACUSQ176N',    # Year-round vacant
                  'ERENTUSQ176N'      # Vacant for rent
)

# Pass symbols to tq_get to get economic data
FRED_data_m <- FRED_symbols %>%
  tq_get(get="economic.data", from = "2001-04-01")

# Show results
FRED_data_m


# Plot data
FRED_data_m %>%
  ggplot(aes(x = date, y = price, color = symbol)) + 
  geom_line() +
  facet_wrap(~ symbol, ncol = 2, scales = "free_y") +
  theme_tq() +
  scale_color_tq() +
  labs(title = "Visualize Economic Data")



## MUTATING DATA: TQ_TRANSMUTE AND TQ_MUTATE

## The tq_transmute() and tq_mutate() functions are used 
## to apply xts, zoo, and quantmod functions in a “tidy” way. 

## The difference between tq_transmute() and tq_mutate() is that 
## tq_transmute() returns a new data frame whereas tq_mutate() grows 
## the existing data frame width-wise (i.e. adds columns). The 
## tq_transmute() function is most useful when periodicity changes the 
## number of rows in the data.

## Here’s an example of changing the periodicity from daily to monthly. 
## You need to use tq_transmute() for this operation because the number 
## of rows changes.

# Change periodicity from daily to monthly using to.period from xts

FANG_data_m <- FANG_data_d %>%
  group_by(symbol) %>%
  tq_transmute(
    select      = adjusted,
    mutate_fun  = to.period,
    period      = "months"
  )

FANG_data_m


## A simple reason you might want to perform a periodicity change is 
## to reduce the amount of data. !! WATCH FOR TIBBLETIME !!

## BEFORE TRANSFORMATION - TOO MUCH DATA
# Daily data

FANG_data_d %>%
  ggplot(aes(date, adjusted, color = symbol)) +
  geom_point() +
  geom_line() +
  facet_wrap(~ symbol, ncol = 2, scales = "free_y") +
  scale_color_tq() +
  theme_tq() +
  labs(title = "Before transformation: Too Much Data")


## AFTER TRANSFORMATION - EASY TO UNDERSTAND
## Much clearer when changed to a monthly scale via tq_transmute().

# Monthly data
FANG_data_m %>%
  ggplot(aes(date, adjusted, color = symbol)) +
  geom_point() +
  geom_line() +
  facet_wrap(~ symbol, ncol = 2, scales = "free_y") +
  scale_color_tq() +
  theme_tq() +
  labs(title = "After transformation: Easier to Understand")

## TQ_MUTATE

## The tq_mutate() function returns the existing data frame 
## column-binded with the output of the xts-based operation. 
## Because of this, tq_mutate() is most useful when the number 
## of columns returned is more than one (dplyr::mutate() doesn’t 
## work in these situations).

## LAGS WITH TQ_MUTATE
## An example of this is with lag.xts. Typically we want more 
## than one lag, which is where tq_mutate() shines. We’ll get 
## the first five lags plus the original data.

# Lags - Get first 5 lags

# Pro Tip: Make the new column names first, then add to the 'col_rename' arg
column_names <- paste0("lag", 1:5)

# First five lags are output for each group of symbols
FANG_data_d %>%
  select(symbol, date, adjusted) %>%
  group_by(symbol) %>%
  tq_mutate(
    select     = adjusted,
    mutate_fun = lag.xts,
    k          = 1:5,
    col_rename = column_names
  )



## ROLLING FUNCTIONS WITH TQ_MUTATE
## Another example is applying a rolling function via the 
## xts-based roll.apply(). Let’s apply the quantile() 
## function to get rolling quantiles. We’ll specify the 
## following arguments for each function:
  
# Rolling quantile
FANG_data_d %>%
  select(symbol, date, adjusted) %>%
  group_by(symbol) %>%
  tq_mutate(
    select     = adjusted,
    mutate_fun = rollapply,
    width      = 5,
    by.column  = FALSE,
    FUN        = quantile,
    probs      = c(0, 0.025, 0.25, 0.5, 0.75, 0.975, 1),
    na.rm      = TRUE
  ) %>% 
  ggplot(aes(date, X97.5., color = symbol)) +
  geom_point() +
  geom_line() +
  facet_wrap(~ symbol, ncol = 2, scales = "free_y") +
  scale_color_tq() +
  theme_tq()


