#
# this is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
library(markdown)
library(shiny)
library(ggplot2)
library(tidyverse)

# read clean data into Shiny
english_continent <- read_csv("english_continent.csv")
                             
english_country <- read_csv("english_country.csv")
                            
immigration_continent <- read_csv("immigration_continent.csv")
                                
immigration_country <- read_csv("immigration_country.csv")
                                

# define UI for application that draws a histogram
# create Navigation bar for both overview and by country
# create an input for selecting specific country to examine

ui<- navbarPage("Gov1005 Final Project: US Immigration Explorer",
                tabPanel("Overview",
                         mainPanel(
                             "PLACE HOLDER"
                         )),
                tabPanel("A Closer Look",
                         headerPanel("PLACE HOLDER"),
                         sidebarPanel(
                            selectInput("variable", "Country:",
                                        list("China" = "China, People's Republic", 
                                            "Mexico" = "Mexico", 
                                            "India" = "India"))
                         ),
                         imageOutput("trendchart"))
)


# define server
server <- function(input, output, session){
  
# render the trend chart on the left
  output$trendchart <- renderPlot({
    
    # this chart is going to be the graph shown on the left
    immigration_country_current <- immigration_country %>% 
      filter(country == input$variable)
  
    graph_left <- ggplot(immigration_country_current) + geom_col(aes(x = year, y = total)) + labs(title = paste0("Current Country :", input$variable))
    
    print(graph_left)
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

