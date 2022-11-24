# CREDITS to BUSINESS SCIENCE UNIVERSITY ----
# LEARNING LAB 65: SPARK IN R ----

# * LIBRARIES ----
library(sparklyr)
library(tidyverse)
library(tidyquant)
library(timetk)
library(janitor)
library(plotly)

# Configuration Setup (Optional)
conf <- list()
conf$`sparklyr.cores.local`         <- 6
conf$`sparklyr.shell.driver-memory` <- "16G"
conf$spark.memory.fraction          <- 0.9
conf$sparklyr.gateway.port <- 8890

# * DATA ----

nasdaq_data_tbl <- read_rds("raw_data/nasdaq_data_tbl.rds")

# Connects to Spark Locally
sc <- spark_connect(
    master  = "local", 
    version = "3.1.3", 
    config  = conf
)

# Copy data to spark
nasdaq_data <- copy_to(
    sc, 
    nasdaq_data_tbl, 
    name      = "nasdaq_data", 
    overwrite = TRUE
)

sdf_nrow(nasdaq_data)

# * SPARK + DPLYR: NASDAQ STOCK RETURNS ANALYSIS ----

nasdaq_metrics_query <- nasdaq_data %>%
    
    group_by(symbol) %>%
    arrange(date) %>%
    mutate(lag = lag(adjusted, n = 1)) %>%
    ungroup() %>%
    
    mutate(returns = (adjusted / lag) - 1 ) %>%
    
    group_by(symbol) %>%
    summarise(
        mean      = mean(returns, na.rm = TRUE),
        sd        = sd(returns, na.rm = TRUE),
        count     = n(),
        last_date = max(date, na.rm = TRUE)
    ) %>%
    ungroup() 

nasdaq_metrics_query %>% show_query()

nasdaq_metrics_tbl <- nasdaq_metrics_query %>% collect()

nasdaq_metrics_tbl

nasdaq_metrics_tbl %>% write_rds("processed_data/nasdaq_metrics.rds")


# * R DPLYR: APPLY SCREENING -----
#  - Market Cap > $1B (More stable)
#  - SD < 1 (Less Volatile)
#  - Count > 5 * 365 (More stock history to base performance)
#  - Last Date = Max Date (Makes sure stock is still active)
#  - Reward Metric: Variation of Sharpe Ratio (Mean Return / Standard Deviation, Higher Better)

nasdaq_metrics_tbl <- read_rds("processed_data/nasdaq_metrics.rds")
nasdaq_index_tbl   <- read_rds("raw_data/nasdaq_index.rds") %>%
    clean_names()

nasdaq_metrics_screened_tbl <- nasdaq_metrics_tbl %>%
    
    inner_join(
        nasdaq_index_tbl %>% select(symbol, company, market_cap), 
        by = "symbol"
    ) %>%
    
    filter(market_cap > 1e9) %>%
    
    arrange(-sd) %>%
    filter(
        sd < 1, 
        count > 365 * 5,
        last_date == max(last_date)
    ) %>%
    mutate(reward_metric = 2500*mean/sd) %>%
    mutate(desc = str_glue("
                           Symbol: {symbol}
                           Mean: {round(mean, 3)}
                           SD: {round(sd, 3)}
                           N: {count}"))

# * Visualize Screening ----
g <- nasdaq_metrics_screened_tbl %>%
    ggplot(aes(log(sd), log(mean))) +
    geom_point(aes(text = desc, color = reward_metric), 
               alpha = 0.5, shape = 21, size = 4) +
    geom_smooth() +
    scale_color_distiller(type = "div") +
    theme_minimal() +
    theme(
        panel.background = element_rect(fill = "black"),
        plot.background = element_rect(fill = "black"),
        text = element_text(colour = "white")
    ) +
    labs(title = "NASDAQ Financial Analysis")

ggplotly(g)

# * Visualize best symbols ----

n <- 9

best_symbols_tbl <- nasdaq_metrics_screened_tbl %>%
    arrange(-reward_metric) %>%
    slice(1:n) 

best_symbols <- best_symbols_tbl$symbol

stock_screen_data_tbl <- nasdaq_data_tbl %>%
    filter(symbol %in% best_symbols) 

g <- stock_screen_data_tbl %>%
    left_join(
        best_symbols_tbl %>% select(symbol, company)
    ) %>%
    group_by(symbol, company) %>%
    plot_time_series(date, adjusted, .smooth = TRUE, .facet_ncol = 3, .interactive = F) +
    geom_line(color = "white") +
    theme_minimal() +
    theme(
        panel.background = element_rect(fill = "black"),
        plot.background = element_rect(fill = "black"),
        text = element_text(colour = "white"),
        strip.text = element_text(colour = "white")
    ) +
    labs(title = "NASDAQ Financial Analysis")

ggplotly(g)