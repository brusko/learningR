summarybk <- function(x) {
   mean <- mean(x, na.rm=TRUE)
   median <- median(x, na.rm=TRUE)
   sd <- sd(x, na.rm=TRUE)
   mad <- mad(x, na.rm=TRUE)
   IQR <- IQR(x, na.rm=TRUE)
   ans <- c(mean, median, sd, mad, IQR)
   ans
}



# how to do weighted means
xs <- replicate(5, runif(10), simplify = FALSE)
ws <- replicate(5, rpois(10, 5) + 1, simplify = FALSE)

## won't work
## lapply(seq_along(xs), means, ws)
## Need to 
lapply(seq_along(xs), function(i) {
  weighted.mean(xs[[i]], ws[[i]])
})

power <- function(exponent) {
  function(x) {
    x ^ exponent
  }
}


out <- vector('list', length(l))
for (i in seq_along(l)) {
  out[[i]] <- length(l[[i]])
}
unlist(out)

unlist(lapply(l, length))




## slow
xs <- runif(1e3)

res <- c()

for (x in xs) {
  res <- c(res, sqrt(x))
}

## faster
res2 <- numeric(length(xs))

for (i in seq_along(xs)) {
  res2[i] <- sqrt(xs[i])
}


sqr1 <- lapply(xs, function(x) sqrt(x))

sqr2 <- lapply(seq_along(xs), )



##

rollmean <- function(x, n) {
  out <- rep(NA, length(x))
  
  offset <- trunc(n / 2)
  for (i in (offset + 1):(length(x) - n + offset + 1)) {
    out[i] <- mean(x[(i - offset):(i + offset - 1)])
  }
  out
}

x <- seq(1,3, length = 1e2) + runif(1e2)

lines(rollmean(x, 5), col='blue', lwd=2)
lines(rollmean(x, 10), col='red', lwd=2)


## but

x <- seq(1, 3, length = 1e2) + rt(1e2, df = 2) / 3
plot(x)
lines(rollmean(x, 5), col = "red", lwd = 2)

## better to use rollmedian
rollapply <- function(x, n, f, ...) {
  out <- rep(NA, length(x))
  
  offset <- trunc(n / 2)
  for (i in (offset + 1):(length(x) - n + offset + 1)) {
    out[i] <- f(x[(i - offset):(i + offset)], ...)
  }
  out
}
plot(x)
lines(rollapply(x,5,median), col='red', lwd = 2)


## ~ zoo rollapply()

rollapply <- function(x, n, f, ...) {
  offset <- trunc(n / 2)
  locs <- (offset + 1):(length(x) - n + offset + 1)
  num <- vapply(
    locs, 
    function(i) f(x[(i - offset):(i + offset)], ...),
    numeric(1)
  )
  
  c(rep(NA, offset), num)
}



tapply2 <- function(x, group, f, ..., simplify = TRUE) {
  pieces <- split(x, group)
  sapply(pieces, f, simplify = simplify)
}



Reduce2 <- function(f, x) {
  out <- x[[1]]
  for(i in seq(2, length(x))) {
    out <- f(out, x[[i]])
  }
  out
}



trans <- list(
  disp = function(x) x * 0.0163871,
  am = function(x) factor(x, levels = c("auto", "manual"))
)

trans

for(var in names(trans)) {
  mtcars[[var]] <- trans[[var]](mtcars[[var]])
}
