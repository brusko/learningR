## RShiny script to  show bitcoin prices

#install.packages('shiny')
#install.packages('coindeskr')
#install.packages('dygraphs')

library(shiny) #To build the shiny App
library(coindeskr) #R-Package connecting to Coindesk API 
library(dygraphs) #For interactive Time-series graphs

library(tidyverse)