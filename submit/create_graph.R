# libraries
library(rtweet)
library(igraph)
library(tidyverse)
library(rjson)

# read any command line arguments
args = commandArgs(trailingOnly=TRUE)
NUM_TWEETS = 1000

# sanity check
print(args)

# ensure proper command line arguments have been supplied
if(length(args) == 0) {
    stop("Please supply your search term as an argument!")
}

# get filename and search term
FILENAME = paste(args, collapse = "_")
SEARCH_TERM = paste(args, collapse = " ")

FILENAME = gsub(" ", "_", FILENAME)
FILENAME = gsub("'", "", FILENAME)
FILENAME = gsub("#", "", FILENAME)

# sanity check
print(paste("filename...", FILENAME, sep = ""))
print(paste("searching for term...", SEARCH_TERM, sep = ""))

# read in credentials
json_file = "./secret/twitter_creds.json"
json_data = fromJSON(readLines(json_file))

# create token for twitter api
create_token(
  app = json_data$app_name,
  consumer_key = json_data$api_key,
  consumer_secret = json_data$api_key_secret,
  access_token = json_data$access_token,
  access_secret = json_data$access_token_secret
) -> twitter_token

request_complete = FALSE

while(!request_complete){
    tryCatch({
        # search for tweets matching term
        tweets.df <- search_tweets(SEARCH_TERM, n=NUM_TWEETS,token=twitter_token,retryonratelimit = TRUE)

        # create network of tweets
        net <- network_graph(tweets.df, e = c("retweet"))

        request_complete = TRUE
    }, error = function(e) {
        print("error encountered:")
        print(e)
        print("retrying...")
    }, finally = {
        # save the rdata
        save.image(paste("datasets/", FILENAME, ".RData", sep = ""))
    })
}
