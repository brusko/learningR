## R-Lunches6.R
##
## Importing Excel files (xls and xlsx) into R
## Using the package readxl
##

install.packages('tidyverse')  ## if not already installed
install.packages('readxl')  ## yes to restart, if asked

library(tidyverse)
library(readxl)

## readxl includes several example files.
## There is a helper function called readxl_example()

readxl_example()

readxl_example('clippy.xls')

## create a shortcut to the full path to the xls file:
xls_example <- readxl_example("datasets.xls")
xls_example

## create a shortcut to the full path to the xls file:
xlsx_example <- readxl_example("datasets.xlsx")
xlsx_example

## read_excel() reads both xls and xlsx files and detects 
## the format from the extension.

example1 <- read_excel(xls_example)
example1

example2 <- read_excel(xlsx_example)
example2

## List the sheet names with excel_sheets()

excel_sheets(xls_example)
excel_sheets(xlsx_example)


# Specify a worksheet by name or number.
read_excel(xlsx_example, sheet = "chickwts")
read_excel(xls_example, sheet = 4)

# There are various ways to control which cells are read. 
# You can even specify the sheet here, if providing an 
# Excel-style cell range.

read_excel(xlsx_example, n_max = 3)
read_excel(xlsx_example, range = "C1:E4")
read_excel(xlsx_example, range = cell_rows(1:4))
read_excel(xlsx_example, range = cell_cols("B:D"))
read_excel(xlsx_example, range = "mtcars!B1:D5")


