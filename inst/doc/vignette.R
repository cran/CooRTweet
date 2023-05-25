## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)
library(CooRTweet)

## ----results='hide'-----------------------------------------------------------
library(CooRTweet)
russian_coord_tweets

## ----results='hide'-----------------------------------------------------------
length(russian_coord_tweets$content_id) == nrow(russian_coord_tweets)


## ----results='hide'-----------------------------------------------------------
result <- detect_coordinated_groups(russian_coord_tweets, 
                                    min_repetition = 5, 
                                    time_window = 10)

## ----results='hide'-----------------------------------------------------------
summary_groups <- group_stats(result)


## ----results='hide'-----------------------------------------------------------
summary_users <- user_stats(result)


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
#  result <- detect_coordinated_groups(retweets, time_window = 60, min_repetition = 10)

## ----results='hide', eval=FALSE-----------------------------------------------
#  hashtags <- reshape_tweets(tweets, intent = "hashtags")
#  result <- detect_coordinated_groups(hashtags, time_window = 60, min_repetition = 10)

## ----results='hide', eval=FALSE-----------------------------------------------
#  urls <- reshape_tweets(tweets, intent = "urls")
#  result <- detect_coordinated_groups(urls, time_window = 60, min_repetition = 10)

## ----results='hide', eval=FALSE-----------------------------------------------
#  urls <- reshape_tweets(tweets, intent = "urls_domain")
#  result <- detect_coordinated_groups(urls, time_window = 60, min_repetition = 10)

## ----results='hide', eval=FALSE-----------------------------------------------
#  summary_groups <- group_stats(result)

## ----results='hide', eval=FALSE-----------------------------------------------
#  library(data.table)
#  # rename tweet column
#  setnames(summary_groups, "object_id", "tweet_id")
#  summary_groups <- tweets$tweets[summary_groups, on = "tweet_id"]

## ----results='hide', eval=FALSE-----------------------------------------------
#  summary_users <- user_stats(result)

## ----results='hide', eval=FALSE-----------------------------------------------
#  library(data.table)
#  
#  # rename user column
#  setnames(summary_users, "id_user", "user_id")
#  
#  # join with pre-processed user data
#  summary_users <- users[summary_users, on = "user_id"]

## ----results='hide', eval=FALSE-----------------------------------------------
#  library(igraph)
#  
#  coord_graph <- generate_network(result, intent = "objects")
#  
#  # E.g., get the degree of each node for filtering
#  igraph::V(coord_graph)$degree <- igraph::degree(coord_graph)
#  
#  # Or we can run a community detection algorithm
#  igraph::V(coord_graph)$cluster <- igraph::cluster_louvain(coord_graph)$membership

## ----results='hide', eval=FALSE-----------------------------------------------
#  library(data.table)
#  dt <- data.table(tweet_id=V(coord_graph)$name,
#                  cluster=V(coord_graph)$cluster,
#                  degree=V(coord_graph)$degree)
#  
#  dt_joined <- tweets$tweets[dt, on = "tweet_id"]

