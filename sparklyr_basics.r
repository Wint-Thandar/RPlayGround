# CREDITS to BUSINESS SCIENCE UNIVERSITY ----
# LEARNING LAB 65: SPARK IN R ----

# ESSENTIAL SPARK in R RESOURCES ----
#  https://spark.rstudio.com
#  https://therinspark.com/


# * LIBRARIES ----
library(fs)
library(tidyverse)
library(DBI)
library(sparklyr)


# * SPARK INSTALLATION ----
# Install Spark
# spark_install(version = "3.1")

# The version that is installed on your machine
# spark_installed_versions()

# To remove a spark installation
# spark_uninstall("2.2.0")


# * CONNECTION TO SPARK ----
?spark_connect

# Configuration Setup (Optional)
conf <- list()
conf$`sparklyr.cores.local`         <- 6
conf$`sparklyr.shell.driver-memory` <- "16G"
conf$spark.memory.fraction          <- 0.9
conf$sparklyr.gateway.port <- 8890

# Connects to Spark Locally
sc <- spark_connect(
    master  = "local", 
    version = "3.1.3", 
    config  = conf
)
sc

# Disconnecting 
# spark_disconnect_all()


# * WEB INTERFACE ----
# Useful for troubleshooting and killing long-running jobs
spark_web(sc)


# * ADDING DATA TO SPARK ---- 
cars <- copy_to(sc, mtcars, "mtcars")

src_tbls(sc)

# These are the same because cars stores a reference to the Spark table
tbl(sc, "mtcars")

cars

# If you want to quickly get number of rows
nrow(cars)

sdf_nrow(cars)


# TIP 1: DATA WRANGLING: use SPARK DPLYR ----
# ** Basics of Dplyr SQL Translation ----
count(cars)

count(cars) %>% show_query()


# ** Advantage of Dplyr SQL Translation ----
# Summarize + Across
cars %>%
    summarise(across(everything(), mean, na.rm = TRUE)) %>%
    show_query()

# Grouped Functions
cars %>%
    mutate(transmission = case_when(am == 1 ~ "automatic", TRUE ~ "manual")) %>%
    group_by(transmission) %>%
    summarise(across(mpg:carb, mean, na.rm = TRUE)) %>%
    show_query()

# Complex Structures (Lists)
cars %>%
    summarise(mpg_percentile = percentile(mpg, array(0, 0.25, 0.5, 0.75, 1))) %>%
    mutate(mpg_percentile = explode(mpg_percentile))


# TIP 2: MODELING AT SCALE ----
# * Make a Model ----
model <- ml_linear_regression(cars, mpg ~ hp)
model

# * Predict New Data ----
more_cars <- copy_to(sc, tibble(hp = 250 + 10 * 1:10))

model %>%
    ml_predict(more_cars)

model %>% summary()

# * Correlations at Scale ----
ml_corr(cars)


# TIP 3: STREAMING (DYNAMIC DATASETS) ----
# Kafka is a technology that Spark works well with
# * Input Directory ----
dir_create("stream_input")

mtcars %>% write_csv("stream_input/cars_1.csv")

# * Start a Stream ----
stream <- stream_read_csv(sc, "stream_input/") 

stream %>%
    select(mpg, cyl, disp) %>%
    stream_write_csv("stream_output/")

mtcars %>% write_csv("stream_input/cars_2.csv")

# * Stop the stream ----
# (if this doesn't work, just disconnect spark)
stream_stop(stream)

spark_disconnect_all()

