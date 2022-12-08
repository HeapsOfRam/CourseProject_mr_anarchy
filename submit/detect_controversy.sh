#!/bin/bash

search_term=$@

Rscript create_graph.R $search_term
./calculate $search_term
