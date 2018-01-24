## sports analytics
##

## if deuce not already installed:
## library(devtools)
## devtools::install_github('skoval/deuce')


help(package = 'deuce')
help('atp_matches', package = 'deuce')

## getting data

url <- 'http://www.tennis-data.co.uk/2017/ausopen.csv'
read.csv(url)

## what about US open / 2016

url <- 'http://www.tennis-data.co.uk/2016/usopen.csv'
usopen <- read.csv(url)

str(usopen)

## static vs dynamic data




library(rvest)

url <- 'http://www.basketball-reference.com/boxscores'

webpage <- read_html(url)

data <- webpage %>% 
  html_nodes(css = 'table') %>% 
  html_table()

length(data)

head(data[[1]])
head(data[[2]])

## what we want is here
head(data[[4]])

## use xpath to get just this

data <- webpage %>% 
  html_nodes(xpath = '//*[@id="divs_standings_E"]') %>% 
  html_table(header=T)

head(data[[1]])
