## from Hadley Advanced R
## Functionals
## A family of functions

add <- function(x,y) {
  stopifnot(length(x) == 1, length(y)==1,
            is.numeric(x), is.numeric(y))
        x + y
}

## add an na.rm argument

rm_na <- function(x,y,identity) {
  if (is.na(x) && is.na(y)) {
    identity
  } else if (is.na(x)) {
    y
  } else {
    x
  }
}


## new version of add becomes

add <- function(x, y, na.rm = FALSE) {
  if (na.rm && (is.na(x) || is.na(y))) rm_na(x, y, 0) else x + y
}


## Generalize to more than 2 nummas
## can do this iteratively:

r_add <- function(xs, na.rm=TRUE) {
  Reduce(function(x, y) add(x, y, na.rm=na.rm), xs, init=0)
}


### Cumulative addition

c_add <- function(xs, na.rm = FALSE) {
  Reduce(function(x, y) add(x, y, na.rm = na.rm), xs,
         accumulate = TRUE)
}


dt1 <- dt
dt1$time <- 2
dt1$alp <- .4
dt2 <- dt1
dt2$x <- dt$y
dt2$y <- dt$x
dt2[,c('time','size')] <- 3
dt2$ease <- 'bounce-out'
dt2$col <- 'green'
dt3 <- dt2
dt3$x <- dt$x
dt3$time <- 4
dt3$col <- 'blue'


p <- ggplot(mtcars) + geom_point(aes(x = wt, y = mpg,
                                     colour=factor(gear))) + facet_wrap(~am)  + theme_igray() 
p + theme_igray() + scale_colour_colorblind()



p <- ggplot(mtcars) +
  geom_point(aes(x = wt, y = mpg, colour=factor(gear))) +
  facet_wrap(~am)
p + scale_colour_tableau()
p + scale_colour_tableau('tableau20')
p + scale_colour_tableau('tableau10medium')
p + scale_colour_tableau('tableau10light')
p + scale_colour_tableau('colorblind10')
p + scale_colour_tableau('trafficlight')
p + scale_colour_tableau('purplegray12')
p + scale_colour_tableau('bluered12')
p + scale_colour_tableau('greenorange12')
p + scale_colour_tableau('cyclic')


