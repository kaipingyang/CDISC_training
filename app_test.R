library(shiny)
library(bslib)

ui <- page_fluid(
  p("test")
)

server <- function(input, output, session) {

}

shinyApp(ui, server)