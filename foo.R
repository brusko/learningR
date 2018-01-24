#'---
#'title: "RMarkdown in GitHub"
#'author: "Bruce Kusko"
#'date: "January 24, 2018"
#'output: 
#'  html_document: 
#'    keep_md: yes
#'---

#'Woe is a me bop om drop a re bop om

#+ r
library(tidyverse)
foo <- readRDS("C:/Users/bk6014/OneDrive - Cerner Corporation/RWD/learningR2/data/co2.Rds")
head(foo)

p <- ggplot(foo, aes(x=time, y=co2)) + geom_line()
print(p)

#' The end
