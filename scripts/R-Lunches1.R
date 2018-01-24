#
# Getting Started with Charts in R
# http://flowingdata.com
#


## Loading and handling data ##

# create an integer vector
c(1,2,3,4,5)

fakedata <- c(1,2,3,4,5)	# Assign to variable
fakedata

fakedata[1]
fakedata[1:3]

str(fakedata)  # str shows the "structure" of the object


# find the squares of all values in fakedata
# standard programming way

x <- vector()  # create an empty vector
for (i in 1:length(fakedata)){  # for each value in fakedata
    x[i] = i^2                  # take the value and square it
}
x                               # print the resulting vector

# R is vectorized 
fakedata
y <- fakedata^2
y

# Data frame
morefake <- c("a", "a", "a", "a", "a")
str(morefake)    # a character vector
f <- cbind(fakedata, morefake)		# Matrix, values "coerced" to characters

# Aside on coersion
# atomic vector data types (homogeneous)
# logical, integer, double, character

## logical & integer --> integer
## integer and character --> character


fake.df <- data.frame(cbind(fakedata, morefake))
fake.df
str(fake.df)

fake.df$morefake <- as.character(fake.df$morefake)   # can change data types
colnames(fake.df)

# Loading data into data frame
education <- read.csv("./data/2009education.csv")
head(education)  # First six rows

# Subsetting
education[1,]		# First row
education[1:10,]	# First ten rows
education$state		# First columnn
education[,1]		# Also first column
education[1,1]		# First cell

# Sort least to greatest
high.order <- order(education$high)		
high.order
education.high <- education[high.order,]
head(education.high)


# Sort greatest to least
high.order <- order(education$high, decreasing=TRUE)
education.high <- education[high.order,]


## Basic plotting

plot(fakedata)
plot(education)		# You get an error.
plot(education.high$high)
plot(education[,2], education[,3])
plot(education[,2:4])

# Plot types
plot(education$high, type="l")	# Line
plot(education$high, type="h")	# High-density
plot(education$high, type="s")	# Step

# Changing parameters
plot(education.high$high, las=1)
plot(education.high$high, las=1, xlab="States", ylab="Percent", main="At least high school degree or equivalent by state")
plot(education.high$high, las=1, xlab="States", ylab="Percent", main="At least high school degree or equivalent", bty="n", cex=0.5, cex.axis=0.6, pch=19)
plot(education.high$state, education.high$high)


# Additional charts
barplot(education$high)
barplot(education$high, names.arg=education$state, horiz=TRUE, las=1, cex.names=0.5, border=NA)
?barplot

boxplot(education$high)
boxplot(education[,2:4])

plot(1:length(education$high), education$high, type="n")
points(1:length(education$high), education$high)

plot(1:length(education$high), education$high, type="n")
lines(1:length(education$high), education$high)


# Multiple charts
par(mfrow=c(3,3), mar=c(2,5,2,1), las=1, bty="n")
plot(education.high$high)
plot(education$high, education$bs)
plot(education.high$high, type="l")	# Line
plot(education.high$high, type="h")	# High-density
plot(education.high$high, type="s")	# Step
barplot(education$high)
barplot(education$high, names.arg=education$state, horiz=TRUE, las=1, cex.names=0.5, border=NA)
boxplot(education$high)
boxplot(education[,2:4])


