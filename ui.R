sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Data", tabName = "data", icon = icon("dashboard")),
    HTML("<div class='form-group shiny-input-container'><p>Citations by <a href='http://opencitations.net/corpus'>OpenCitations Corpus</a> and <a href='https://www.crossref.org/services/metadata-delivery/rest-api/'>Crossref</a> as of 2017-11-07</p></div>"),
    HTML("<div class='form-group shiny-input-container'><p>R source code of <a href='https://github.com/tts/opencitations'>querying data, and building this web app</a></p></div>")
    
  ), width = 180
)


body <- dashboardBody(
  
  tabItems(
    
    tabItem("data",
            fluidRow(
              box(title = "Table",
                  status = "info",
                  solidHeader = TRUE,
                  width = 12,
                  DT::dataTableOutput("datatable", 
                                      height = "600px"))
              )
    )
  )
)


dashboardPage(
  dashboardHeader(title = "OCC and Crossref citation counts of a set of Aalto University publications 2013-2015",
                  titleWidth = "700"),
  sidebar,
  body,
  skin = "black"
)

