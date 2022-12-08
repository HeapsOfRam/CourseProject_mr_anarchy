#!/bin/bash

search_term=$1

Rscript create_graph.R $search_term
./calculate datasets/$search_term
