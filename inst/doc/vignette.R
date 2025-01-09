## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)
library(CooRTweet)

## ----install, eval = FALSE----------------------------------------------------
#  # Install from CRAN
#  install.packages("CooRTweet")
#  
#  # Or install the development version from GitHub
#  devtools::install_github("username/CooRTweet") # Replace with actual GitHub repository

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

## ----generate-network---------------------------------------------------------
graph <- generate_coordinated_network(
  result,
  edge_weight = 0.5
)
graph

## ----multi-modal-analysis-----------------------------------------------------
# Example datasets for different content types
head(german_elections)

# Prepare data --------------------

# URLs
urls_data <- prep_data(german_elections,
                       object_id = "url_id",
                       account_id = "account_id",
                       content_id = "post_id",
                       timestamp_share = "timestamp")

urls_data <- unique(urls_data,
                    by = c("object_id", "account_id", "content_id", "timestamp_share"))

urls_data <- urls_data[!is.na(object_id)]

urls_data$object_id <- paste0("url_", urls_data$object_id)

# images (pHash)
img_data <- prep_data(german_elections,
                      object_id = "phash_id",
                      account_id = "account_id",
                      content_id = "post_id",
                      timestamp_share = "timestamp")

img_data <- unique(img_data,
                   by = c("object_id", "account_id", "content_id", "timestamp_share"))

img_data <- img_data[!is.na(object_id)]

img_data$object_id <- paste0("hash_", img_data$object_id)


# Detect coordinated groups for URLs and hashtags  --------------------
result_urls <- detect_groups(urls_data, time_window = 30,
                             min_participation = 2)

result_images <- detect_groups(img_data, time_window = 30,
                               min_participation = 2)

# Combine results  --------------------
library(data.table)

combined_results <- rbindlist( 
    list(result_urls, result_images),
    use.names = TRUE,
    fill = TRUE
)

# Generate the coordinated multi-modal network  --------------------
graph <- generate_coordinated_network(combined_results, edge_weight = 0.5)
graph

## ----visualize-network, eval = FALSE------------------------------------------
#  library(igraph)
#  plot.igraph(
#      graph,
#      layout = layout.fruchterman.reingold,
#      edge.width = 0.5,
#      edge.curved = 0.3,
#      vertex.size = 3,
#      vertex.frame.color = "grey",
#      vertex.frame.width = 0.1,
#      vertex.label = NA
#  )

