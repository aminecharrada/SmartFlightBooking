# ============================================================================
# 🛫 SMART FLIGHT BOOKING DASHBOARD
# ============================================================================
# A comprehensive R Shiny dashboard to help customers book the best flight
# by balancing price, duration, comfort, and timing.
# ============================================================================

# Load required libraries
library(shiny)
library(shinydashboard)
library(shinydashboardPlus)
library(shinyWidgets)
library(tidyverse)
library(plotly)
library(DT)
library(scales)
library(viridis)

# ============================================================================
# 🎨 PROFESSIONAL COLOR PALETTE
# ============================================================================
# Using a modern airline-inspired palette
colors <- list(
  primary = "#1E3A5F",      # Deep Navy Blue
  secondary = "#3498DB",    # Sky Blue
  accent = "#E74C3C",       # Coral Red
  success = "#27AE60",      # Emerald Green
  warning = "#F39C12",      # Golden Yellow
  info = "#9B59B6",         # Purple
  light = "#ECF0F1",        # Light Gray
  dark = "#2C3E50",         # Dark Slate
  white = "#FFFFFF",
  gradient = c("#1E3A5F", "#3498DB", "#5DADE2", "#85C1E9")
)

# Airline colors for consistency
airline_colors <- c(

  "SpiceJet" = "#E74C3C",
  "AirAsia" = "#E74C3C", 
  "Vistara" = "#8E44AD",
  "Air_India" = "#F39C12",
  "Indigo" = "#3498DB",
  "GO_FIRST" = "#27AE60"
)

# ============================================================================
# 📊 LOAD AND PREPARE DATA
# ============================================================================
# Load dataset
data <- read.csv("../Clean_Dataset.csv", stringsAsFactors = FALSE)

# Data preprocessing
data <- data %>%
  select(-X) %>%  # Remove index column
  mutate(
    airline = factor(airline),
    source_city = factor(source_city),
    destination_city = factor(destination_city),
    departure_time = factor(departure_time, levels = c("Early_Morning", "Morning", "Afternoon", "Evening", "Night", "Late_Night")),
    arrival_time = factor(arrival_time, levels = c("Early_Morning", "Morning", "Afternoon", "Evening", "Night", "Late_Night")),
    stops = factor(stops, levels = c("zero", "one", "two_or_more")),
    class = factor(class, levels = c("Economy", "Business")),
    # Create route column
    route = paste(source_city, "→", destination_city),
    # Calculate value score (lower is better)
    # Normalized: price + duration penalty + stops penalty
    price_norm = (price - min(price)) / (max(price) - min(price)),
    duration_norm = (duration - min(duration)) / (max(duration) - min(duration)),
    stops_penalty = case_when(
      stops == "zero" ~ 0,
      stops == "one" ~ 0.3,
      TRUE ~ 0.6
    ),
    value_score = round((0.5 * price_norm + 0.3 * duration_norm + 0.2 * stops_penalty) * 100, 1)
  )

# ============================================================================
# 🖥️ UI DEFINITION
# ============================================================================
ui <- dashboardPage(
  skin = "blue",
  
  # Header
  dashboardHeader(
    title = span(icon("plane"), " Smart Flight Booking"),
    titleWidth = 280
  ),
  
  # Sidebar
  dashboardSidebar(
    width = 280,
    sidebarMenu(
      id = "tabs",
      
      # Logo/Brand
      div(style = "text-align: center; padding: 20px;",
          tags$img(src = "https://cdn-icons-png.flaticon.com/512/3125/3125713.png", 
                   height = "80px", style = "opacity: 0.9;"),
          h4("Flight Analytics", style = "color: #ecf0f1; margin-top: 10px;")
      ),
      
      hr(style = "border-color: #34495e;"),
      
      menuItem("📊 Overview", tabName = "overview", icon = icon("home")),
      menuItem("💰 Price Trends", tabName = "price_trends", icon = icon("chart-line")),
      menuItem("✈️ Airline Comparison", tabName = "airline", icon = icon("plane")),
      menuItem("🔄 Stops Analysis", tabName = "stops", icon = icon("exchange-alt")),
      menuItem("⏰ Time Optimization", tabName = "time", icon = icon("clock")),
      menuItem("🗺️ Route Analysis", tabName = "routes", icon = icon("route")),
      menuItem("⭐ Best Value Finder", tabName = "value", icon = icon("star")),
      
      hr(style = "border-color: #34495e;"),
      
      # Global Filters
      h4("🔍 Global Filters", style = "color: #ecf0f1; padding-left: 15px;"),
      
      pickerInput(
        inputId = "filter_source",
        label = "From City:",
        choices = unique(data$source_city),
        selected = unique(data$source_city),
        multiple = TRUE,
        options = list(`actions-box` = TRUE, `live-search` = TRUE)
      ),
      
      pickerInput(
        inputId = "filter_dest",
        label = "To City:",
        choices = unique(data$destination_city),
        selected = unique(data$destination_city),
        multiple = TRUE,
        options = list(`actions-box` = TRUE, `live-search` = TRUE)
      ),
      
      pickerInput(
        inputId = "filter_airline",
        label = "Airline:",
        choices = unique(data$airline),
        selected = unique(data$airline),
        multiple = TRUE,
        options = list(`actions-box` = TRUE)
      ),
      
      pickerInput(
        inputId = "filter_class",
        label = "Class:",
        choices = c("Economy", "Business"),
        selected = c("Economy", "Business"),
        multiple = TRUE
      )
    )
  ),
  
  # Body
  dashboardBody(
    # Custom CSS
    tags$head(
      tags$style(HTML("
        /* Main styling */
        .content-wrapper { background-color: #f8f9fa; }
        .main-header .logo { font-weight: bold; }
        
        /* Value boxes */
        .small-box { border-radius: 10px; }
        .small-box .icon { font-size: 70px; }
        
        /* Info boxes */
        .info-box { border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        
        /* Cards */
        .box { border-radius: 10px; box-shadow: 0 2px 15px rgba(0,0,0,0.08); }
        .box-header { border-radius: 10px 10px 0 0; }
        
        /* KPI cards */
        .kpi-card {
          background: linear-gradient(135deg, #1E3A5F 0%, #3498DB 100%);
          border-radius: 15px;
          padding: 20px;
          color: white;
          text-align: center;
          margin-bottom: 15px;
          box-shadow: 0 4px 15px rgba(0,0,0,0.2);
        }
        .kpi-value { font-size: 2.5em; font-weight: bold; }
        .kpi-label { font-size: 0.9em; opacity: 0.9; }
        
        /* Badge styles */
        .badge-best { background-color: #27AE60; }
        .badge-fast { background-color: #3498DB; }
        .badge-cheap { background-color: #F39C12; }
        
        /* Recommendation card */
        .recommendation-card {
          background: white;
          border-left: 5px solid #27AE60;
          padding: 15px;
          margin: 10px 0;
          border-radius: 5px;
          box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        /* Insight box */
        .insight-box {
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          color: white;
          padding: 15px;
          border-radius: 10px;
          margin: 10px 0;
        }
      "))
    ),
    
    tabItems(
      # ========================================
      # TAB 1: OVERVIEW
      # ========================================
      tabItem(tabName = "overview",
        fluidRow(
          # KPI Boxes
          valueBoxOutput("kpi_total_flights", width = 3),
          valueBoxOutput("kpi_avg_price", width = 3),
          valueBoxOutput("kpi_avg_duration", width = 3),
          valueBoxOutput("kpi_airlines", width = 3)
        ),
        
        fluidRow(
          box(
            title = span(icon("chart-pie"), " Price Distribution by Airline"),
            status = "primary", solidHeader = TRUE, width = 6,
            plotlyOutput("overview_price_airline", height = "350px")
          ),
          box(
            title = span(icon("clock"), " Flight Duration Distribution"),
            status = "primary", solidHeader = TRUE, width = 6,
            plotlyOutput("overview_duration", height = "350px")
          )
        ),
        
        fluidRow(
          box(
            title = span(icon("lightbulb"), " Key Insights"),
            status = "success", solidHeader = TRUE, width = 12,
            uiOutput("key_insights")
          )
        )
      ),
      
      # ========================================
      # TAB 2: PRICE TRENDS
      # ========================================
      tabItem(tabName = "price_trends",
        fluidRow(
          box(
            title = span(icon("chart-line"), " Price vs Days Before Departure"),
            status = "primary", solidHeader = TRUE, width = 8,
            plotlyOutput("price_vs_days", height = "400px")
          ),
          box(
            title = span(icon("info-circle"), " Booking Advice"),
            status = "success", solidHeader = TRUE, width = 4,
            uiOutput("booking_advice")
          )
        ),
        
        fluidRow(
          box(
            title = span(icon("th"), " Price Heatmap: Days Left × Departure Time"),
            status = "info", solidHeader = TRUE, width = 12,
            plotlyOutput("price_heatmap", height = "400px")
          )
        )
      ),
      
      # ========================================
      # TAB 3: AIRLINE COMPARISON
      # ========================================
      tabItem(tabName = "airline",
        fluidRow(
          box(
            title = span(icon("chart-bar"), " Average Price by Airline"),
            status = "primary", solidHeader = TRUE, width = 6,
            plotlyOutput("airline_price_bar", height = "350px")
          ),
          box(
            title = span(icon("chart-area"), " Price Distribution by Airline"),
            status = "primary", solidHeader = TRUE, width = 6,
            plotlyOutput("airline_price_box", height = "350px")
          )
        ),
        
        fluidRow(
          box(
            title = span(icon("chart-line"), " Duration vs Price by Airline"),
            status = "info", solidHeader = TRUE, width = 8,
            plotlyOutput("airline_scatter", height = "400px")
          ),
          box(
            title = span(icon("trophy"), " Airline Rankings"),
            status = "success", solidHeader = TRUE, width = 4,
            uiOutput("airline_rankings")
          )
        )
      ),
      
      # ========================================
      # TAB 4: STOPS ANALYSIS
      # ========================================
      tabItem(tabName = "stops",
        fluidRow(
          valueBoxOutput("kpi_direct_price", width = 4),
          valueBoxOutput("kpi_one_stop_price", width = 4),
          valueBoxOutput("kpi_multi_stop_price", width = 4)
        ),
        
        fluidRow(
          box(
            title = span(icon("chart-bar"), " Average Price by Number of Stops"),
            status = "primary", solidHeader = TRUE, width = 6,
            plotlyOutput("stops_price", height = "350px")
          ),
          box(
            title = span(icon("hourglass-half"), " Average Duration by Number of Stops"),
            status = "primary", solidHeader = TRUE, width = 6,
            plotlyOutput("stops_duration", height = "350px")
          )
        ),
        
        fluidRow(
          box(
            title = span(icon("balance-scale"), " Stops Trade-off Analysis"),
            status = "success", solidHeader = TRUE, width = 12,
            uiOutput("stops_insight")
          )
        )
      ),
      
      # ========================================
      # TAB 5: TIME OPTIMIZATION
      # ========================================
      tabItem(tabName = "time",
        fluidRow(
          box(
            title = span(icon("sun"), " Average Price by Departure Time"),
            status = "primary", solidHeader = TRUE, width = 6,
            plotlyOutput("time_price", height = "350px")
          ),
          box(
            title = span(icon("clock"), " Average Duration by Departure Time"),
            status = "primary", solidHeader = TRUE, width = 6,
            plotlyOutput("time_duration", height = "350px")
          )
        ),
        
        fluidRow(
          box(
            title = span(icon("th"), " Departure × Arrival Time Heatmap (Avg Price)"),
            status = "info", solidHeader = TRUE, width = 12,
            plotlyOutput("time_heatmap", height = "400px")
          )
        )
      ),
      
      # ========================================
      # TAB 6: ROUTE ANALYSIS
      # ========================================
      tabItem(tabName = "routes",
        fluidRow(
          column(4,
            selectInput("route_source", "From:", choices = unique(data$source_city), selected = "Delhi"),
            selectInput("route_dest", "To:", choices = unique(data$destination_city), selected = "Mumbai")
          ),
          column(8,
            uiOutput("route_kpis")
          )
        ),
        
        fluidRow(
          box(
            title = span(icon("list"), " Top Flights for This Route"),
            status = "primary", solidHeader = TRUE, width = 12,
            DTOutput("route_table")
          )
        ),
        
        fluidRow(
          box(
            title = span(icon("chart-bar"), " Route Price Analysis"),
            status = "info", solidHeader = TRUE, width = 6,
            plotlyOutput("route_price_chart", height = "300px")
          ),
          box(
            title = span(icon("lightbulb"), " Route Recommendations"),
            status = "success", solidHeader = TRUE, width = 6,
            uiOutput("route_recommendations")
          )
        )
      ),
      
      # ========================================
      # TAB 7: VALUE FINDER
      # ========================================
      tabItem(tabName = "value",
        fluidRow(
          box(
            title = span(icon("sliders-h"), " Customize Your Preferences"),
            status = "primary", solidHeader = TRUE, width = 4,
            sliderInput("weight_price", "Price Importance:", 0, 100, 50, post = "%"),
            sliderInput("weight_duration", "Duration Importance:", 0, 100, 30, post = "%"),
            sliderInput("weight_stops", "Direct Flight Preference:", 0, 100, 20, post = "%"),
            hr(),
            selectInput("value_source", "From:", choices = unique(data$source_city), selected = "Delhi"),
            selectInput("value_dest", "To:", choices = unique(data$destination_city), selected = "Mumbai"),
            selectInput("value_class", "Class:", choices = c("Economy", "Business"), selected = "Economy"),
            actionButton("find_value", "🔍 Find Best Flights", class = "btn-success btn-lg btn-block")
          ),
          box(
            title = span(icon("trophy"), " Top Recommended Flights"),
            status = "success", solidHeader = TRUE, width = 8,
            uiOutput("value_results")
          )
        ),
        
        fluidRow(
          box(
            title = span(icon("table"), " All Matching Flights Ranked"),
            status = "info", solidHeader = TRUE, width = 12,
            DTOutput("value_table")
          )
        )
      )
    )
  )
)

# ============================================================================
# 🖥️ SERVER LOGIC
# ============================================================================
server <- function(input, output, session) {
  
  # Reactive filtered data
  filtered_data <- reactive({
    data %>%
      filter(
        source_city %in% input$filter_source,
        destination_city %in% input$filter_dest,
        airline %in% input$filter_airline,
        class %in% input$filter_class
      )
  })
  
  # ========================================
  # OVERVIEW TAB
  # ========================================
  
  output$kpi_total_flights <- renderValueBox({
    valueBox(
      format(nrow(filtered_data()), big.mark = ","),
      "Total Flights",
      icon = icon("plane"),
      color = "blue"
    )
  })
  
  output$kpi_avg_price <- renderValueBox({
    valueBox(
      paste("₹", format(round(mean(filtered_data()$price)), big.mark = ",")),
      "Average Price",
      icon = icon("rupee-sign"),
      color = "green"
    )
  })
  
  output$kpi_avg_duration <- renderValueBox({
    valueBox(
      paste(round(mean(filtered_data()$duration), 1), "hrs"),
      "Average Duration",
      icon = icon("clock"),
      color = "yellow"
    )
  })
  
  output$kpi_airlines <- renderValueBox({
    valueBox(
      length(unique(filtered_data()$airline)),
      "Airlines",
      icon = icon("building"),
      color = "purple"
    )
  })
  
  output$overview_price_airline <- renderPlotly({
    df <- filtered_data() %>%
      group_by(airline) %>%
      summarise(avg_price = mean(price), .groups = "drop") %>%
      arrange(desc(avg_price))
    
    plot_ly(df, x = ~reorder(airline, avg_price), y = ~avg_price, type = "bar",
            marker = list(color = colors$gradient[2],
                          line = list(color = colors$primary, width = 1.5))) %>%
      layout(
        xaxis = list(title = "Airline"),
        yaxis = list(title = "Average Price (₹)"),
        hovermode = "x unified"
      )
  })
  
  output$overview_duration <- renderPlotly({
    plot_ly(filtered_data(), x = ~duration, type = "histogram",
            marker = list(color = colors$secondary, 
                          line = list(color = colors$primary, width = 1))) %>%
      layout(
        xaxis = list(title = "Duration (hours)"),
        yaxis = list(title = "Number of Flights")
      )
  })
  
  output$key_insights <- renderUI({
    df <- filtered_data()
    
    cheapest_airline <- df %>% group_by(airline) %>% 
      summarise(avg = mean(price)) %>% arrange(avg) %>% slice(1)
    
    fastest_airline <- df %>% group_by(airline) %>%
      summarise(avg = mean(duration)) %>% arrange(avg) %>% slice(1)
    
    best_time <- df %>% group_by(departure_time) %>%
      summarise(avg = mean(price)) %>% arrange(avg) %>% slice(1)
    
    tagList(
      div(class = "insight-box",
        h4(icon("lightbulb"), " Quick Insights"),
        tags$ul(
          tags$li(HTML(paste0("<strong>Cheapest Airline:</strong> ", cheapest_airline$airline, 
                              " (Avg ₹", format(round(cheapest_airline$avg), big.mark = ","), ")"))),
          tags$li(HTML(paste0("<strong>Fastest Airline:</strong> ", fastest_airline$airline,
                              " (Avg ", round(fastest_airline$avg, 1), " hours)"))),
          tags$li(HTML(paste0("<strong>Best Time to Fly:</strong> ", best_time$departure_time,
                              " departures are cheapest")))
        )
      )
    )
  })
  
  # ========================================
  # PRICE TRENDS TAB
  # ========================================
  
  output$price_vs_days <- renderPlotly({
    df <- filtered_data() %>%
      group_by(days_left) %>%
      summarise(
        avg_price = mean(price),
        min_price = min(price),
        max_price = max(price),
        .groups = "drop"
      )
    
    plot_ly(df) %>%
      add_trace(x = ~days_left, y = ~avg_price, type = "scatter", mode = "lines+markers",
                name = "Average Price",
                line = list(color = colors$primary, width = 3),
                marker = list(color = colors$primary, size = 8)) %>%
      add_ribbons(x = ~days_left, ymin = ~min_price, ymax = ~max_price,
                  name = "Price Range",
                  fillcolor = "rgba(52, 152, 219, 0.2)",
                  line = list(color = "transparent")) %>%
      layout(
        xaxis = list(title = "Days Before Departure", autorange = "reversed"),
        yaxis = list(title = "Price (₹)"),
        hovermode = "x unified",
        legend = list(orientation = "h", y = -0.2)
      )
  })
  
  output$booking_advice <- renderUI({
    df <- filtered_data() %>%
      group_by(days_left) %>%
      summarise(avg_price = mean(price), .groups = "drop")
    
    # Find best booking window
    best_window <- df %>% 
      filter(days_left >= 7, days_left <= 49) %>%
      arrange(avg_price) %>% 
      slice(1:5)
    
    optimal_days <- round(mean(best_window$days_left))
    
    tagList(
      div(class = "recommendation-card",
        h4(icon("calendar-check"), " Best Booking Window"),
        p(HTML(paste0("Book <strong>", optimal_days, " days</strong> before departure for best prices."))),
        hr(),
        h5("📌 Recommendations:"),
        tags$ul(
          tags$li("Last-minute bookings (< 3 days) are usually expensive"),
          tags$li("Prices stabilize 2-3 weeks before departure"),
          tags$li("Business class has less price variation")
        )
      )
    )
  })
  
  output$price_heatmap <- renderPlotly({
    df <- filtered_data() %>%
      mutate(days_bucket = cut(days_left, 
                               breaks = c(0, 3, 7, 14, 21, 30, 50),
                               labels = c("1-3", "4-7", "8-14", "15-21", "22-30", "31+"))) %>%
      group_by(days_bucket, departure_time) %>%
      summarise(avg_price = mean(price), .groups = "drop")
    
    df_wide <- df %>%
      pivot_wider(names_from = departure_time, values_from = avg_price)
    
    plot_ly(
      x = colnames(df_wide)[-1],
      y = df_wide$days_bucket,
      z = as.matrix(df_wide[,-1]),
      type = "heatmap",
      colorscale = list(c(0, colors$success), c(0.5, colors$warning), c(1, colors$accent)),
      hovertemplate = "Departure: %{x}<br>Days Left: %{y}<br>Avg Price: ₹%{z:,.0f}<extra></extra>"
    ) %>%
      layout(
        xaxis = list(title = "Departure Time"),
        yaxis = list(title = "Days Before Departure")
      )
  })
  
  # ========================================
  # AIRLINE COMPARISON TAB
  # ========================================
  
  output$airline_price_bar <- renderPlotly({
    df <- filtered_data() %>%
      group_by(airline) %>%
      summarise(avg_price = mean(price), .groups = "drop") %>%
      arrange(avg_price)
    
    plot_ly(df, y = ~reorder(airline, -avg_price), x = ~avg_price, type = "bar",
            orientation = "h",
            marker = list(color = ~avg_price, 
                          colorscale = list(c(0, colors$success), c(1, colors$accent)))) %>%
      layout(
        xaxis = list(title = "Average Price (₹)"),
        yaxis = list(title = ""),
        showlegend = FALSE
      )
  })
  
  output$airline_price_box <- renderPlotly({
    plot_ly(filtered_data(), y = ~price, x = ~airline, type = "box",
            color = ~airline, colors = airline_colors) %>%
      layout(
        xaxis = list(title = ""),
        yaxis = list(title = "Price (₹)"),
        showlegend = FALSE
      )
  })
  
  output$airline_scatter <- renderPlotly({
    df <- filtered_data() %>%
      group_by(airline) %>%
      summarise(
        avg_price = mean(price),
        avg_duration = mean(duration),
        count = n(),
        .groups = "drop"
      )
    
    plot_ly(df, x = ~avg_duration, y = ~avg_price, type = "scatter", mode = "markers+text",
            text = ~airline, textposition = "top center",
            marker = list(size = ~sqrt(count)/2, color = ~avg_price,
                          colorscale = list(c(0, colors$success), c(1, colors$accent)),
                          line = list(color = colors$dark, width = 2)),
            hovertemplate = paste(
              "<b>%{text}</b><br>",
              "Avg Price: ₹%{y:,.0f}<br>",
              "Avg Duration: %{x:.1f} hrs<br>",
              "<extra></extra>"
            )) %>%
      layout(
        xaxis = list(title = "Average Duration (hours)"),
        yaxis = list(title = "Average Price (₹)")
      )
  })
  
  output$airline_rankings <- renderUI({
    df <- filtered_data()
    
    # Rankings
    cheapest <- df %>% group_by(airline) %>% summarise(avg = mean(price)) %>% arrange(avg) %>% slice(1)
    fastest <- df %>% group_by(airline) %>% summarise(avg = mean(duration)) %>% arrange(avg) %>% slice(1)
    most_direct <- df %>% filter(stops == "zero") %>% count(airline) %>% arrange(desc(n)) %>% slice(1)
    
    tagList(
      div(class = "recommendation-card",
        h4(icon("medal"), " 🥇 Rankings"),
        tags$table(class = "table",
          tags$tr(
            tags$td(icon("dollar-sign", style = "color: #27AE60;")),
            tags$td(tags$strong("Cheapest")),
            tags$td(cheapest$airline)
          ),
          tags$tr(
            tags$td(icon("bolt", style = "color: #3498DB;")),
            tags$td(tags$strong("Fastest")),
            tags$td(fastest$airline)
          ),
          tags$tr(
            tags$td(icon("plane", style = "color: #9B59B6;")),
            tags$td(tags$strong("Most Direct")),
            tags$td(most_direct$airline)
          )
        )
      )
    )
  })
  
  # ========================================
  # STOPS ANALYSIS TAB
  # ========================================
  
  output$kpi_direct_price <- renderValueBox({
    avg <- filtered_data() %>% filter(stops == "zero") %>% summarise(avg = mean(price)) %>% pull(avg)
    valueBox(
      paste("₹", format(round(avg), big.mark = ",")),
      "Direct Flight (Avg)",
      icon = icon("plane"),
      color = "green"
    )
  })
  
  output$kpi_one_stop_price <- renderValueBox({
    avg <- filtered_data() %>% filter(stops == "one") %>% summarise(avg = mean(price)) %>% pull(avg)
    valueBox(
      paste("₹", format(round(avg), big.mark = ",")),
      "1 Stop (Avg)",
      icon = icon("exchange-alt"),
      color = "yellow"
    )
  })
  
  output$kpi_multi_stop_price <- renderValueBox({
    avg <- filtered_data() %>% filter(stops == "two_or_more") %>% summarise(avg = mean(price)) %>% pull(avg)
    valueBox(
      paste("₹", format(round(avg), big.mark = ",")),
      "2+ Stops (Avg)",
      icon = icon("random"),
      color = "red"
    )
  })
  
  output$stops_price <- renderPlotly({
    df <- filtered_data() %>%
      group_by(stops) %>%
      summarise(avg_price = mean(price), .groups = "drop")
    
    plot_ly(df, x = ~stops, y = ~avg_price, type = "bar",
            marker = list(color = c(colors$success, colors$warning, colors$accent))) %>%
      layout(
        xaxis = list(title = "Number of Stops", 
                     ticktext = c("Direct", "1 Stop", "2+ Stops"),
                     tickvals = c("zero", "one", "two_or_more")),
        yaxis = list(title = "Average Price (₹)")
      )
  })
  
  output$stops_duration <- renderPlotly({
    df <- filtered_data() %>%
      group_by(stops) %>%
      summarise(avg_duration = mean(duration), .groups = "drop")
    
    plot_ly(df, x = ~stops, y = ~avg_duration, type = "bar",
            marker = list(color = c(colors$success, colors$warning, colors$accent))) %>%
      layout(
        xaxis = list(title = "Number of Stops",
                     ticktext = c("Direct", "1 Stop", "2+ Stops"),
                     tickvals = c("zero", "one", "two_or_more")),
        yaxis = list(title = "Average Duration (hours)")
      )
  })
  
  output$stops_insight <- renderUI({
    df <- filtered_data()
    
    direct <- df %>% filter(stops == "zero") %>% 
      summarise(price = mean(price), duration = mean(duration))
    one_stop <- df %>% filter(stops == "one") %>%
      summarise(price = mean(price), duration = mean(duration))
    
    price_diff <- round((one_stop$price - direct$price) / direct$price * 100, 1)
    time_saved <- round(one_stop$duration - direct$duration, 1)
    
    tagList(
      div(class = "insight-box",
        h4(icon("balance-scale"), " Direct vs 1-Stop Trade-off"),
        fluidRow(
          column(6,
            h5("💰 Price Difference"),
            p(HTML(paste0("Direct flights cost <strong>", abs(price_diff), "%</strong> ",
                          ifelse(price_diff > 0, "less", "more"), " than 1-stop flights")))
          ),
          column(6,
            h5("⏱️ Time Saved"),
            p(HTML(paste0("Direct flights save <strong>", abs(time_saved), " hours</strong> on average")))
          )
        ),
        hr(),
        h5("📌 Recommendation:"),
        p(ifelse(price_diff < 15 && time_saved > 1,
                 "✅ Direct flights offer great value - slightly more expensive but much faster!",
                 "🤔 Consider 1-stop flights if you're on a tight budget and have flexible time."))
      )
    )
  })
  
  # ========================================
  # TIME OPTIMIZATION TAB
  # ========================================
  
  output$time_price <- renderPlotly({
    df <- filtered_data() %>%
      group_by(departure_time) %>%
      summarise(avg_price = mean(price), .groups = "drop")
    
    # Color based on price
    colors_time <- ifelse(df$avg_price == min(df$avg_price), colors$success,
                          ifelse(df$avg_price == max(df$avg_price), colors$accent, colors$secondary))
    
    plot_ly(df, x = ~departure_time, y = ~avg_price, type = "bar",
            marker = list(color = colors_time)) %>%
      layout(
        xaxis = list(title = "Departure Time"),
        yaxis = list(title = "Average Price (₹)")
      )
  })
  
  output$time_duration <- renderPlotly({
    df <- filtered_data() %>%
      group_by(departure_time) %>%
      summarise(avg_duration = mean(duration), .groups = "drop")
    
    plot_ly(df, x = ~departure_time, y = ~avg_duration, type = "bar",
            marker = list(color = colors$info)) %>%
      layout(
        xaxis = list(title = "Departure Time"),
        yaxis = list(title = "Average Duration (hours)")
      )
  })
  
  output$time_heatmap <- renderPlotly({
    df <- filtered_data() %>%
      group_by(departure_time, arrival_time) %>%
      summarise(avg_price = mean(price), .groups = "drop")
    
    df_wide <- df %>%
      pivot_wider(names_from = arrival_time, values_from = avg_price, values_fill = NA)
    
    plot_ly(
      x = colnames(df_wide)[-1],
      y = df_wide$departure_time,
      z = as.matrix(df_wide[,-1]),
      type = "heatmap",
      colorscale = list(c(0, colors$success), c(0.5, colors$warning), c(1, colors$accent)),
      hovertemplate = "Departure: %{y}<br>Arrival: %{x}<br>Avg Price: ₹%{z:,.0f}<extra></extra>"
    ) %>%
      layout(
        xaxis = list(title = "Arrival Time"),
        yaxis = list(title = "Departure Time")
      )
  })
  
  # ========================================
  # ROUTE ANALYSIS TAB
  # ========================================
  
  route_data <- reactive({
    filtered_data() %>%
      filter(source_city == input$route_source, destination_city == input$route_dest)
  })
  
  output$route_kpis <- renderUI({
    df <- route_data()
    
    if(nrow(df) == 0) {
      return(div(class = "alert alert-warning", "No flights found for this route with current filters."))
    }
    
    fluidRow(
      column(3,
        div(class = "kpi-card",
          div(class = "kpi-value", format(nrow(df), big.mark = ",")),
          div(class = "kpi-label", "Flights Available")
        )
      ),
      column(3,
        div(class = "kpi-card", style = "background: linear-gradient(135deg, #27AE60 0%, #2ECC71 100%);",
          div(class = "kpi-value", paste0("₹", format(min(df$price), big.mark = ","))),
          div(class = "kpi-label", "Lowest Price")
        )
      ),
      column(3,
        div(class = "kpi-card", style = "background: linear-gradient(135deg, #3498DB 0%, #5DADE2 100%);",
          div(class = "kpi-value", paste0(round(min(df$duration), 1), "h")),
          div(class = "kpi-label", "Fastest Flight")
        )
      ),
      column(3,
        div(class = "kpi-card", style = "background: linear-gradient(135deg, #9B59B6 0%, #BB8FCE 100%);",
          div(class = "kpi-value", paste0("₹", format(round(mean(df$price)), big.mark = ","))),
          div(class = "kpi-label", "Average Price")
        )
      )
    )
  })
  
  output$route_table <- renderDT({
    df <- route_data() %>%
      arrange(value_score) %>%
      select(airline, flight, departure_time, arrival_time, stops, class, duration, days_left, price, value_score) %>%
      head(20)
    
    datatable(df, 
              options = list(pageLength = 10, dom = 'ftp'),
              rownames = FALSE,
              colnames = c("Airline", "Flight", "Departure", "Arrival", "Stops", "Class", "Duration (h)", "Days Left", "Price (₹)", "Value Score")) %>%
      formatCurrency("price", currency = "₹", digits = 0) %>%
      formatStyle("value_score",
                  background = styleColorBar(c(0, 100), colors$success),
                  backgroundSize = "98% 88%",
                  backgroundRepeat = "no-repeat",
                  backgroundPosition = "center")
  })
  
  output$route_price_chart <- renderPlotly({
    df <- route_data() %>%
      group_by(airline) %>%
      summarise(avg_price = mean(price), .groups = "drop") %>%
      arrange(avg_price)
    
    plot_ly(df, x = ~reorder(airline, avg_price), y = ~avg_price, type = "bar",
            marker = list(color = colors$secondary)) %>%
      layout(
        xaxis = list(title = ""),
        yaxis = list(title = "Average Price (₹)")
      )
  })
  
  output$route_recommendations <- renderUI({
    df <- route_data()
    
    if(nrow(df) == 0) return(NULL)
    
    cheapest <- df %>% arrange(price) %>% slice(1)
    fastest <- df %>% arrange(duration) %>% slice(1)
    best_value <- df %>% arrange(value_score) %>% slice(1)
    
    tagList(
      div(class = "recommendation-card", style = "border-left-color: #F39C12;",
        h5(icon("dollar-sign"), " 💰 Cheapest Option"),
        p(HTML(paste0("<strong>", cheapest$airline, " ", cheapest$flight, "</strong><br>",
                      "₹", format(cheapest$price, big.mark = ","), " | ",
                      cheapest$duration, "h | ", cheapest$stops, " stops")))
      ),
      div(class = "recommendation-card", style = "border-left-color: #3498DB;",
        h5(icon("bolt"), " ⚡ Fastest Option"),
        p(HTML(paste0("<strong>", fastest$airline, " ", fastest$flight, "</strong><br>",
                      "₹", format(fastest$price, big.mark = ","), " | ",
                      fastest$duration, "h | ", fastest$stops, " stops")))
      ),
      div(class = "recommendation-card", style = "border-left-color: #27AE60;",
        h5(icon("star"), " ⭐ Best Value"),
        p(HTML(paste0("<strong>", best_value$airline, " ", best_value$flight, "</strong><br>",
                      "₹", format(best_value$price, big.mark = ","), " | ",
                      best_value$duration, "h | ", best_value$stops, " stops")))
      )
    )
  })
  
  # ========================================
  # VALUE FINDER TAB
  # ========================================
  
  value_flights <- eventReactive(input$find_value, {
    # Normalize weights
    total_weight <- input$weight_price + input$weight_duration + input$weight_stops
    w_price <- input$weight_price / total_weight
    w_duration <- input$weight_duration / total_weight
    w_stops <- input$weight_stops / total_weight
    
    df <- data %>%
      filter(
        source_city == input$value_source,
        destination_city == input$value_dest,
        class == input$value_class
      )
    
    if(nrow(df) == 0) return(NULL)
    
    # Recalculate value score with user weights
    df <- df %>%
      mutate(
        price_norm = (price - min(price)) / (max(price) - min(price) + 0.001),
        duration_norm = (duration - min(duration)) / (max(duration) - min(duration) + 0.001),
        stops_penalty = case_when(
          stops == "zero" ~ 0,
          stops == "one" ~ 0.5,
          TRUE ~ 1
        ),
        custom_score = round((w_price * price_norm + w_duration * duration_norm + w_stops * stops_penalty) * 100, 1)
      ) %>%
      arrange(custom_score)
    
    return(df)
  })
  
  output$value_results <- renderUI({
    df <- value_flights()
    
    if(is.null(df) || nrow(df) == 0) {
      return(div(class = "alert alert-info", 
                 icon("info-circle"), " Select your preferences and click 'Find Best Flights'"))
    }
    
    top3 <- df %>% head(3)
    
    tagList(
      h4(paste0("🛫 ", input$value_source, " → ", input$value_dest, " (", input$value_class, ")")),
      hr(),
      
      # Best Flight
      div(class = "recommendation-card", style = "border-left: 5px solid #27AE60; background: #f0fff4;",
        fluidRow(
          column(8,
            h4(icon("trophy", style = "color: gold;"), " #1 BEST VALUE"),
            h5(paste(top3$airline[1], top3$flight[1])),
            p(HTML(paste0(
              "<strong>Price:</strong> ₹", format(top3$price[1], big.mark = ","), " | ",
              "<strong>Duration:</strong> ", top3$duration[1], "h | ",
              "<strong>Stops:</strong> ", top3$stops[1], " | ",
              "<strong>Departure:</strong> ", top3$departure_time[1]
            )))
          ),
          column(4, style = "text-align: center;",
            div(style = "font-size: 2em; color: #27AE60; font-weight: bold;",
                paste0("Score: ", top3$custom_score[1])),
            span(class = "badge badge-best", style = "background: #27AE60; padding: 5px 10px;", "⭐ RECOMMENDED")
          )
        )
      ),
      
      if(nrow(top3) >= 2) {
        div(class = "recommendation-card", style = "border-left: 5px solid #3498DB;",
          h5(icon("medal"), " #2 ", top3$airline[2], " ", top3$flight[2]),
          p(paste0("₹", format(top3$price[2], big.mark = ","), " | ", top3$duration[2], "h | ", top3$stops[2], " stops | Score: ", top3$custom_score[2]))
        )
      },
      
      if(nrow(top3) >= 3) {
        div(class = "recommendation-card", style = "border-left: 5px solid #F39C12;",
          h5(icon("medal"), " #3 ", top3$airline[3], " ", top3$flight[3]),
          p(paste0("₹", format(top3$price[3], big.mark = ","), " | ", top3$duration[3], "h | ", top3$stops[3], " stops | Score: ", top3$custom_score[3]))
        )
      }
    )
  })
  
  output$value_table <- renderDT({
    df <- value_flights()
    
    if(is.null(df)) return(NULL)
    
    df %>%
      select(airline, flight, departure_time, arrival_time, stops, duration, days_left, price, custom_score) %>%
      datatable(
        options = list(pageLength = 15, dom = 'ftp'),
        rownames = FALSE,
        colnames = c("Airline", "Flight", "Departure", "Arrival", "Stops", "Duration (h)", "Days Left", "Price (₹)", "Value Score")
      ) %>%
      formatCurrency("price", currency = "₹", digits = 0) %>%
      formatStyle("custom_score",
                  background = styleColorBar(c(0, 100), "#27AE60"),
                  backgroundSize = "98% 88%",
                  backgroundRepeat = "no-repeat",
                  backgroundPosition = "center")
  })
}

# ============================================================================
# 🚀 RUN THE APP
# ============================================================================
shinyApp(ui = ui, server = server)
