library(shiny)
library(shinydashboard)
library(DT)

data <- read.csv("doi_cites_df.csv", stringsAsFactors = FALSE)
