library(rtweet)
library(igraph)
library(tidyverse)
library(rjson)

#NUM_TWEETS = 1000
#NUM_TWEETS = 50000
NUM_TWEETS = 5000
#SEARCH_TERM = "#beefban"
#SEARCH_TERM = "#zelda"
#FILENAME = "zelda"

args = commandArgs(trailingOnly=TRUE)

print(args)

if(length(args) != 1) {
    stop("Please supply your search time as an argument!")
}

#SEARCH_TERM = "#" + args[0]
FILENAME = args[1]
SEARCH_TERM = paste("#", args[1], sep = "")

print(paste("filename...", FILENAME, sep = ""))
print(paste("searching for term...", SEARCH_TERM, sep = ""))

json_file = "../secret/twitter_creds.json"
json_data = fromJSON(readLines(json_file))

##CREO EL TOKEN EN BASE A MI APLICACIÓN EN TWITTER (https://developer.twitter.com/en/apps)
create_token(
  app = json_data$app_name,
  consumer_key = json_data$api_key,
  consumer_secret = json_data$api_key_secret,
  access_token = json_data$access_token,
  access_secret = json_data$access_token_secret 
) -> twitter_token

#auth <- rtweet_app()

#BAJO LOS TWEETS
#tweets.df <- search_tweets("search", n=NUM_TWEETS,token=twitter_token,retryonratelimit = TRUE)
#tweets.df <- search_tweets("search", n=250000,token=auth,retryonratelimit = TRUE)

tweets.df <- search_tweets2(SEARCH_TERM, n=NUM_TWEETS,token=twitter_token,retryonratelimit = TRUE)
#just.tweets.df <- search_tweets(SEARCH_TERM, n=NUM_TWEETS,token=twitter_token,retryonratelimit = TRUE)
#users.df <- users_data(just.tweets.df)

#tweets.df <- cbind(users.df, just.tweets.df)
#tweets.df <- cbind(just.tweets.df, users.df)


#CREO EL GRAFO DE RETWEETS
net = network_graph(tweets.df, e = c("retweet"))

#save.image("datasets/filename.RData")
#save.image("datasets/zelda.RData")
save.image(paste("datasets/", FILENAME, ".RData", sep = ""))
#GENERO EL LAYOUT (PARA VISUALIZARLO)
