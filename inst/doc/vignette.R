## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)
library(CooRTweet)

## ----results='hide'-----------------------------------------------------------
library(CooRTweet)
set.seed(123)
russian_coord_tweets

## ----results='hide'-----------------------------------------------------------
length(russian_coord_tweets$content_id) == nrow(russian_coord_tweets)

## ----results='hide'-----------------------------------------------------------
result <- detect_groups(russian_coord_tweets,
                        min_participation = 2,
                        time_window = 600)

## -----------------------------------------------------------------------------
combined_accounts <- c(result$account_id, result$account_id_y)
combined_accounts_dt <- data.table::data.table(account_id = combined_accounts)
account_counts <- combined_accounts_dt[, .N, by = account_id]

russian_coord_tweets <- data.table::as.data.table(russian_coord_tweets)
raw_counts <- russian_coord_tweets[, .N, by = account_id]
raw_counts_included <- raw_counts[account_id %in% combined_accounts] 

# min_participation
min(raw_counts_included$N)

## -----------------------------------------------------------------------------
coord_graph <- generate_coordinated_network(result, edge_weight = 0.99, objects = TRUE)

## ----results='hide'-----------------------------------------------------------
library(igraph)

min(E(coord_graph)$weight[E(coord_graph)$weight_threshold == 1])

## ----results='hide'-----------------------------------------------------------
summary_groups <- group_stats(coord_graph = coord_graph, weight_threshold = "full")

## ----results='hide'-----------------------------------------------------------
summary_accounts <- account_stats(coord_graph = coord_graph, result = result, weight_threshold = "full")

## -----------------------------------------------------------------------------
result_update <- flag_speed_share(russian_coord_tweets, result, min_participation = 2, time_window = 120)

## -----------------------------------------------------------------------------
coord_graph_fast <-
  generate_coordinated_network(
    result_update,
    fast_net = TRUE,
    edge_weight = 0.99,
    subgraph = 2
  )

## ----eval=FALSE---------------------------------------------------------------
#  prep_data <-
#    function(x,
#             object_id = NULL,
#             account_id = NULL,
#             content_id = NULL,
#             timestamp_share = NULL
#    )

## ----results='hide', eval=FALSE-----------------------------------------------
#  # load data
#  
#  raw <- load_tweets_json('path/to/data/with/jsonfiles')
#  users <- load_twitter_users_json('path/to/data/with/jsonfiles')

## ----results='hide', eval=FALSE-----------------------------------------------
#  # preprocess (unnest) data
#  
#  tweets <- preprocess_tweets(raw)
#  users <- preprocess_twitter_users(users)

## ----results='hide', eval=FALSE-----------------------------------------------
#  # reshape data
#  retweets <- reshape_tweets(tweets, intent = "retweets")
#  
#  # detect coordinated tweets
#  result <- detect_groups(retweets, time_window = 60, min_participation = 10)
#  coord_graph <- generate_coordinated_network(result, edge_weight = 0.95)
#  

## ----results='hide', eval=FALSE-----------------------------------------------
#  hashtags <- reshape_tweets(tweets, intent = "hashtags")
#  result <- detect_groups(hashtags, time_window = 60, min_participation = 10)
#  coord_graph <- generate_coordinated_network(result, edge_weight = 0.95)
#  

## ----results='hide', eval=FALSE-----------------------------------------------
#  urls <- reshape_tweets(tweets, intent = "urls")
#  result <- detect_groups(urls, time_window = 60, min_participation = 10)
#  coord_graph <- generate_coordinated_network(result, edge_weight = 0.95)
#  

## ----results='hide', eval=FALSE-----------------------------------------------
#  urls <- reshape_tweets(tweets, intent = "urls_domain")
#  result <- detect_groups(urls, time_window = 60, min_participation = 10)
#  coord_graph <- generate_coordinated_network(result, edge_weight = 0.95)
#  

## ----results='hide', eval=FALSE-----------------------------------------------
#  summary_groups <- group_stats(coord_graph = coord_graph, weight_threshold = "full")
#  

## ----results='hide', eval=FALSE-----------------------------------------------
#  summary_accounts <- account_stats(coord_graph = coord_graph, result = result, weight_threshold = "fast")

