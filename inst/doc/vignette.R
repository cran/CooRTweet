## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)
library(CooRTweet)

## ----install, eval = FALSE----------------------------------------------------
# # Install from CRAN
# install.packages("CooRTweet")
# 
# # Or install the development version from GitHub
# devtools::install_github("nicolarighetti/CooRTweet")

## ----data-preparation---------------------------------------------------------
library(CooRTweet)
head(russian_coord_tweets)

## ----detect-groups------------------------------------------------------------
result <- detect_groups(
  x = russian_coord_tweets,
  min_participation = 2,
  time_window = 60
)
head(result)

## ----inclusive-time-interval--------------------------------------------------
shares <- data.table::data.table(
  object_id = "url_1",
  account_id = c("A", "B", "C"),
  content_id = c("p1", "p2", "p3"),
  timestamp_share = c(0, 10, 30)
)

interval_result <- detect_groups(
  shares, time_window = 20, time_window_low = 10,
  min_participation = 1
)
sort(interval_result$time_delta)

## ----generate-network---------------------------------------------------------
graph <- generate_coordinated_network(result)
graph

## ----german-elections---------------------------------------------------------
# Example datasets for different content types
head(german_elections_sample)

## ----multimodal-urls----------------------------------------------------------
# URLs
urls_data <- prep_data(german_elections_sample,
                       object_id = "url_id",
                       account_id = "account_id",
                       content_id = "post_id",
                       timestamp_share = "timestamp")

urls_data$object_id <- paste0("url_", urls_data$object_id)

## ----multimodal-images--------------------------------------------------------
# images (pHash)
img_data <- prep_data(german_elections_sample,
                      object_id = "phash_id",
                      account_id = "account_id",
                      content_id = "post_id",
                      timestamp_share = "timestamp")

img_data$object_id <- paste0("hash_", img_data$object_id)

## ----multimodal-detect groups-------------------------------------------------
# Detect coordinated groups for URLs and images  --------------------
result_urls <- detect_groups(urls_data, time_window = 30,
                             min_participation = 2)

result_images <- detect_groups(img_data, time_window = 30,
                               min_participation = 2)


## ----url-time-interval--------------------------------------------------------
result_urls_10_30 <- detect_groups(
  urls_data, time_window = 30, time_window_low = 10,
  min_participation = 2
)
head(result_urls_10_30)

## ----multimodal-stack---------------------------------------------------------
# Combine results  --------------------
library(data.table)

combined_results <- rbindlist( 
    list(result_urls, result_images),
    use.names = TRUE,
    fill = TRUE
)

## ----multimodal-generate-network----------------------------------------------
# Generate the coordinated multi-modal network  --------------------
graph <- generate_coordinated_network(combined_results, subgraph = 1)
graph

## ----visualize-network, eval = FALSE------------------------------------------
# library(igraph)
# plot.igraph(
#     graph,
#     layout = layout.fruchterman.reingold,
#     edge.width = 0.5,
#     edge.curved = 0.3,
#     vertex.size = 3,
#     vertex.frame.color = "grey",
#     vertex.frame.width = 0.1,
#     vertex.label = NA
# )

