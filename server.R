library(shiny)
library(ggmap)
library(lubridate)
library(plyr)
library(dplyr)

# data
sellers <- read.csv("data/heady_sellers.csv", stringsAsFactors = FALSE)
sellers$delivery_dat_n <- ifelse(sellers$day == "Sun", 1, 
                                 ifelse(sellers$day == "Mon", 2,
                                        ifelse(sellers$day == "Tues", 3,
                                               ifelse(sellers$day == "Wed", 4,
                                                      ifelse(sellers$day == "Thur", 5,
                                                             ifelse(sellers$day == "Fri", 6, 7)
                                                      )
                                               )
                                        )
                                 )
)

locations <- geocode(sellers$address)
sellers$lat <- locations$lat
sellers$lon <- locations$lon


# Define server logic for random distribution application
shinyServer(function(input, output) {
  
  # Reactive expression to generate the requested distribution.
  # This is called whenever the inputs change. The output
  # functions defined below then all use the value computed from
  # this expression
  uarehere <- reactive({
    geocode(input$whereuare)
  })
  
  dow <- reactive({
    as.numeric(wday(Sys.Date(), label=TRUE))
  })
  
  routedf <- reactive({
    print(sellers)
    sellers_today <- filter(sellers, delivery_dat_n == dow())
    # wrap sunday to saturday
    dow_ny <- ifelse(dow() == 1, 7, dow()-1)
    sellers_yesterday <- filter(sellers, delivery_dat_n == dow()-1)
    # sellers today or yesterday
    sellers_target <- bind_rows(sellers_today, sellers_yesterday)
    # stop if no sellers
    if(nrow(sellers_target) == 0) stop("No sellers yesterday or today!")
    
    # distance to each seller
    time2seller <- arrange(
      rbind.fill(mapdist(from = as.numeric(uarehere()), to = sellers_target$address, mode="driving")),
      minutes)
      # route
      ggmap::route(from = as.character(time2seller[1, "from"]), to = as.character(time2seller[1, "to"]), mode = 'driving', structure = 'route')
      })


  # Generate a plot of the data. 
  output$mapplot <- renderPlot({
    qmap(input$whereuare, maprange = TRUE) +
      geom_path(aes(x = lon, y = lat), colour = 'red', size = 1.5,
                data = routedf(), lineend = 'round')
  })
  
})


