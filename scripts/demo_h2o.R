### playing with H2O

## installation, once
##@@ pkgs <- c("statmod","RCurl","jsonlite")
##@@ 
##@@ for (pkg in pkgs) {
##@@   if (! (pkg %in% rownames(installed.packages()))) { install.packages(pkg) }
##@@ }
##@@ 
##@@ install.packages("h2o", type="source", repos="https://h2o-release.s3.amazonaws.com/h2o/rel-weierstrass/7/R")

library(h2o)        # Awesome ML Library
library(timetk)     # Toolkit for working with time series in R
library(tidyquant)  # Loads tidyverse, financial pkgs, used to get data

# Beer, Wine, Distilled Alcoholic Beverages, in Millions USD
beer_sales_tbl <- tq_get("S4248SM144NCEN", get = "economic.data", from = "2010-01-01", to = "2017-10-27")

beer_sales_tbl

## Visualization is particularly important for time series analysis and forecasting, 
## and it’s a good idea to identify spots where we will split the data into training, 
## test and validation sets.


# Plot Beer Sales with train, validation, and test sets shown
beer_sales_tbl %>%
  ggplot(aes(date, price)) +
  # Train Region
  annotate("text", x = ymd("2012-01-01"), y = 7000,
           color = palette_light()[[1]], label = "Train Region") +
  # Validation Region
  geom_rect(xmin = as.numeric(ymd("2016-01-01")), 
            xmax = as.numeric(ymd("2016-12-31")),
            ymin = 0, ymax = Inf, alpha = 0.02,
            fill = palette_light()[[3]]) +
  annotate("text", x = ymd("2016-07-01"), y = 7000,
           color = palette_light()[[1]], label = "Validation\nRegion") +
  # Test Region
  geom_rect(xmin = as.numeric(ymd("2017-01-01")), 
            xmax = as.numeric(ymd("2017-08-31")),
            ymin = 0, ymax = Inf, alpha = 0.02,
            fill = palette_light()[[4]]) +
  annotate("text", x = ymd("2017-05-01"), y = 7000,
           color = palette_light()[[1]], label = "Test\nRegion") +
  # Data
  geom_line(col = palette_light()[1]) +
  geom_point(col = palette_light()[1]) +
  geom_ma(ma_fun = SMA, n = 12, size = 1) +
  # Aesthetics
  theme_tq() +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  labs(title = "Beer Sales: 2007 through 2017",
       subtitle = "Train, Validation, and Test Sets Shown") 

## DEMO
## We’ll go through a workflow that can be used to perform time series machine learning.

## STEP 0: REVIEW DATA

# Starting point
beer_sales_tbl %>% glimpse()

## STEP 1: AUGMENT TIME SERIES SIGNATURE
## The tk_augment_timeseries_signature() function expands out the timestamp information 
## column-wise into a machine learning feature set, adding columns of time series information 
## to the original data frame. 
## There are now 30 features, not all important, but some will be.

# Augment (adds data frame columns)
beer_sales_tbl_aug <- beer_sales_tbl %>%
  tk_augment_timeseries_signature()

beer_sales_tbl_aug %>% glimpse()


## STEP 2: PREP THE DATA FOR H2O
## We need to prepare the data in a format for H2O. First, let’s remove any unnecessary columns 
## such as dates or those with missing values, and change the ordered classes to plain factors. 
## We prefer dplyr operations for these steps.

beer_sales_tbl_clean <- beer_sales_tbl_aug %>%
  select_if(~ !is.Date(.)) %>%
  select_if(~ !any(is.na(.))) %>%
  mutate_if(is.ordered, ~ as.character(.) %>% as.factor)

beer_sales_tbl_clean %>% glimpse()

## Let’s split into a training, validation and test sets following the time ranges 
## in the visualization above.

# Split into training, validation and test sets
train_tbl <- beer_sales_tbl_clean %>% filter(year < 2016)
valid_tbl <- beer_sales_tbl_clean %>% filter(year == 2016)
test_tbl  <- beer_sales_tbl_clean %>% filter(year == 2017)

## STEP 3: MODEL WITH H2O
## First, fire up h2o. This will initialize the Java Virtual Machine (JVM) that H2O uses locally.

h2o.init()        # Fire up h2o
h2o.no_progress() # Turn off progress bars

## We change our data to an H2OFrame object that can be interpreted by the h2o package.

# Convert to H2OFrame objects
train_h2o <- as.h2o(train_tbl)
valid_h2o <- as.h2o(valid_tbl)
test_h2o  <- as.h2o(test_tbl)

# Set the names that h2o will use as the target and predictor variables.

# Set names for h2o
y <- "price"
x <- setdiff(names(train_h2o), y)


## Apply any regression model to the data. We’ll use h2o.automl.

# linear regression model used, but can use any model
automl_models_h2o <- h2o.automl(
  x = x, 
  y = y, 
  training_frame = train_h2o, 
  validation_frame = valid_h2o, 
  leaderboard_frame = test_h2o, 
  max_runtime_secs = 60, 
  stopping_metric = "deviance")


## Next we extract the leader model.

# Extract leader model
automl_leader <- automl_models_h2o@leader


## STEP 4: PREDICT
## Generate predictions using h2o.predict() on the test data.

pred_h2o <- h2o.predict(automl_leader, newdata = test_h2o)


## STEP 5: EVALUATE PERFORMANCE
## There are a few ways to evaluate performance. We’ll go through the easy way, 
## which is h2o.performance().

h2o.performance(automl_leader, newdata = test_h2o)

## Our preference for this is assessment is mean absolute percentage error (MAPE), 
## which is not included above. However, we can easily calculate. We can investigate 
## the error on our test set (actuals vs predictions).

# Investigate test error
error_tbl <- beer_sales_tbl %>% 
  filter(lubridate::year(date) == 2017) %>%
  add_column(pred = pred_h2o %>% as.tibble() %>% pull(predict)) %>%
  rename(actual = price) %>%
  mutate(
    error     = actual - pred,
    error_pct = error / actual
  ) 

error_tbl


## For comparison sake, we can calculate a few residuals metrics.

error_tbl %>%
  summarise(
    me   = mean(error),
    rmse = mean(error^2)^0.5,
    mae  = mean(abs(error)),
    mape = mean(abs(error_pct)),
    mpe  = mean(error_pct)
  ) %>%
  glimpse()


#################### Halloween Bonus  ######################
# Libraries needed for bonus material
library(extrafont) # More fonts!! We'll use Chiller
font_import()   #### say yes, may take a few minutes
loadfonts(device="win") 

# Create spooky dark theme:
theme_spooky = function(base_size = 10, base_family = "Chiller") {
  
  theme_grey(base_size = base_size, base_family = base_family) %+replace%
    
    theme(
      # Specify axis options
      axis.line = element_blank(),  
      axis.text.x = element_text(size = base_size*0.8, color = "white", lineheight = 0.9),  
      axis.text.y = element_text(size = base_size*0.8, color = "white", lineheight = 0.9),  
      axis.ticks = element_line(color = "white", size  =  0.2),  
      axis.title.x = element_text(size = base_size, color = "white", margin = margin(0, 10, 0, 0)),  
      axis.title.y = element_text(size = base_size, color = "white", angle = 90, margin = margin(0, 10, 0, 0)),  
      axis.ticks.length = unit(0.3, "lines"),   
      # Specify legend options
      legend.background = element_rect(color = NA, fill = " gray10"),  
      legend.key = element_rect(color = "white",  fill = " gray10"),  
      legend.key.size = unit(1.2, "lines"),  
      legend.key.height = NULL,  
      legend.key.width = NULL,      
      legend.text = element_text(size = base_size*0.8, color = "white"),  
      legend.title = element_text(size = base_size*0.8, face = "bold", hjust = 0, color = "white"),  
      legend.position = "none",  
      legend.text.align = NULL,  
      legend.title.align = NULL,  
      legend.direction = "vertical",  
      legend.box = NULL, 
      # Specify panel options
      panel.background = element_rect(fill = " gray10", color  =  NA),  
      #panel.border = element_rect(fill = NA, color = "white"),  
      panel.border = element_blank(),
      panel.grid.major = element_line(color = "grey35"),  
      panel.grid.minor = element_line(color = "grey20"),  
      panel.spacing = unit(0.5, "lines"),   
      # Specify facetting options
      strip.background = element_rect(fill = "grey30", color = "grey10"),  
      strip.text.x = element_text(size = base_size*0.8, color = "white"),  
      strip.text.y = element_text(size = base_size*0.8, color = "white",angle = -90),  
      # Specify plot options
      plot.background = element_rect(color = " gray10", fill = " gray10"),  
      plot.title = element_text(size = base_size*1.2, color = "white",hjust=0,lineheight=1.25,
                                margin=margin(2,2,2,2)),  
      plot.subtitle = element_text(size = base_size*1, color = "white",hjust=0,  margin=margin(2,2,2,2)),  
      plot.caption = element_text(size = base_size*0.8, color = "white",hjust=0),  
      plot.margin = unit(rep(1, 4), "lines")
      
    )
  
}


## Now let’s create the final visualization so we can see our spooky forecast… 
## Conclusion from the plot: It’s scary how accurate h2o is.

beer_sales_tbl %>%
  ggplot(aes(x = date, y = price)) +
  # Data - Spooky Orange
  geom_point(size = 2, color = "gray", alpha = 0.5, shape = 21, fill = "orange") +
  geom_line(color = "orange", size = 0.5) +
  geom_ma(n = 12, color = "white") +
  # Predictions - Spooky Purple
  geom_point(aes(y = pred), size = 2, color = "gray", alpha = 1, shape = 21, fill = "purple", data = error_tbl) +
  geom_line(aes(y = pred), color = "purple", size = 0.5, data = error_tbl) +
  # Aesthetics
  theme_spooky(base_size = 20) +
  labs(
    title = "Beer Sales Forecast: h2o + timetk",
    subtitle = "H2O had highest accuracy, MAPE = 3.9%",
    caption = "Thanks to @lenkiefer for theme_spooky!"
  )

