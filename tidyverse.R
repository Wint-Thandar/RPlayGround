# Tidyverse 
# a collection of packages for R that are all designed to work together to help users stay organized and efficient throughout their data science projects. 
# there are 8 core packages. 

# Data Import
# 1. readr: for data import.
# 2. tidyr: for data tidying.
# 3. tibble: for tibbles, a modern re-imagining of data frames.

# Data Manipulation
# 4. dplyr: for data manipulation.
# 5. stringr: for strings.

# Data Visualization
# 6. ggplot2: for data visualisation.

# Functional Programming
# 7. purrr: for functional programming.

# Working with Categorical Variables (Factors)
# 8. forcats: for dealing factors.

# Load the tidyverse 
library(tidyverse)

# Write csv file
write_file(x=”a,b,c\n1,2,3\n4,5,NA”, path = “sample.csv”)

# READ TABULAR DATA 
# read the sample csv file into the enviorment
tibble_1 <- read_csv(“sample.csv”)
tibble_1 

# Install and load readxl to read xlsx files
install.packages(readxl)
library(readxl)
read_excel(“sampledatafoodsales.xlsx”, sheet = 1) # sheet argument is for which sheet to read

# Write another csv file with different types 
write_file(x=”a,b,c,d\n1,T,3,dog\n4,FALSE,NA,cat\n6,F,5,mouse\n18,TRUE,3,moose”, path = “sample2.csv”)
read_csv(“sample2.csv”)


