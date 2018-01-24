## Script that follows "Introduction to Working With Time Series Data in Text Formats in R"
##
## http://www.neonscience.org/tabular-time-series 

## from "Time Series 00: Intro to Time Series Data in R - Managing Date/Time Formats & Simple Plots using ggplot2"

library(tidyverse)
library(ggmap)
# library(digest)
# devtools::install_github("ropensci/EML", build=FALSE, dependencies=c("DEPENDS", "IMPORTS"))
library(EML)
library(lubridate)

## Read the data (Harvard ~ meterolocgical data)

harMet.daily <- read_csv('./data/NEONDSMetTimeSeries/NEON-DS-Met-Time-Series/HARV/FisherTower-Met/hf001-06-daily-m.csv')

## Let's plot air temp

ggplot(harMet.daily, aes(x=date, y=airt)) + geom_point() +
  ggtitle("Daily Air Temperature\nNEON Harvard Forest Field Site")


## Now plot precipitation

ggplot(harMet.daily, aes(x=date, y=prec)) + geom_point() +
  ggtitle("Daily PRecipitation\nNEON Harvard Forest Field Site")

## Do air temp and precipitation correlate?

ggplot(harMet.daily, aes(x=airt, y=prec)) + geom_point() +
  ggtitle("Daily Air Temperature versus Precipitation")


#################################################################################################
## Time Series 01: Why Metadata Are Important: How to Work with Metadata in Text & EML Format

## Next, we will read in the LTER EML file - directly from the online URL using eml_read. 

# data location
# http://harvardforest.fas.harvard.edu:8080/exist/apps/datasets/showData.html?id=hf001
# table 4 http://harvardforest.fas.harvard.edu/data/p00/hf001/hf001-04-monthly-m.csv

# import EML from Harvard Forest Met Data
# note, for this particular tutorial, we will work with an abridged version of the file
# that you can access directly on the harvard forest website. (see comment below)
eml_HARV <- read_eml("http://harvardforest.fas.harvard.edu/data/eml/hf001.xml")

# import a truncated version of the eml file for quicker demonstration
# eml_HARV <- read_eml("http://neonscience.github.io/NEON-R-Tabular-Time-Series/hf001-revised.xml")

# view size of object
object.size(eml_HARV)

## 54344432 bytes

# view the object class
class(eml_HARV)

## The eml_read function creates an EML class object. This object can be accessed using slots in R (@) 
## rather than a typical subset [] approach.

## Explore the MetaData

# view the contact name listed in the file

eml_HARV@dataset@creator

## An object of class "ListOfcreator"
## [[1]]
## <creator system="uuid">
##   <individualName>
##     <givenName>Emery</givenName>
##     <surName>Boose</surName>
##   </individualName>
## </creator>

# view information about the methods used to collect the data as described in EML
eml_HARV@dataset@methods

## <methods>
##   <methodStep>
##     <description>
##       <section>
##         <title>Observation periods</title>
##         <para>15-minute: 15 minutes, ending with given time. Hourly: 1 hour, ending with given time. Daily: 1 day, midnight to midnight. All times are Eastern Standard Time.</para>
##       </section>
##       <section>
##         <title>Instruments</title>
##         <para>Air temperature and relative humidity: Vaisala HMP45C (2.2m above ground). Precipitation: Met One 385 heated rain gage (top of gage 1.6m above ground). Global solar radiation: Licor LI200X pyranometer (2.7m above ground). PAR radiation: Licor LI190SB quantum sensor (2.7m above ground). Net radiation: Kipp and Zonen NR-LITE net radiometer (5.0m above ground). Barometric pressure: Vaisala CS105 barometer. Wind speed and direction: R.M. Young 05103 wind monitor (10m above ground). Soil temperature: Campbell 107 temperature probe (10cm below ground). Data logger: Campbell Scientific CR10X.</para>
##       </section>
##       <section>
##         <title>Instrument and flag notes</title>
##         <para>Air temperature. Daily air temperature is estimated from other stations as needed to complete record.</para>
##         <para>Precipitation. Daily precipitation is estimated from other stations as needed to complete record. Delayed melting of snow and ice (caused by problems with rain gage heater or heavy precipitation) is noted in log - daily values are corrected if necessary but 15-minute values are not.  The gage may underestimate actual precipitation under windy or cold conditions.</para>
##         <para>Radiation. Whenever possible, snow and ice are removed from radiation instruments after precipitation events.  Depth of snow or ice on instruments and time of removal are noted in log, but values are not corrected or flagged.</para>
##         <para>Wind speed and direction. During ice storms, values are flagged as questionable when there is evidence (from direct observation or the 15-minute record) that ice accumulation may have affected the instrument's operation.</para>
##       </section>
##     </description>
##   </methodStep>
## </methods>

## Identify & Map Data Location

# grab x coordinate from the coverage information
XCoord <- eml_HARV@dataset@coverage@geographicCoverage[[1]]@boundingCoordinates@westBoundingCoordinate@.Data

# grab y coordinate from the coverage information
YCoord <- eml_HARV@dataset@coverage@geographicCoverage[[1]]@boundingCoordinates@northBoundingCoordinate@.Data

# map <- get_map(location='Harvard', maptype = "terrain")

# plot the NW corner of the site.
map <- get_map(location='massachusetts', maptype = "toner", zoom =8)

ggmap(map, extent=TRUE) +
  geom_point(aes(x=as.numeric(XCoord),y=as.numeric(YCoord)), 
             color="darkred", size=6, pch=18)


#################################################################################################
## Time Series 02: Dealing With Dates & Times in R - as.Date, POSIXct, POSIXlt

harMet_15Min <- read_csv('./data/NEONDSMetTimeSeries/NEON-DS-Met-Time-Series/HARV/FisherTower-Met/hf001-10-15min-m.csv')

## Dates are already in POSIXct time.
## But Timezone is not correct.