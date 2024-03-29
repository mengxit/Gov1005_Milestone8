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
                                
immigration_continent_long <- read_csv("immigration_continent_long.csv")

immigration_country <- read_csv("immigration_country.csv")

immigration_country_long <- read_csv("immigration_country_long.csv")


# percent function for formatting
percent <- function(x, digits = 1, format = "f", ...) {
    paste0(formatC(100 * x, format = format, digits = digits, ...), "%")
}

                            
# define UI for application that draws a histogram
# create Navigation bar for both overview and by country
# create an input for selecting specific country to examine

ui<- navbarPage("Gov1005 Final Project: US Immigration Explorer",
                tabPanel("Overview",
                         headerPanel("IMMIGRATION INTO US BY SOURCE COUNTRY - WILL UPDATE TEXT"),
                         sliderInput("year", "Year:",
                                     min = 2009, max = 2017,
                                     value = 2009),
                         #imageOutput("overview", width = "20%", height = "20%"),
                         plotOutput("barchart")
                        
                         ),
                tabPanel("A Closer Look",
                         headerPanel("CLOSER LOOK INTO A SOURCE COUNTRY - PLEASE SELECT - WILL UPDATE TEXT"),
                         fluidRow(
                          column(8, align="left",
                          selectInput("variable", "Country:",
                                                list("China" = "China, People's Republic", 
                                                     "Mexico" = "Mexico", 
                                                     "India" = "India")),
                         plotOutput("trendchart")),
                         column(3, align = "right",
                         plotOutput("donut")))
))


# define server
server <- function(input, output, session){
  
  # render the opening page
  output$overview <- renderImage(
    list(src = "intro_graph.png"),
    deleteFile = FALSE
  )
  
  # render the bar chart on the opening page
  
  output$barchart <- renderPlot({
    
    # filter down to top 20 countries in a particular year
    immigration_current10 <- immigration_country %>%
                                          filter(year == as.numeric(input$year)) %>%
                                          arrange(desc(total)) %>%
                                          head(20)
    
    # create bar chart
    barchart <- ggplot(immigration_current10, 
                       aes(x = reorder(country, -total), y = total)) + 
      geom_col(aes(fill = total)) + 
      theme(axis.text.x = element_text(angle = 90, hjust = 1)) + 
      scale_fill_gradient2(low = "blue", high = "red", midpoint = median(immigration_current10$total)) +
      labs(x = "Country", y = "Total Immigrants",title = paste0("20 Source Countries with Most Immigrants into US in ", input$year))
      
    # return image
    
    print(barchart)
    
  })
  
  
# render the trend chart on the left
  output$trendchart <- renderPlot({
    
    # this chart is going to be the graph shown on the left
    immigration_country_current <- immigration_country_long %>% 
      filter(country == input$variable)
    
    # create the chart
    graph_left <- ggplot(immigration_country_current, 
                         aes(x = year, y = count, fill = admission_class)) +
        geom_area(position = 'stack') + 
        labs(y = "Total Immigrants", x = "Year", 
             fill = "Admission Class", 
             title = paste0("Immigration Overview from ", input$variable,  " to US")) + 
        scale_fill_discrete(labels = c("Diversity", "Employment",
                                       "Immediate Relatives", "Other Relatives", "Refugee", "Other")) +  
        scale_x_continuous(breaks = c(2009, 2011, 2013, 2015, 2017))
    
    print(graph_left)
  })
 
# render language donut chart
  output$donut <- renderPlot({
      
      # this chart is going to be shown on the right
      english_country_current <- english_country %>%
          filter(country == input$variable)
      
      # make a summary chart
      english_country_current_summary <- english_country_current %>%
          summarize(total = sum(total_number), 
                    total_very_well = sum(population_very_well),
                    not_very_well = total - total_very_well) %>%
          select(total_very_well, not_very_well)
      
      # gather information from long to short format
      english_country_current_summary <- english_country_current_summary%>%
          gather(key = "english", value = "population",total_very_well:not_very_well)
      
      # compute percentages
      english_country_current_summary$fraction = english_country_current_summary$population / sum(english_country_current_summary$population)
      
      # compute the cumulative percentages (top of each rectangle)
      english_country_current_summary$ymax = cumsum(english_country_current_summary$fraction)
      
      # compute the bottom of each rectangle
      english_country_current_summary$ymin = c(0, head(english_country_current_summary$ymax, n=-1))
      
      donut <- ggplot(english_country_current_summary, 
          aes(ymax = ymax, ymin=ymin, 
          xmax=4, xmin=3, fill=english)) +
          geom_rect() +
          coord_polar(theta = "y") +
          xlim(c(2, 4)) + 
          scale_fill_discrete(labels = c("Not Very Well", "Very Well")) +
          labs(title = paste0(percent(english_country_current_summary$fraction[1]) ,
                              "  immigrants from ", input$variable, " Speak English Very Well"),
                             fill = "English Speaking Ability", 
                        caption = "Average during 2007 - 2016") +
          theme(axis.text.y=element_blank(), 
                axis.ticks=element_blank())
      
      print(donut)
  })  
  
}

# Run the application 
shinyApp(ui = ui, server = server)

