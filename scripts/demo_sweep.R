### demo_week sweep

## http://www.business-science.io/code-tools/2017/10/25/demo_week_sweep.html 

## SWEEP
## sweep is used for tidying the forecast package workflow. 

## An added benefit to sweep and timetk is if the ts-objects are created from 
## time-based tibbles (tibbles with date or datetime index), the date or datetime 
##information is carried through the forecasting process as a timetk index attribute. 

library(sweep)      # Broom-style tidiers for the forecast package
library(forecast)   # Forecasting models and predictions package
library(tidyquant)  # Loads tidyverse, financial pkgs, used to get data
library(timetk)     # Functions working with time series


## DATA (Beer, again)

# Beer, Wine, Distilled Alcoholic Beverages, in Millions USD
beer_sales_tbl <- tq_get("S4248SM144NCEN", 
                         get = "economic.data", 
                         from = "2010-01-01", 
                         to = "2016-12-31")

beer_sales_tbl

## Visualization is particularly important for time series analysis 
## and forecasting.

## We’ll use tidyquant charting tools: mainly geom_ma(ma_fun = SMA, n = 12) 
## to add a 12-period simple moving average to get an idea of the trend. 

# Plot Beer Sales
beer_sales_tbl %>%
  ggplot(aes(date, price)) +
  geom_line(col = palette_light()[1]) +
  geom_point(col = palette_light()[1]) +
  geom_ma(ma_fun = SMA, n = 12, size = 1) +
  theme_tq() +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  labs(title = "Beer Sales: 2007 through 2016")


## We’ll use the combination of forecast and sweep to perform tidy forecasting.

## Forecasting using the forecast package is a non-tidy process 
## that involves ts class objects. --> use sweep to tidy up models and forecasts.

## ARIMA MODEL (demo)

## STEP 1: CREATE TS OBJECT
## Use timetk::tk_ts() to convert from tbl to ts. 

## Here’s how to convert. Remember that ts-objects are regular time series 
## so we need to specify a start and a freq.

# Convert from tbl to ts
beer_sales_ts <- tk_ts(beer_sales_tbl, start = 2010, freq = 12)

beer_sales_ts


## We can check that the ts-object has a timetk_idx.
has_timetk_idx(beer_sales_ts)


## STEP 2A: MODEL USING ARIMA
## We can use the auto.arima() function from the forecast package to model the time series.

# Model using auto.arima
fit_arima <- auto.arima(beer_sales_ts)

fit_arima


## STEP 2B: TIDY THE MODEL
## Like broom tidies the stats package, we can use sweep functions to tidy the ARIMA model. 
## Let’s examine three tidiers, which enable tidy model evaluation:
## •	sw_tidy(): Used to retrieve the model coefficients
## •	sw_glance(): Used to retrieve model description and training set accuracy metrics
## •	sw_augment(): Used to get model residuals

## SW_TIDY
## The sw_tidy() function returns the model coefficients in a tibble (tidy data frame).

# sw_tidy - Get model coefficients
sw_tidy(fit_arima)

## SW_GLANCE
## The sw_glance() function returns the training set accuracy measures in a tibble (tidy data frame). 
## We use glimpse to aid in quickly reviewing the model metrics.

# sw_glance - Get model description and training set accuracy measures
sw_glance(fit_arima) %>%
  glimpse()


## SW_AUGMENT
## The sw_augument() function helps with model evaluation. We get the “.actual”, “.fitted” and “.resid” columns, 
## which are useful in evaluating the model against the training data. Note that we can pass timetk_idx = TRUE 
## to return the original date index.

# sw_augment - get model residuals
sw_augment(fit_arima, timetk_idx = TRUE)

## We can visualize the residual diagnostics for the training data to make sure there is no pattern leftover.

# Plotting residuals
sw_augment(fit_arima, timetk_idx = TRUE) %>%
  ggplot(aes(x = index, y = .resid)) +
  geom_point() + 
  geom_hline(yintercept = 0, color = "red") + 
  labs(title = "Residual diagnostic") +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  theme_tq()


## STEP 3: MAKE A FORECAST
## Make a forecast using the forecast() function.

fcast_arima <- forecast(fit_arima, h = 12)

## One problem is the forecast output is not “tidy”. We need it in a data frame 
## if we want to work with it using the tidyverse functionality. The class is “forecast”, 
## which is a ts-based-object (its contents are ts-objects).

class(fcast_arima)

## STEP 4: TIDY THE FORECAST WITH SWEEP
## We can use sw_sweep() to tidy the forecast output. As an added benefit, if the forecast-object 
## has a timetk index, we can use it to return a date/datetime index as opposed to regular index 
## from the ts-based-object.

# Check if object has timetk index 
has_timetk_idx(fcast_arima)

## Now, use sw_sweep() to tidy the forecast output. Internally it projects a future time series 
## index based on “timetk_idx” that is an attribute (this all happens because we created the ts-object 
## originally with tk_ts() in Step 1). 

## Bottom Line: This means we can finally use dates with the forecast package (as opposed to the 
## regularly spaced numeric index that the ts-system uses)!!!

# sw_sweep - tidies forecast output
fcast_tbl <- sw_sweep(fcast_arima, timetk_idx = TRUE)

fcast_tbl


## STEP 5: COMPARE ACTUALS VS PREDICTIONS
## We can use tq_get() to retrieve the actual data. Note that we don’t have all of the data for comparison, 
## but we can at least compare the first several months of actual values.

actuals_tbl <- tq_get("S4248SM144NCEN", get = "economic.data", from = "2017-01-01", to = "2017-12-31")

## Notice that we have the entire forecast in a tibble. We can now more easily visualize the forecast.

# Visualize the forecast with ggplot
fcast_tbl %>%
  ggplot(aes(x = index, y = price, color = key)) +
  # 95% CI
  geom_ribbon(aes(ymin = lo.95, ymax = hi.95), 
              fill = "#D5DBFF", color = NA, size = 0) +
  # 80% CI
  geom_ribbon(aes(ymin = lo.80, ymax = hi.80, fill = key), 
              fill = "#596DD5", color = NA, size = 0, alpha = 0.8) +
  # Prediction
  geom_line() +
  geom_point() +
  # Actuals
  geom_line(aes(x = date, y = price), color = palette_light()[[1]], data = actuals_tbl) +
  geom_point(aes(x = date, y = price), color = palette_light()[[1]], data = actuals_tbl) +
  # Aesthetics
  labs(title = "Beer Sales Forecast: ARIMA", x = "", y = "Thousands of Tons",
       subtitle = "sw_sweep tidies the auto.arima() forecast output") +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  scale_color_tq() +
  scale_fill_tq() +
  theme_tq()


## We can investigate the error on our test set (actuals vs predictions).

# Investigate test error 
error_tbl <- left_join(actuals_tbl, fcast_tbl, by = c("date" = "index")) %>%
  rename(actual = price.x, pred = price.y) %>%
  select(date, actual, pred) %>%
  mutate(
    error     = actual - pred,
    error_pct = error / actual
  ) 

error_tbl

## And we can calculate a few residuals metrics. The MAPE error is approximately 4.3% 
## from the actual value, which is slightly better than the simple linear regression from 
## the timetk demo. Note that the RMSE is slightly worse.

# Calculate test error metrics
test_residuals <- error_tbl$error
test_error_pct <- error_tbl$error_pct * 100 # Percentage error

me   <- mean(test_residuals, na.rm=TRUE)
rmse <- mean(test_residuals^2, na.rm=TRUE)^0.5
mae  <- mean(abs(test_residuals), na.rm=TRUE)
mape <- mean(abs(test_error_pct), na.rm=TRUE)
mpe  <- mean(test_error_pct, na.rm=TRUE)

tibble(me, rmse, mae, mape, mpe) %>% glimpse()


