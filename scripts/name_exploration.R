## illustrating R with baby names
##
## taken from https://rpubs.com/jalapic/babynames
##
##
## How popular is your name?

### load packages
library(babynames) 
library(dplyr) 
library(tidyr)
library(ggplot2)
library(gridExtra)
library(magrittr)


head(babynames)

tail(babynames)

# What are the most popular names of all time?

babynames %>%
  group_by(sex, name) %>%
  summarize(total = sum(n)) %>%
  arrange(desc(total)) %$%
  split(., sex)  -> bn


## How many unique names are there?

babynames %$%
  split(., sex) %>%
  lapply(. %$% length(unique(name)))

## far more female names than male names



## How popular has YOUR name been over the years?

## starting with the adults


Bruce <- babynames %>%
  filter(name=="Bruce") %$% 
  ggplot(., aes(year, n)) +
  geom_line(aes(color=sex), lwd=1) +
  scale_color_manual(values = c("red", "blue")) +
  theme_bw() +
  ggtitle("Bruce")

Brad <- babynames %>%
  filter(name=="Brad") %$% 
  ggplot(., aes(year, n)) +
  geom_line(aes(color=sex), lwd=1) +
  scale_color_manual(values = c("red", "blue")) +
  theme_bw() +
  ggtitle("Brad")

Michael <- babynames %>%
  filter(name=="Michael") %$% 
  ggplot(., aes(year, n)) +
  geom_line(aes(color=sex), lwd=1) +
  scale_color_manual(values = c("red", "blue")) +
  theme_bw() +
  ggtitle("Michael")

Justin <- babynames %>%
  filter(name=="Justin") %$% 
  ggplot(., aes(year, n)) +
  geom_line(aes(color=sex), lwd=1) +
  scale_color_manual(values = c("red", "blue")) +
  theme_bw() +
  ggtitle("Justin")

grid.arrange(Bruce, Brad, Michael, Justin,ncol=2)

#################################

Bruce + ylim(0,50)
Brad 
Michael + ylim(0,1150)

#################################



#########################################

Finn <- babynames %>%
  filter(name=="Finn") %$% 
  ggplot(., aes(year, n)) +
  geom_line(aes(color=sex), lwd=1) +
  scale_color_manual(values = c("red", "blue")) +
  theme_bw() +
  ggtitle("Finn")

Ivan <- babynames %>%
  filter(name=="Ivan") %$% 
  ggplot(., aes(year, n)) +
  geom_line(aes(color=sex), lwd=1) +
  scale_color_manual(values = c("red", "blue")) +
  theme_bw() +
  ggtitle("Ivan")

Duhn <- babynames %>%
  filter(name=="Duhn") %$% 
  ggplot(., aes(year, n)) +
  geom_line(aes(color=sex), lwd=1) +
  scale_color_manual(values = c("red", "blue")) +
  theme_bw() +
  ggtitle("Duhn")


Dylan <- babynames %>%
  filter(name=="Dylan") %$% 
  ggplot(., aes(year, n)) +
  geom_line(aes(color=sex), lwd=1) +
  scale_color_manual(values = c("red", "blue")) +
  theme_bw() +
  ggtitle("Dylan")

grid.arrange(Finn, Ivan, Duhn, Dylan, ncol=2)


#### How many names start with Fin?


Fin <- babynames %>% dplyr::filter(grepl('Fin', name)) %>%
  select(name,n) %>% distinct() %>% group_by(name) %>% count() %>% arrange(desc(nn))

View(Fin)


Brad <- babynames %>% dplyr::filter(grepl('Brad', name)) %>%
    select(name,n) %>% distinct() %>% group_by(name) %>% count() %>% arrange(desc(nn))

View(Brad)


Bruce <- babynames %>% dplyr::filter(grepl('Bruce', name)) %>%
  select(name,n) %>% distinct() %>% group_by(name) %>% count() %>% arrange(desc(nn))

View(Bruce)


Dun <- babynames %>% dplyr::filter(grepl('Du[a-z]*n$', name)) %>%
  select(name,n) %>% distinct() %>% group_by(name) %>% count() %>% arrange(desc(nn))

View(Dun)

Ivan <- babynames %>% dplyr::filter(grepl('Ivan', name)) %>%
  select(name,n) %>% distinct() %>% group_by(name) %>% count() %>% arrange(desc(nn))

View(Ivan)

Dylan <- babynames %>% dplyr::filter(grepl('D[y,i][a-z]*n$', name)) %>%
  select(name,n) %>% distinct() %>% group_by(name) %>% count() %>% arrange(desc(nn))

View(Dylan)

##############

Duhn <- babynames %>%
  filter(name=="Duhn") %$% 
  ggplot(., aes(year, n)) +
  geom_line(aes(color=sex), lwd=1) +
  scale_color_manual(values = c("red", "blue")) +
  theme_bw() +
  ggtitle("Duhn")





D <- babynames %>% dplyr::filter(grepl('^D', name)) %>%
  select(name,n) %>% distinct() %>% group_by(name) %>% count() %>% arrange(desc(nn))

View(D)




