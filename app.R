# app.R
# Water Quality Dashboard - Shiny App

library(shiny)
library(leaflet)
library(plotly)
library(dplyr)
library(tidyr)
library(dataRetrieval)
library(DT)
library(lubridate)

# Source the data fetching script
source("scripts/fetch_data.R")

# Fetch data once when app loads
wq_list <- fetch_usgs_wq_data(state_cd = "AZ", 
                              start_date = "2023-01-01",
                              parameter_codes = c("00010", "00300", "00400"))

wq_data <- wq_list$data
sites <- wq_list$sites

# Clean and prepare data
wq_clean <- wq_data %>%
  mutate(date = as.Date(sample_dt),
         year = year(date),
         month = month(date, label = TRUE)) %>%
  select(site_no, station_nm, date, year, month,
         dec_lat_va, dec_long_va, parm_cd, result_va) %>%
  filter(!is.na(result_va))

# Add parameter names
param_names <- data.frame(
  parm_cd = c("00010", "00300", "00400"),
  parameter = c("Temperature (°C)", "Dissolved Oxygen (mg/L)", "pH")
)

wq_clean <- left_join(wq_clean, param_names, by = "parm_cd")

# UI
ui <- fluidPage(
  titlePanel("Water Quality Dashboard - Arizona USGS Monitoring Stations"),
  
  theme = bslib::bs_theme(
    bg = "#fdfaf5", 
    fg = "#3d4f3a", 
    primary = "#6b8f5e"
  ),
  
  sidebarLayout(
    sidebarPanel(
      h4("Dashboard Controls"),
      
      selectInput("parameter",
                  "Select Parameter:",
                  choices = unique(wq_clean$parameter),
                  selected = "Temperature (°C)"),
      
      dateRangeInput("date_range",
                     "Date Range:",
                     start = min(wq_clean$date),
                     end = max(wq_clean$date),
                     min = min(wq_clean$date),
                     max = max(wq_clean$date)),
      
      hr(),
      
      h4("About"),
      p("This dashboard visualizes water quality data from USGS monitoring stations across Arizona."),
      p("Data source: USGS National Water Information System (NWIS)"),
      
      hr(),
      
      h4("Summary Statistics"),
      tableOutput("summary_table")
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Map",
                 br(),
                 leafletOutput("map", height = 500)),
        
        tabPanel("Time Series",
                 br(),
                 plotlyOutput("timeseries", height = 500)),
        
        tabPanel("Distribution",
                 br(),
                 plotlyOutput("boxplot", height = 500)),
        
        tabPanel("Data Table",
                 br(),
                 DTOutput("data_table"))
      )
    )
  )
)

# Server
server <- function(input, output, session) {
  
  # Reactive filtered data
  filtered_data <- reactive({
    wq_clean %>%
      filter(parameter == input$parameter,
             date >= input$date_range[1],
             date <= input$date_range[2])
  })
  
  # Map
  output$map <- renderLeaflet({
    site_summary <- filtered_data() %>%
      group_by(site_no, station_nm, dec_lat_va, dec_long_va) %>%
      summarise(
        n_samples = n(),
        mean_value = round(mean(result_va, na.rm = TRUE), 2),
        .groups = "drop"
      )
    
    leaflet(site_summary) %>%
      addTiles() %>%
      addCircleMarkers(
        lng = ~dec_long_va,
        lat = ~dec_lat_va,
        radius = 8,
        color = "#3d4f3a",
        fillColor = "#6b8f5e",
        fillOpacity = 0.7,
        popup = ~paste0(
          "<b>", station_nm, "</b><br/>",
          "Site ID: ", site_no, "<br/>",
          "Samples: ", n_samples, "<br/>",
          "Mean ", input$parameter, ": ", mean_value
        )
      )
  })
  
  # Time series plot
  output$timeseries <- renderPlotly({
    plot_ly(filtered_data(), 
            x = ~date, 
            y = ~result_va,
            color = ~station_nm,
            type = 'scatter', 
            mode = 'markers+lines',
            marker = list(size = 6),
            hoverinfo = 'text',
            text = ~paste0(
              station_nm, "<br>",
              input$parameter, ": ", round(result_va, 2), "<br>",
              "Date: ", date
            )) %>%
      layout(
        title = paste(input$parameter, "Over Time"),
        xaxis = list(title = "Date"),
        yaxis = list(title = input$parameter),
        hovermode = 'closest',
        showlegend = TRUE
      )
  })
  
  # Box plot
  output$boxplot <- renderPlotly({
    plot_ly(filtered_data(), 
            x = ~station_nm,
            y = ~result_va,
            type = "box",
            marker = list(color = "#6b8f5e")) %>%
      layout(
        title = paste("Distribution of", input$parameter, "by Site"),
        xaxis = list(title = ""),
        yaxis = list(title = input$parameter)
      )
  })
  
  # Summary table
  output$summary_table <- renderTable({
    filtered_data() %>%
      summarise(
        Samples = n(),
        Mean = round(mean(result_va, na.rm = TRUE), 2),
        Median = round(median(result_va, na.rm = TRUE), 2),
        Min = round(min(result_va, na.rm = TRUE), 2),
        Max = round(max(result_va, na.rm = TRUE), 2)
      )
  })
  
  # Data table
  output$data_table <- renderDT({
    filtered_data() %>%
      select(Date = date, 
             Site = station_nm,
             Parameter = parameter,
             Value = result_va) %>%
      datatable(options = list(pageLength = 25))
  })
}

# Run app
shinyApp(ui = ui, server = server)
