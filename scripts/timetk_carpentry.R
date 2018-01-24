library(tidyquant)
library(timetk)

beer_sales_tbl <- tq_get("S4248SM144NCEN", get = "economic.data", from = "2010-01-01", to = "2016-12-31")
beer_sales_tbl

## visualize

beer_sales_tbl %>% 
  ggplot(aes(x=date, y=price)) +
  geom_line(col = palette_light()[1]) +
  geom_point(col = palette_light()[1]) +
  geom_ma(ma_fun = SMA, n=12, size=1) +
  theme_tq() +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  labs(title = "Beer Sales: 2007 through 2016")

## Add a time series signature (~ timestamp info expanded column-wise int a feature set)
##
## We can quickly get a feel for the time series using tk_index() to extract the index 
## and tk_get_timeseries_summary() to retrieve summary information of the index. 

beer_sales_tbl %>% 
  tk_index() %>% 
  tk_get_timeseries_summary() %>% 
  glimpse()

## step 1. Augment the time series signature
beer_sales_tbl_aug <- beer_sales_tbl %>% 
  tk_augment_timeseries_signature()

beer_sales_tbl_aug

## step2. Model

fit_lm <- lm(price ~., data=select(beer_sales_tbl_aug, -c(date, diff)))

## step 3. Build future (new) data
## (Use tk_index() to extact data)

beer_sales_idx <- beer_sales_tbl %>% tk_index()
tail(beer_sales_idx)

## Make a future index from the existing index with tk_make_future_timeseries. 

future_idx <- beer_sales_idx %>% tk_make_future_timeseries(n_future = 12)
future_idx
 

## From the future index, use tk_get_timeseries_signature() to turn index 
## into time signature data frame.

new_data_tbl <- future_idx %>% tk_get_timeseries_signature()

## Predict the new data

pred <- predict(fit_lm, newdata = select(new_data_tbl, -c(index, diff)))

predictions_tbl <- tibble(date = future_idx,
                          value = pred)
predictions_tbl

## step 5. Compare actual vs predicted
## use tq_get to retrieve the actual data (only the first several months are available ...)

actuals_tbl <- tq_get("S4248SM144NCEN", get = "economic.data", from = "2017-01-01", to = "2017-12-31")
