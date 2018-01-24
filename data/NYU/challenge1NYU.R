---
title: "Challenge1NYU"
author: "Bruce Kusko"
date: "January 30, 2016"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

## Challenge 1 
### NYU Data Science Workshop

```{r}
## read in the data set
hony <- read.csv("./humansofnewyork.csv", stringsAsFactors=FALSE)
```


#### 1. How many status updates have been posted on this page?

Do some data exploration:
```{r}
dim(hony)
head(hony,3)
summary(hony)
```

