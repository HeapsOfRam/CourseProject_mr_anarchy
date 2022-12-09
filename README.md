# Controversial Topic Extraction

Final project for CS410: Text Information Systems

Project by Ryan March (ryanm14)

## Milestone 1: Project Proposal

I've written up [this PDF for my final project proposal](./ryanm14_cs410_final_project_proposal.pdf).

## Milestone 2: Progress Report

I've written up [this PDF for my progress report](./progress_report.pdf)

### Technology Review

As part of my progress, I have written a review on some state of the art controversy detection methods [in this PDF](https://github.com/HeapsOfRam/tech_review/blob/main/techreview.pdf)

## Milestone 3: Final Project Submission

Unfortunately, I wasn't able to quite accomplish what I had in mind for this project.
Most of it ended up being taken from prior art, as mentioned [in the Sources section](#sources).
Instead of providing an interface where a user provides a generic topic thread, and detecting controversy there, I instead ask the user for a search query (which I refer to as a "topic" later in this document), and the script then pulls down the most recent Tweets that match that query, to detect if the recent discussion seems controversial or not.

Please see [the Documentation header in this README](#documentation) for details around setup, usage, and general goals and results of the project.

## Documentation

### Motivation

Detecting controversy is an important task.
Controversy has obvious political implications, as the political field is rampant with controversial subjects and discussions.
This could, for example, help politicians decide what discussion topics to focus on (or avoid).
It could also help informed voters or debate moderators select particularly challenging topics to focus on, to see how different candidates handle these controversial subjects.

However, controversy is latent all around us.
Even something as simple as "pineapple on pizza" can be quite polarizing!
It would be very useful to automatically detect topics or queries that have inherent controversy to them (or at least in recent discussions).
For example, let's say I am interested in buying two video games, but I don't know which to pick.
So, I want to look at discussion around each game and understand the sentiment.
Maybe I see game 1 is controversial (in this case, that would likely mean having mixed reception instead of dealing with "controversial subjects") while game 2 has much more consolidated opinions.
Of course, the next step would be to see if game 2 is ubiquitously hated or universally loved, which is beyond the scope of controversy detection.
But, this may help me to determine if certain products don't live up to the "hype"; ie if discussion around them is more interesting than the products themselves.
This could apply to movies, restaurants -- almost anything -- and is just one specific use case for detecting controversy.

Thus, I pursued automatic, unsupervised, controversy detection for my final project.

### Approach

The approach taken here is, again, very similar to prior art, but I experimented with different parameters (like word n-gram size, etc) to see the impact.
Generally, the idea is that a discussion is made up of multiple posts.
These posts can be read in and constructed into a graph based on what post another post is responding to or other criteria.
Once the network is constructed, we try to bifurcate the data into two clusters.
Depending on how cleanly the data separates into these two clusters help to inform us how controversial a topic is.
Two (or more, in the future) clear, distinct clusters indicate that there are two polar sides to this discussion, potentially indicating controversy.
If the clusters are not very separable, it seems maybe there is more agreement in the discussion.
Based on how close the clusters are, we can assign a controversy score to the discussion/topic.

There are many possible variations from here.
For example, what kind of similarity measures do we use for posts or users?
In fact, do we want to cluster posts themselves or the users that made those posts?
And so on; there is clearly much room to explore in this subject, and I found it very interesting!

### Setup

#### API Access

You will need to do a few things to set up this code for running.
This code pulls data down via the `rtweets` library in `R`, which requires API credentials [which can be acquired here](https://developer.twitter.com/en/portal/dashboard).
You will first need a Twitter account. I created one specifically for this purpose.
Then, you can request a developer account by signing in to the aforementioned link with your account.
Specifically, I mentioned my use case was student/academic researcher (admittedly I forget which).
I mentioned I would not make data available to a government agency. 
I requested elevated access for both v1.1 and v2 access, which required me to sign up for the highest free API tier (I believe it was for "academic purposes" maybe).
Then, I was able to generate my credentials and run the code.
I put my credentials into the file `submit/secret/twitter_creds.json`, which I have explicitly ignored for version control purposes.
The R scripts read in this JSON file, which is expected to have the format:

```json
{
    "app_name": YOUR_APP_NAME,
    "api_key": YOUR_API_KEY,
    "api_secret_key": YOUR_API_SECRET
    "bearer_token": YOUR_AUTH_BEARER_TOKEN,
    "access_token": YOUR_ACCESS_TOKEN,
    "access_token_secret": YOUR_SECRET_TOKEN
}
```

Of the above values, the `bearer_token` should actually not be necessary, as I believe it is only used as an Authorization header (`Bearer` token) for HTTP/curl requests.
The `access_token` and `access_token` had to be generated in the Developer Portal (found by following the aforementioned link, after being logged in to your developer account).
As briefly mentioned, at some point you will also need to create a specific development app/project.
I called my `tis_controversy_detection`.

#### Environment Setup

##### Environment

Luckily, I was able to containerize my logic.
This means, environment setup should be trivial.
All you will need to do is build and run the docker container, which I will elaborate on [in the Usage section](#usage).

However, this code can also be run locally. I've tested this code locally using the following versions of `R`:

```
$ R --version
R version 4.1.3 (2022-03-10) -- "One Push-Up"
Copyright (C) 2022 The R Foundation for Statistical Computing
Platform: x86_64-redhat-linux-gnu (64-bit)

R is free software and comes with ABSOLUTELY NO WARRANTY.
You are welcome to redistribute it under the terms of the
GNU General Public License versions 2 or 3.
For more information about these matters see
https://www.gnu.org/licenses/.
```

and `python`:

```
$ python --version
Python 3.10.8
```

However, the versions mentioned in the Dockerfile should work as well.
As shown briefly above in the output of `R --version`, I also ran my code on a Fedora Linux PC as my primary local development environment:

```
$ uname -a
Linux localhost.localdomain 6.0.10-100.fc35.x86_64 #1 SMP PREEMPT_DYNAMIC Sat Nov 26 17:21:18 UTC 2022 x86_64 x86_64 x86_64 GNU/Linux
```

##### Install

The next important piece after getting the proper environment is to install the requisite libraries.
The required libraries for R are provided in [the `requirements.R` file](submit/requirements.R), and the required python libraries are provided in [the `requirements.txt` file](submit/requirements.txt).
To install, you can run the following commands:

```bash
# install r requirements
Rscript requirements.R
# install python requirements
# NOTE: i recommend using a virtualenv for local development, as follows:
python3 -m venv controversy
source controversy/bin/activate
pip install -r requirements.txt
```

### Usage

#### Docker/Podman

Once the setup steps have been completed, the code can be run in a couple of ways.
The recommended environment-agnostic path is by using Docker.
I have included the script I use for building and running the Docker container in the [`run_detector.sh` script](submit/run_detector.sh).
Actually, I used `podman` instead of Docker.
This should be a drop-in replacement for Docker from my experience, so in the script I just alias `docker` to `podman`.
However, for simplicity, you can just run:

```bash
tag=YOUR_DESIRED_TAG
topic=YOUR_DESIRED_SEARCH_TOPIC

docker build -t $tag .
docker run -it --env QUERY_TERM=$topic --name ControversyDetector $tag
```

Or, if you want to invoke the `run_detector.sh` script directly, you will need to provide the tag and the topic as command line arguments:

```bash
sh run_detector.sh YOUR_DESIRED_TAG YOUR_DESIRED_TOPIC
```

Please note, for the `run_detector.sh` script you must enclose `YOUR_DESIRED_TOPIC` in quotes.

#### Running Locally

I also have included the script I use to run the code locally, [in `detect_controversy.sh`](submit/detect_controversy.sh).
This script also takes command line arguments, as shown:

```bash
sh detect_controversy.sh YOUR_DESIRED_TOPIC
```

Please note!
For single term topics, this should be straightforward.
Even certain special characters (namely `#`, `'`, and ` ` [space]) are allowed for your argument.
However, for `'` character, you will need to wrap your entire term in quotes, for example:

```bash
sh detect_controversy.sh "Can't Stop"
```

This script will first run [the R code to generate the graph from downloaded user tweets](submit/create_graph.R).
Then, it will call [the included `calculate` script](submit/calculate).
This `calculate` script will run [this next R script to generate the training file](submit/create_txt.R).
After that is done, it will pass the result into the `fasttext` executable (which is also included in this repository) to generate the word vectors, which can be used to detect controversy.
The final step that the `calculate` script performs is taking the results of the `fasttext` executable and providing them to [the python `score.py` scoring file](submit/score.py), which will generate the overall controversy score, between [0,1].

## Sources

Most of this code is copied directly from the project [Measuring controversy in Social Networks through NLP](https://github.com/jmanuoz/Measuring-controversy-in-Social-Networks-through-NLP).
I additionally referenced [this controversy-detection project](https://github.com/gvrkiran/controversy-detection) when trying to create networks and run the controversy detection.

## Contributors

I worked on this project myself, Ryan March -- ryanm14
