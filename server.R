function(input, output, session) {
  
  output$datatable <- DT::renderDataTable({
    
    data$doi <- sapply(data$doi, function(x) {
      paste0("<a href='http://dx.doi.org/", x, "'>", x, "</a>")
    })
  
    data
    
    }, escape = FALSE, options = list(scrollX = T)
 )
  
  
}
