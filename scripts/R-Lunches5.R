## R-Lunches5.R

getwd()  ## make sure you are in the learningR project directory

# install.packages("ggplot2")  ## only if not done earlier
library(ggplot2)


## The dataset mpg (comes with ggplot2) shows fuel economy 
# data, 1999 and 2008
mpg

# Do cars with big engines use more fuel than cars with small 
# engines?
# What does the relationship between engine size and fuel 
# efficiency look like?
# positive? negative? linear? non-linear?

?mpg

## looks like we want to compare displ with hwy

## using ggplot2 to show the data
## The plot shows a negative relationship between engine 
# size (displ) and fuel efficiency (hwy). 

ggplot(data = mpg) + geom_point(mapping = aes(x=displ, y=hwy))

## is this what you expected?

## you begin with the function ggplot(). 
## The first argument is the dataset to use in the graph

ggplot(data = mpg)  ## nothing is printed, but a ggplot object is 
                    ## created - an empty plot

## you complete the plot by adding one or more layers to 
## the plot object
## the function geom_point() adds a layer of points to 
## your plot (scatterplot)

## Each geom function takes a mapping argument. This 
## defines how variables in your dataset are mapped 
## to visual properties.

## The mapping argument is always paired with aes() and 
## the x and y arguments of aes() specify which variables 
## to map to the x and y axes.
## ggplot looks for the mapped variable in the data argument,
## in this case mpg.

## Reusable template

# ggplot(data = <DATA>)  +  <GEOM_FUNCTION>(mapping = aes(<MAPPINGS>))

## To make a graph, replace the bracketed sections in the 
## code above with a dataset, a geom function, 
## and a set of mappings.



### Aesthetic Mappings

## An aesthetic is a visual property of the objects in 
## your plot. 
## Aesthetics include things like the size, the shape, 
## or the color of your points 
## (and remember, x-position and y-position are also 
## aesthetics.). 

## You can add a third variable, like class, to a two 
## dimensional scatterplot by mapping it to an aesthetic. 
## In the next example we map class to color. 

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, color = class))

## ggplot2 will automatically assign a unique level of the 
## aesthetic (here a unique color) to each unique value of 
## the variable, a process known as scaling. ggplot2 will 
## also add a legend that explains which levels correspond 
## to which values.

## Now we map class to size
## gives an error, but does it anyway

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, size = class))

## mapping class to shape
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, shape = class))  

## only six shapes available by default, seventh class (SUV) goes unplotted


## mapping class to alpha (transparency)
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, alpha = class))

## For each aesthetic, you set the name of the aesthetic to 
## the variable to display within the aes() function. 

## It selects a reasonable scale to use with the aesthetic, 
## and it constructs a legend that explains the mapping 
## between levels (of the aesthetic) and values(in the dataframe).

## For x and y aesthetics, ggplot2 does not create a legend, 
## but it creates an axis line with tick marks and a label. 
## The axis line acts as a legend; it explains the 
## mapping between locations and values.


## You can also set the aesthetic properties of your 
## geom manually. For example, we can make all of the points 
## in our plot blue:

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy), color = "blue")



### FACETS

## (As we saw) one way to add additional variables is with 
## aesthetics. 
## Another way, particularly useful for categorical variables, 
## is to split your plot into facets, subplots that each 
## display one subset of the data.

## To facet your plot by a single variable, use facet_wrap(). 
## The first argument of facet_wrap() should be a formula, 
## which you create with ~ followed by a variable name 
## (here “formula” is the name of a data structure in R, 
## not a synonym for “equation”). 
## The variable that you pass to facet_wrap() should 
## be discrete.

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) + 
  facet_wrap(~ class, nrow = 2)

## To facet your plot on the combination of two variables, 
## add facet_grid() to your plot call. 

## The first argument of facet_grid() is also a formula. 
## This time the formula should contain two variable 
## names separated by a ~.

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) + 
  facet_grid(drv ~ cyl)


### GEOMETRIC OBJECTS

## A geom is the geometrical object that a plot uses 
## to represent data.

## bar charts use bar geoms, line charts use line geoms, 
## boxplots use boxplot geoms, and so on. 
## Scatterplots break the trend; they use the point geom. 

## Lots of geoms available

?geom<TAB>

## Here are two plots tha contain the same x-variable, 
## the same y-variable, and both describe the same data.
## But each uses a different visual object (geom) to 
## represent the data.  
  

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy))

ggplot(data = mpg) + 
  geom_smooth(mapping = aes(x = displ, y = hwy)) +
  geom_point(mapping = aes(x = displ, y = hwy))


## Every geom function in ggplot2 takes a mapping argument. 
## However, not every aesthetic works with every geom. 

## You could set the shape of a point, but you couldn’t set 
## the “shape” of a line. 

## On the other hand, you could set the linetype of a line. 
## geom_smooth() will draw a different line, with a different
## linetype, for each unique value of the variable that you 
## map to linetype.

ggplot(data = mpg) + 
  geom_smooth(mapping = aes(x = displ, y = hwy, linetype = drv), se=FALSE)

## Here geom_smooth() separates the cars into three lines 
## based on their drv value, which describes a car’s 
## drivetrain. (4, r, f)

## we can make it more clear by overlaying the lines on top 
## of the raw data and then coloring everything according 
## to drv.

ggplot(data = mpg) + 
  geom_smooth(mapping = aes(x = displ, y = hwy, linetype = drv)) + 
  geom_point(mapping = aes(x=displ, y=hwy, color=drv))

## two geoms in the same graph! 


### Titles, axis-labels, etc

## first, let's call our plot "p"

p <- ggplot(data = mpg) + 
  geom_smooth(mapping = aes(x = displ, y = hwy, linetype = drv)) + 
  geom_point(mapping = aes(x=displ, y=hwy, color=drv))

## now we can add to "p"

## Title

p + ggtitle('MPG Data from the ggplot2 package')

p <- p + ggtitle('MPG Data from the ggplot2 package')

p <- p + xlab('Engine Displacement')
p <- p + ylab('Highway Miles per Gallon')


## labs (in newer versions of ggplot2?)

p <- ggplot(data = mpg) + 
  geom_smooth(mapping = aes(x = displ, y = hwy, linetype = drv)) + 
  geom_point(mapping = aes(x=displ, y=hwy, color=drv))


p <- p + labs(title = "MPG Data", 
              subtitle = "From the ggplot2 package")

p <- p + labs(caption = "Isn't ggplot2 awesome")
p <- p + labs(x = 'Engine Displacement', y='Highway Miles per Gallon')




## to get rid of the legend, use theme
p <- p + theme(legend.position="none")

## Enlarging the x and y axes labels and text, use theme

p <- p + theme(plot.title=element_text(size=25, face="bold"),
               plot.subtitle = element_text(size=15),
               axis.text.x=element_text(size=15), 
               axis.text.y=element_text(size=15),
               axis.title.x=element_text(size=15),
               axis.title.y=element_text(size=15)) 

ggplot(data=mpg) + geom_histogram(aes(x=hwy))

