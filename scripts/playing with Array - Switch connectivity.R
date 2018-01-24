## playing with Array - Switch connectivity

## What do I have to work with
## Array - Switch Connectivity

## changed csv file; NULL and N/A to blanks

array <- read_csv('./data/DirectoryArrayConnectivity.csv')

arrayCC <- array %>% filter(complete.cases(.))

## arrays with a B
arraySwitchB <- arrayCC %>% dplyr::filter(grepl('B[0-9]', switch_name))

## arrays with a R
arraySwitchR <- arrayCC %>% dplyr::filter(grepl('R[0-9]', switch_name))  ### careful, TASPFR false positive

## array with a B or R ##NOT WORKING
arraySwitchNBR <- arrayCC %>% dplyr::filter(grepl('![B,R]', switch_name))

one <- arrayR[,c('array_name','switch_name')]
two <- arrayB[,c('array_name','switch_name')]

three <- merge(one,two)

##########################################################

## example of bipartite graph


set.seed(123)
V1 <- sample(LETTERS[1:10], size = 10, replace = TRUE)
V2 <- sample(1:10, size = 10, replace = TRUE)

d <- data.frame(V1 = V1, V2 = V2, weights = runif(10))
d

g <- graph_from_data_frame(d, directed = FALSE)
V(g)$label <- V(g)$name # set labels.

V(g)$type <- 1
V(g)[name %in% 1:10]$type <- 2

V(g)$shape <- shape[as.numeric(V(g)$type) + 1]
















V(g)$x <- c(1, 1, 1, 2, 2, 2, 2)
V(g)$y <- c(3, 2, 1, 3.5, 2.5, 1.5, 0.5)
V(g)$shape <- shape[as.numeric(V(g)$type) + 1]
V(g)$color <- c('red', 'blue', 'green', 'steelblue', 'steelblue', 'steelblue', 'steelblue')
E(g)$color <- 'gray'
E(g)$color[E(g)['A' %--% V(g)]] <- 'red'
E(g)$color[E(g)['B' %--% V(g)]] <- 'blue'
E(g)$color[E(g)['C' %--% V(g)]] <- 'green'
plot(g)

