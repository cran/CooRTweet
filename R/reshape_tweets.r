#' reshape_tweets
#'
#' @description
#' Reshape twitter data for coordination detection.
#'
#' @details
#' This function takes the pre-processed Twitter data
#' (output of \link{preprocess_tweets}) and reshapes it
#' for coordination detection (\link{detect_coordinated_groups}).
#' You can choose the intent for reshaping the data. Use
#' `"retweets"` to detect coordinated retweeting behaviour;
#' `"hashtags"` for coordinated usage of hashtags;
#' `"urls"` to detect coordinated link sharing behaviour;
#' `"urls_domain"` to detect coordinated link sharing behaviour
#' at the domain level.
#' `"cotweet"` to detect coordinated cotweeting behaviour
#' (users posting same text).
#' The output of this function is a reshaped `data.table` that
#' can be passed to \link{detect_coordinated_groups}.
#'
#' @param tweets a named list of Twitter data
#' (output of \link{preprocess_tweets})
#'
#' @param intent the desired intent for analysis.
#' @param drop_retweets Option passed to `intent = "cotweet"`.
#' When analysing tweets based on text similarity, you can choose to drop
#' all tweets that are retweets. Default: TRUE
#' @param drop_replies Option passed to `intent = "cotweet"`.
#' When analysing tweets based on text similarity, you can choose to drop
#' all tweets that are replies to other tweets. Default: TRUE
#' @param drop_hashtags Option passed to `intent = "cotweet"`. You can choose to
#' remove all hashtags from the tweet texts. Default: FALSE
#'
#' @return a reshaped data.table
#'
#' @import data.table
#'
#' @export
#'


reshape_tweets <- function(
    tweets,
    intent = c("retweets", "hashtags", "urls", "urls_domains", "cotweet"),
    drop_retweets = TRUE,
    drop_replies = TRUE,
    drop_hashtags = FALSE) {
    start <- tweet_id <- type <- referenced_tweet_id <- object_id <- id_user <-
        text <- text_normalized <- domain <- NULL
    if (!inherits(tweets, "list")) {
        stop("Provided data probably not preprocessed yet.")
    }

    required_elements <- c(
        "tweets",
        "referenced",
        "urls",
        "mentions",
        "hashtags"
    )

    for (el in required_elements) {
        if (!el %in% names(tweets)) {
            stop(
                paste("Provided data does not have the right structure.
                Please ensure the list contains:", el)
            )
        }
    }

    output_cols <- c("object_id", "id_user", "content_id", "timestamp_share")

    if (intent == "retweets") {
        # Mapping overview
        # referenced_tweet_id --> object_id
        # author_id --> id_user
        # tweet_id --> content_id:
        # created_timestamp --> timestamp_share

        # filter only mentions that start at position 3
        # these are direct retweets:
        # "RT @username"

        candidates <- tweets$mentions[start == 3, tweet_id]
        retweets <- tweets$referenced[tweet_id %in% candidates]
        retweets <- retweets[type == "retweeted"]

        # join meta data with referenced tweets
        retweets <- tweets$tweets[retweets, on = "tweet_id"]

        # attach original tweets, we need the timestamps

        filt <- tweets$tweets$tweet_id %in% retweets$referenced_tweet_id

        original_tweets <- tweets$tweets[filt]
        original_tweets[, referenced_tweet_id := tweet_id]

        tweet_cols <- c(
            "referenced_tweet_id",
            "author_id",
            "tweet_id",
            "created_timestamp"
        )

        retweets <- rbind(
            retweets[, tweet_cols, with = FALSE],
            original_tweets[, tweet_cols, with = FALSE]
        )

        data.table::setnames(retweets, tweet_cols, output_cols)
        data.table::setindex(retweets, object_id, id_user)

        return(retweets)
    } else if (intent == "hashtags") {
        # Mapping overview
        # hashtag --> object_id
        # author_id --> id_user
        # tweet_id --> content_id:
        # created_timestamp --> timestamp_share

        # join meta data with hashtags table
        hashtags <- tweets$tweets[tweets$hashtags, on = "tweet_id"]

        tweet_cols <- c("tag", "author_id", "tweet_id", "created_timestamp")
        hashtags <- hashtags[, tweet_cols, with = FALSE]

        data.table::setnames(hashtags, tweet_cols, output_cols)
        data.table::setindex(hashtags, object_id, id_user)

        return(hashtags)
    } else if (intent == "urls") {
        # Mapping overview
        # expanded_url --> object_id
        # author_id --> id_user
        # tweet_id --> content_id:
        # created_timestamp --> timestamp_share

        # remove Twitter's internal URLs
        filt <- startsWith(tweets$urls$expanded_url, "https://twitter.com")
        urls <- tweets$urls[!filt]

        # join meta data with urls table
        urls <- tweets$tweets[urls, on = "tweet_id"]

        tweet_cols <- c(
            "expanded_url",
            "author_id",
            "tweet_id",
            "created_timestamp"
        )

        urls <- urls[, tweet_cols, with = FALSE]

        data.table::setnames(urls, tweet_cols, output_cols)
        data.table::setindex(urls, object_id, id_user)

        return(urls)
    } else if (intent == "urls_domains") {
        # Mapping overview
        # domain --> object_id
        # author_id --> id_user
        # tweet_id --> content_id:
        # created_timestamp --> timestamp_share

        # remove Twitter's internal URLs
        filt <- startsWith(tweets$urls$expanded_url, "https://twitter.com")
        domains <- tweets$urls[!filt]

        # remove prefix "www" to normalize domain names
        domains[, domain := gsub("www\\.", "", domain)]

        # join meta data with urls table
        domains <- tweets$tweets[domains, on = "tweet_id"]

        tweet_cols <- c("domain", "author_id", "tweet_id", "created_timestamp")
        domains <- domains[, tweet_cols, with = FALSE]

        data.table::setnames(domains, tweet_cols, output_cols)
        data.table::setindex(domains, object_id, id_user)

        return(domains)
    } else if (intent == "cotweet") {
        # Mapping overview
        # text_normalized --> object_id
        # author_id --> id_user
        # tweet_id --> content_id:
        # created_timestamp --> timestamp_share
        referenced_tweets <- tweets$referenced
        cotweets <- tweets$tweets

        # filter out retweets
        if (drop_retweets) {
            filt <- cotweets$tweet_id %in% referenced_tweets[type == "retweeted", ]$tweet_id
            cotweets <- cotweets[!filt, ]
        }
        if (drop_replies) {
            filt <- cotweets$tweet_id %in% referenced_tweets[type == "replied_to", ]$tweet_id
            cotweets <- cotweets[!filt, ]
        }

        # normalize text
        cotweets[, text_normalized := normalize_text(text)]
        if (drop_hashtags) {
            cotweets[, text_normalized := remove_hashtags(text)]
        }
        data.table::setindex(cotweets, text_normalized)

        tweet_cols <- c("text_normalized", "author_id", "tweet_id", "created_timestamp")
        cotweets <- cotweets[, tweet_cols, with = FALSE]

        data.table::setnames(cotweets, tweet_cols, output_cols)
        data.table::setindex(cotweets, object_id)
        data.table::setindex(cotweets, id_user)

        return(cotweets)
    } else {
        .NotYetImplemented()
    }
}


#' Normalize text
#'
#' @description
#' Utility function that normalizes text by removing mentions of other users, removing "RT",
#' converting to lower case, and trimming whitespace.
#'
#' @param x The text to be normalized.
#'
#' @return The normalized text.
#'
#' @export

normalize_text <- function(x) {
    # remove mentions of other users
    x <- gsub("@.+?(\\s|$)", "", x)
    # remove "RT"
    x <- gsub("RT", "", x)
    x <- trimws(tolower(x))
    return(x)
}


#' Remove hashtags
#'
#' @description
#' Utility function that removes hashtags from tags.
#'
#' @param x The text to be processed.
#'
#' @return The text without hashtags.
#'
#' @export

remove_hashtags <- function(x) {
    # remove hashtags from text
    x <- gsub("#.+?(\\s|$)", "", x)
    return(x)
}
