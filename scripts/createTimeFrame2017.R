## script to get time signature for 2017

library(tidyquant)
library(timetk)

FB_tbl <- FANG %>%
      filter(symbol == "FB")

idx <- tk_index(FB_tbl)

idx_future <- tk_make_future_timeseries(idx, n_future = 366)

day <- 1:366
df <- data.frame(day, idx_future)

TimeFrame <- tk_augment_timeseries_signature(df)

TimeFrame <- TimeFrame %>% rename(date=idx_future, UnixTime=index.num) %>% dplyr(select(date, everything))

## !! Need to correct for Central Time...

## !! And need to correcty for Daylight Savings Time
