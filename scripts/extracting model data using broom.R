## extracting model data using broom

library(tidyverse)
library(broom)

df.h <- data.frame( 
  hour     = factor(rep(1:24, each = 21)),
  price    = runif(504, min = -10, max = 125),
  wind     = runif(504, min = 0, max = 2500),
  temp     = runif(504, min = - 10, max = 25)  
)

df.h <- tbl_df(df.h)
df.h <- group_by(df.h, hour)

group_size(df.h) # checks out, 21 obs. for each factor variable

# different attempts:  DOESN'T WORK
reg.models <- do(df.h, formula = price ~ wind + temp)

reg.models <- do(df.h, .f = lm(price ~ wind + temp, data = df.h))

### ans

dfHour = df.h %>% group_by(hour) %>%
  do(fitHour = lm(price ~ wind + temp, data = .))

# get the coefficients by group in a tidy data_frame
dfHourCoef = tidy(dfHour, fitHour)
dfHourCoef

# augment
# get the predicitons by group in a tidy manner
dfHoursPred <- augment(dfHour, fitHour)


# glance
# get the summary statistics by group in a tidy data_frame
dfHourSumm = glance(dfHour, fitHour)
dfHourSumm


#############################$$$$$$$$$$$$%%%%%%%%%%%%###############

## can we draw the lines for all 24 groups?
## or maybe one or two

str(dfHourCoef)
