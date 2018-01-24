## demo_week timetk

# Load libraries
library(timetk)     # Toolkit for working with time series in R
library(tidyquant)  # Loads tidyverse, financial pkgs, used to get data


# Beer, Wine, Distilled Alcoholic Beverages, in Millions USD
beer_sales_tbl <- tq_get("S4248SM144NCEN", 
                         get = "economic.data", 
                         from = "2010-01-01", 
                         to = "2016-12-31")

beer_sales_tbl


# Plot Beer Sales

## We’ll use tidyquant charting tools: mainly 
## geom_ma(ma_fun = SMA, n = 12) to add a 12-period 
## simple moving average to get an idea of the trend. 
## We can also see there appears to be both trend (moving 
## average is increasing in a relatively linear pattern) 
## and some seasonality (peaks and troughs tend to occur 
## at specific months).

# Plot Beer Sales
beer_sales_tbl %>%
  ggplot(aes(date, price)) +
  geom_line(col = palette_light()[1]) +
  geom_point(col = palette_light()[1]) +
  geom_ma(ma_fun = SMA, n = 12, size = 1) +
  theme_tq() +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  labs(title = "Beer Sales: 2007 through 2016")



## We’ve split this demo into two parts. 
## First, we’ll follow a workflow for time series machine learning. 
## Second, we’ll check out coercion tools.

## Part 1

## 	Key Insight: The time series signature ~ timestamp information 
## expanded column-wise into a feature set ~ is used to perform 
## machine learning.

## Objective: We’ll predict the next 12 months of data for the time series 
## using the time series signature.

##  We’ll go through a workflow that can be used to perform time series 
## machine learning. You’ll see how several timetk functions can help with 
## this process. We’ll do machine learning with a simple lm() linear regression, 
## and you will see how powerful and accurate this can be when a time series 
## signature is used. 

## STEP 0: REVIEW DATA

# Starting point
beer_sales_tbl

## We can quickly get a feel for the time series using tk_index() 
## to extract the index and tk_get_timeseries_summary() 
## to retrieve summary information of the index. We use glimpse() 
## to output in a nice format for review.

beer_sales_tbl %>%
  tk_index() %>%
  tk_get_timeseries_summary() %>%
  glimpse()


## STEP 1: AUGMENT TIME SERIES SIGNATURE
## The tk_augment_timeseries_signature() function expands out the 
## timestamp information column-wise into a machine learning feature set, 
## adding columns of time series information to the original data frame.

# Augment (adds data frame columns)
beer_sales_tbl_aug <- beer_sales_tbl %>%
  tk_augment_timeseries_signature()

beer_sales_tbl_aug

## STEP 2: MODEL
## Apply any regression model to the data. We’ll use lm(). 
## Note that we drop the date and diff columns. Most algorithms do not 
## work with dates, and the diff column is not useful for machine 
## learning (it’s more useful for finding time gaps in the data).

# linear regression model used, but can use any model
fit_lm <- lm(price ~ ., data = select(beer_sales_tbl_aug, -c(date, diff)))

summary(fit_lm)


## STEP 3: BUILD FUTURE (NEW) DATA
## Use tk_index() to extract the index.

# Retrieves the timestamp information
beer_sales_idx <- beer_sales_tbl %>%
  tk_index()

tail(beer_sales_idx)


## Make a future index from the existing index with 
## tk_make_future_timeseries. The function internally checks 
## the periodicity and returns the correct sequence. 


# Make future index
future_idx <- beer_sales_idx %>%
  tk_make_future_timeseries(n_future = 12)

future_idx


## From the future index, use tk_get_timeseries_signature() 
## to turn index into time signature data frame.

new_data_tbl <- future_idx %>%
  tk_get_timeseries_signature()

new_data_tbl


## STEP 4: PREDICT THE NEW DATA
## Use the predict() function for your regression model. Note that 
## we drop the index and diff columns, the same as before when using 
## the lm() function.


# Make predictions
pred <- predict(fit_lm, newdata = select(new_data_tbl, -c(index, diff)))

predictions_tbl <- tibble(
  date  = future_idx,
  value = pred
)

predictions_tbl


## STEP 5: COMPARE ACTUAL VS PREDICTIONS
## We can use tq_get() to retrieve the actual data. Note that we don’t 
## have all of the data for comparison, but we can at least compare 
## the first several months of actual values.

actuals_tbl <- tq_get("S4248SM144NCEN", 
                      get = "economic.data", 
                      from = "2017-01-01", 
                      to = "2017-12-31")

## Visualize our forecast

# Plot Beer Sales Forecast
beer_sales_tbl %>%
  ggplot(aes(x = date, y = price)) +
  # Training data
  geom_line(color = palette_light()[[1]]) +
  geom_point(color = palette_light()[[1]]) +
  # Predictions
  geom_line(aes(y = value), color = palette_light()[[2]], data = predictions_tbl) +
  geom_point(aes(y = value), color = palette_light()[[2]], data = predictions_tbl) +
  # Actuals
  geom_line(color = palette_light()[[1]], data = actuals_tbl) +
  geom_point(color = palette_light()[[1]], data = actuals_tbl) +
  # Aesthetics
  theme_tq() +
  labs(title = "Beer Sales Forecast: Time Series Machine Learning",
       subtitle = "Using basic multivariate linear regression can yield accurate results")


## We can investigate the error on our test set (actuals vs predictions).

# Investigate test error
error_tbl <- left_join(actuals_tbl, predictions_tbl) %>%
  rename(actual = price, pred = value) %>%
  mutate(
    error     = actual - pred,
    error_pct = error / actual
  ) 

error_tbl


## And we can calculate a few residuals metrics. The MAPE error 
## is approximately 4.5% from the actual value, which is pretty good 
## for a simple multivariate linear regression. A more complex 
## algorithm could produce more accurate results.

# Calculating test error metrics
test_residuals <- error_tbl$error
test_error_pct <- error_tbl$error_pct * 100 # Percentage error

me   <- mean(test_residuals, na.rm=TRUE)
rmse <- mean(test_residuals^2, na.rm=TRUE)^0.5
mae  <- mean(abs(test_residuals), na.rm=TRUE)
mape <- mean(abs(test_error_pct), na.rm=TRUE)
mpe  <- mean(test_error_pct, na.rm=TRUE)

tibble(me, rmse, mae, mape, mpe) %>% glimpse()
