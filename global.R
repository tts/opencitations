library(shiny)
library(shinydashboard)
library(DT)

data <- read.csv("doi_cites_df.csv", stringsAsFactors = FALSE)
names(data) <- c("DOI", "About", "OCC_cites", "Crossref_cites", "Percentage")
