## scraping web pages

library(rvest)


url <- paste("http://www.census.gov/population/international/data/idb/",
             "region.php?N=%20Results%20&T=10&A=separate&RT=0&Y=2016&R=-1&C=US",
             sep="")


html <- read_html(url) # reading the html code into memory
html # not very informative

substr(html_text(html), 1, 1000) # first 1000 characters


tab <- html_table(html)
str(tab)

pop <- tab[[1]]
