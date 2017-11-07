library(SPARQL)
library(tidyverse)
library(rcrossref)

#--A set of Aalto University publication DOI's from 2013-2016-------------------------------
aaltodata <- read.csv("aalto_csc_cleaned_dois.csv", sep = "|", stringsAsFactors = F, quote = "")

#--Query OpenCitations Corpus for citation counts-------------------------------------------

doi_q_occ <- function(doi) {
  
  Sys.sleep(3)
  
  endpoint <- "http://opencitations.net/sparql"
  
  q <- paste0("PREFIX cito: <http://purl.org/spar/cito/>
              PREFIX dcterms: <http://purl.org/dc/terms/>
              PREFIX datacite: <http://purl.org/spar/datacite/>
              PREFIX literal: <http://www.essepuntato.it/2010/06/literalreification/>
              SELECT ?citing ?title WHERE {
              ?id a datacite:Identifier ;
              datacite:usesIdentifierScheme datacite:doi ;
              literal:hasLiteralValue '", doi, "' .
              ?br 
              datacite:hasIdentifier ?id ;
              ^cito:cites ?citing .
              ?citing dcterms:title ?title
              }")
  
  answer <- SPARQL(url = endpoint, q, format = "xml")
  result_df <- answer$results
  
  if( nrow(answer$results) > 0 ) {
    result_df$doi_queried <- doi
  } else {
    result_df[1, "doi_queried"] <- doi
  }
  
  return(result_df)
}

# Can be done in one go like this (takes roughly an hour) but in practice, did in chunks (each 20 min)
old <- Sys.time()
q_result <- map_df(aaltodata$doi, ~ doi_q_occ(.x))
new <- Sys.time() - old

write.csv(q_result, "occ_q_result.csv", row.names = F)

# Only those that have been cited
cited <- q_result[!is.na(q_result$citing),]

cited_stats <- cited %>% 
  group_by(doi_queried) %>% 
  summarise(TimesCited = n()) %>% 
  arrange(desc(TimesCited))

#--Query Crossref for cites there, and metadata---------------------------

doi_q_crossref <- function(doi) {
  
  crossref_cites <- cr_citation_count(doi)
  crossref_metadata <- cr_cn(doi, format = "text", style = "apa")
  thisdoi <- doi
  df <- as.data.frame(cbind(thisdoi, crossref_metadata, crossref_cites), stringsAsFactors = FALSE)
  
}

crossref_cites_df <- map_df(cited_stats$doi_queried, ~ doi_q_crossref(.x))
doi_cites_df <- left_join(cited_stats, crossref_cites_df, by = c("doi_queried"="thisdoi"))
names(doi_cites_df) <- c("doi", "OOC_cites", "About", "Crossref_cites")

doi_cites_df <- doi_cites_df %>% 
  mutate(Perc = round(OOC_cites / as.integer(Crossref_cites) * 100, digits = 2)) %>% 
  arrange(Perc) %>% 
  select(doi, About, OOC_cites, Crossref_cites, Perc)

# median(doi_cites_df$Perc)

write.csv(doi_cites_df, "doi_cites_df.csv", row.names = FALSE)

