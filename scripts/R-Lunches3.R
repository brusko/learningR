## R-Lunches week 3


getwd()  ## make sure you are in the learningR project directory

list.files()   ## to see if you have the three "sub-directories", data, scripts, and output



##### Data Import

### CSV files
education <- read.csv('./data/2009education.csv')  ## assuming 2009education.csv is in your "data" directory


### MySQL database
install.packages('RMySQL')
library(RMySQL)  ## package we need to run queries agains a  MySQL database

db<- dbDriver("MySQL")
conn <- dbConnect(db, user="dbro", password="sql_uN0wrYt3", host="cmisdb421", db="cmistrunk") 

hpnacmis <- dbGetQuery(conn, 
                       "
                       SELECT *
                       FROM cmistrunk.met_network_port_usage
                       ")

head(hpnacmis)

####################################################

###### Pulling data from Vertica
install.packages('rJava')
install.packages('RJDBC')
library(rJava)
library(RJDBC)    ## we need these packages to pull data from the Vertica database


vertica_db <- new.env()
vertica_db[['driver_class']] <- "com.vertica.jdbc.Driver"
vertica_db[['class_path']] <- "C:\\Program Files\\Vertica Systems\\JAVA\\vertica-jdbc-8.0.0-1.jar"
vertica_db[['database']] <- "jdbc:vertica://CERNOCRSVERTDB-LOAD.CERNERASP.COM:5433/Cerner"
vertica_db[['username']] <- "bk6014"
vertica_db[['password']] <- "******"          ## PASSWORD GOES HERE  ##
options( java.parameters = "-Xmx8g" )


drv <- JDBC(vertica_db$driver_class,
            vertica_db$class_path,
            identifier.quote = "`")

conn <- dbConnect(drv,
                  vertica_db$database,
                  vertica_db$username,
                  vertica_db$password)


remNetData <- dbGetQuery(conn, "
                         SELECT COMPUTER_SYSTEM_NAME
                         , MNEMONIC
                         , SERIAL_NUMBER
                         , STATUS
                         , PRODUCT_CATEGORIZATION_TIER_3
                         , PRODUCT_NAME
                         , MANUFACTURER
                         , PRIMARY_USAGE
                         , SITE
                         , REGION
                         FROM PATROLPRD.REMEDY_COMPUTERSYSTEMS
                         WHERE PRODUCT_CATEGORIZATION_TIER_2 = 'Network'
                         ")


################################
## Excel files
install.packages('readxl')
library(readxl)
?read_excel

##############################################

## Towards Tidy Data

install.packages('EDAWR')  ## doesn't work, packing is not on CRAN

install.packages("devtools")  ##  helper package to get packages on Github

devtools::install_github("rstudio/EDAWR") # this works

library(EDAWR)

?storms
storms   ## tidy

?cases
cases    ## not tidy

?pollution
pollution   ## not tidy

?tb
tb      ## not tidy


##tidy the "cases" table
gather(cases, "year", "n", 2:4)

## tidy the "pollution" table
spread(pollution, size, amount)



## dplyr
install.packages('dplyr')
library(dplyr)


install.packages("nycflights13")
library(nycflights13)   ## flights in and out of NYC in 2013

?flights



