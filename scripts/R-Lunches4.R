## R-Lunches4.R

getwd()  ## make sure you are in the learningR project directory

list.files()   ## to see if you have the three "sub-directories", data, scripts, and output


## load packages
## use install.packages('packagename') if package has never been installed

library(tidyverse)
library(EDAWR)

install.packages('nycflights13')
library(nycflights13)

?flights

# Filter rows with filter()

filter(flights, month == 1, day == 1)
flights %>% filter(month==1, day ==1)

jan1 <- filter(flights, month == 1, day == 1)

# wrap assignment in parentheses to print results
(dec25 <- filter(flights, month == 12, day == 25))


#  Comparisons

filter(flights, month = 1)    ## wrong
filter(flights, month == 1)   ## correct

filter(flights, month == 11 | month == 12)


#   Exercises
## 1.	Find all flights that
## 1.	Had an arrival delay of two or more hours.
## 2.	Flew to Houston (IAH or HOU)
## 3.	Were operated by United, American, or Delta
## 4.	Departed in summer (July, August, and September)
## 5.	Arrived more than two hours late, but didn’t leave late
## 6.	Were delayed by at least an hour, but made up over 30 minutes in flight
## 7.	Departed between midnight and 6am (inclusive)

## Arrange rows with arrange()

arrange(flights, year, month, day)

arrange(flights, desc(arr_delay))    ## descending

## Exercises
##@ 1.	How could you use arrange() to sort all missing values to the start? (Hint: use is.na()).
##@ 2.	Sort flights to find the most delayed flights. Find the flights that left earliest.
##@ 3.	Sort flights to find the fastest flights.
##@ 4.	Which flights travelled the longest? Which travelled the shortest?


## Select columns with select()

# Select columns by name
select(flights, year, month, day)

# Select all columns between year and day (inclusive)
select(flights, year:day)

# Select all columns except those from year to day (inclusive)
select(flights, -(year:day))

## everything helper function
select(flights, time_hour, air_time, everything())


## Add new variables with mutate()

## start with a smaller dataset

flights_sml <- select(flights, 
                      year:day, 
                      ends_with("delay"), 
                      distance, 
                      air_time
)

mutate(flights_sml,
       gain = arr_delay - dep_delay,
       speed = distance / air_time * 60
)

# Note that you can refer to columns that you’ve just created:
mutate(flights_sml,
       gain = arr_delay - dep_delay,
       hours = air_time / 60,
       gain_per_hour = gain / hours
)


## Grouped summaries with summarise()

summarise(flights, delay = mean(dep_delay))

summarise(flights, delay = mean(dep_delay, na.rm = TRUE))


## summarize not really useful unless paired with group_by()

by_day <- group_by(flights, year, month, day)
summarise(by_day, delay = mean(dep_delay, na.rm = TRUE))



# Combining multiple operations with the pipe

## old school

by_dest <- group_by(flights, dest)

delay <- summarise(by_dest,
                   count = n(),
                   dist = mean(distance, na.rm = TRUE),
                   delay = mean(arr_delay, na.rm = TRUE)
)

delay <- filter(delay, count > 20, dest != "HNL")


## using the "pipe"
## this approach focuses on the transformatoins, not on what's being transformed.

delays <- flights %>% 
  group_by(dest) %>% 
  summarise(
    count = n(),
    dist = mean(distance, na.rm = TRUE),
    delay = mean(arr_delay, na.rm = TRUE)
  ) %>% 
  filter(count > 20, dest != "HNL")







#############################################

## ggplot2

library(ggplot2)

# there is a built-in dataset in ggplot2, called mpg
?mpg

## let's use ggplot2 to answer the question: do cars with big engines
## use more fuel than cars with smaller engines...

mpg

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy))

## follows a template:
## ggplot(data = <DATA>)  +  <GEOM_FUNCTION>(mapping = aes(<MAPPINGS>))



# Exercises
##@ 1.	Run ggplot(data = mpg) what do you see?
##@ 2.	What does the drv variable describe? Read the help for ?mpg to find out.
##@ 3.	Make a scatterplot of hwy vs cyl.
##@ 4.	What happens if you make a scatterplot of class vs drv. Why is the plot not useful?


################################


data(mtcars)
?mtcars

head(mtcars)

## base R
plot(mtcars$wt, mtcars$mpg)

## ggplot2
ggplot(data = mtcars, aes(x = wt, y = mpg)) + geom_point()

## line graph
str(pressure)

ggplot(data = pressure, aes(x = temperature, y = pressure)) + geom_line()

# Add points
ggplot(data = pressure, aes(x = temperature, y = pressure)) + geom_line() + 
  geom_point()

## Histograms
# base R
hist(mtcars$mpg)

# ggplot2
ggplot(data = mtcars, aes(x = mpg)) + geom_histogram()
ggplot(data = mtcars, aes(x = mpg)) + geom_histogram(binwidth = 4)

## Boxplots
str(ToothGrowth)
head(ToothGrowth)

summary(ToothGrowth$dose)
table(ToothGrowth$dose)

plot(ToothGrowth$supp, ToothGrowth$len)
boxplot(len ~ supp, data = ToothGrowth)  ## formula syntax

## ggplot2
ggplot(data = ToothGrowth, aes(x = supp, y = len)) + geom_boxplot()


# First principles of creating a plot

# 1. A dataframe containing what you are plotting should be specified.
# 2. An aesthetic must be given declaring x, y or both as some variable in the data.frame. For some plots (histograms, density, e.g.), one of these will be calculated as a stat from the data.
# 3. A geom must be specified, stating how the aesthetics will appear as geomtrical objects.


