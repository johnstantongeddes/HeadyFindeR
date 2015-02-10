library(shiny)

# Define UI for random distribution application 
shinyUI(fluidPage(
    
  # Application title
  titlePanel("Heady Finder!"),
  
  # Sidebar with controls to select the random distribution type
  # and number of observations to generate. Note the use of the
  # br() element to introduce extra vertical spacing
  sidebarLayout(
    sidebarPanel(
      textInput("whereuare", label = "Where are you?",
                value = "UVM, Burlington, VT"),
      submitButton("Submit")
      ),
      mainPanel(
        plotOutput("mapplot")
      )
    )
))
