## learning me some network visualization
##
##
install.packages("igraph") 
install.packages("network") 
install.packages("sna")
install.packages("visNetwork")
install.packages("threejs")
install.packages("networkD3")
install.packages("ndtv")
install.packages('RColorBrewer')
install.packages('extrafont')

library("igraph") 
library("network") 
library("sna")
library("visNetwork")
library("threejs")
library("networkD3")
library("ndtv")
library('RColorBrewer')
library('extrafont')


library(tidyverse)


## set up PDF plotting stuff

Sys.setenv(R_GSCMD = "C:/Program Files/gs/gs9.21/bin/gswin64c.exe")

pdf(file="ArialBlack.pdf")
plot(x=10:1, y=10:1, pch=19, cex=6, 
     main="This is a plot", col="orange", 
     family="Arial Black" )
dev.off()

embed_fonts("ArialBlack.pdf", outfile="ArialBlack_embed.pdf")

### Data Sets

## Data Set 1: edgelist
nodes <- read_csv('C:/Users/bk6014/OneDrive - Cerner Corporation/shortcuts and to do/NetworkViz/Data files/Dataset1-Media-Example-NODES.csv')
links <- read_csv('C:/Users/bk6014/OneDrive - Cerner Corporation/shortcuts and to do/NetworkViz/Data files/Dataset1-Media-Example-EDGES.csv')

ht(nodes)
ht(links)

nrow(nodes); length(unique(nodes$id))
nrow(links); nrow(unique(links[,c("from", "to")]))

## Data Set 2: matrix
nodes2 <- read_csv('C:/Users/bk6014/OneDrive - Cerner Corporation/shortcuts and to do/NetworkViz/Data files/Dataset2-Media-User-Example-NODES.csv')
links2 <- read_csv('C:/Users/bk6014/OneDrive - Cerner Corporation/shortcuts and to do/NetworkViz/Data files/Dataset2-Media-User-Example-EDGES.csv')

ht(nodes2)
ht(links2)

links2 <- as.matrix(links2)
dim(links2)
dim(nodes2)

### Turning networks into igraph objects

## Data set 1



## What do I have to work with
## Array - Switch Connectivity

array <- read_csv('./data/DirectoryArrayConnectivity.csv')

nodesArray <- array %>% dplyr::select(data_center:array_port_name)
nodesSwitch <- array %>% dplyr::select(data_center, switch_name, switch_port)
