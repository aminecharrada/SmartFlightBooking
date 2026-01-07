# 🛫 Smart Flight Booking Dashboard

A professional R Shiny dashboard to help customers book the best flight by balancing **price**, **duration**, **comfort**, and **timing**.

![Dashboard Preview](https://img.shields.io/badge/R-Shiny-blue?style=for-the-badge&logo=r)![Status](https://img.shields.io/badge/Status-Ready-green?style=for-the-badge)

---

## 🎯 Business Problem Solved

> **Help customers make smarter flight booking decisions**

When booking a flight, customers typically ask:

-   ❓ *Which flight is the cheapest?*
-   ❓ *When should I book to pay less?*
-   ❓ *Is it better to take a direct flight or with stops?*
-   ❓ *Which airline gives the best value for money?*
-   ❓ *What is the best departure time?*

This dashboard **answers all these questions** with interactive visualizations and recommendations.

---

## 📊 Dashboard Features

### 1️⃣ Overview Dashboard

-   Total flights, average price, duration KPIs
-   Price distribution by airline
-   Key insights summary

### 2️⃣ Price Trends & Best Time to Book 💰

-   Line chart: Price vs Days before departure
-   Heatmap: Days left × Departure time
-   Smart booking window recommendations

### 3️⃣ Airline Comparison ✈️

-   Average price comparison by airline
-   Price distribution (boxplots)
-   Duration vs Price scatter plot
-   Airline rankings

### 4️⃣ Stops Analysis 🔄

-   Price comparison: Direct vs 1-stop vs 2+ stops
-   Duration comparison by stops
-   Trade-off analysis and recommendations

### 5️⃣ Time Optimization ⏰

-   Best departure time for cheapest flights
-   Departure × Arrival time heatmap
-   Duration analysis by time of day

### 6️⃣ Route Analysis 🗺️

-   Filter by source and destination city
-   Top flights for selected route
-   Route-specific recommendations

### 7️⃣ Value-for-Money Score ⭐

-   Customizable preference weights (price, duration, stops)
-   Smart ranking algorithm
-   Personalized flight recommendations

---

## 🎨 Color Palette

The dashboard uses a professional **airline-inspired** color palette:

Color

Hex Code

Usage

🔵 Deep Navy

`#1E3A5F`

Primary

🔵 Sky Blue

`#3498DB`

Secondary

🔴 Coral Red

`#E74C3C`

Accent/Alerts

🟢 Emerald

`#27AE60`

Success

🟡 Golden

`#F39C12`

Warning

🟣 Purple

`#9B59B6`

Info

---

## 🚀 Quick Start

### 1. Install Required Packages

```r
source("install_packages.R")
```

### 2. Run the Dashboard

```r
shiny::runApp("app.R")
```

Or in RStudio, open `app.R` and click **"Run App"**.

---

## 📦 Required Packages

-   `shiny` - Web application framework
-   `shinydashboard` - Dashboard layout
-   `shinydashboardPlus` - Enhanced dashboard components
-   `shinyWidgets` - Custom input widgets
-   `tidyverse` - Data manipulation
-   `plotly` - Interactive charts
-   `DT` - Interactive tables
-   `scales` - Number formatting
-   `viridis` - Color scales

---

## 📁 Project Structure

```
SmartFlightBooking/├── app.R                  # Main Shiny application├── install_packages.R     # Package installation script├── README.md              # This file└── ../Clean_Dataset.csv   # Flight data (parent directory)
```

---

## 📈 Dataset Description

The dashboard uses `Clean_Dataset.csv` containing:

Column

Description

`airline`

Airline name (SpiceJet, Vistara, etc.)

`flight`

Flight number

`source_city`

Departure city

`destination_city`

Arrival city

`departure_time`

Time of departure

`arrival_time`

Time of arrival

`stops`

Number of stops (zero, one, two_or_more)

`class`

Travel class (Economy, Business)

`duration`

Flight duration in hours

`days_left`

Days until departure

`price`

Ticket price in ₹

---

## 💡 Key Insights You'll Discover

1.  **Best Booking Window**: Optimal days before departure to get lowest prices
2.  **Airline Rankings**: Cheapest, fastest, and most value-for-money airlines
3.  **Stops Trade-off**: Is the direct flight premium worth it?
4.  **Best Travel Times**: Cheapest and most convenient departure times
5.  **Route Optimization**: Best options for specific city pairs

---

## 👨‍💻 Author

Created as a data analytics portfolio project demonstrating:

-   R Shiny development
-   Interactive data visualization
-   Business intelligence dashboards
-   Data-driven decision making

---

## 📝 License

This project is for educational and portfolio purposes.

---

*Built with ❤️ using R Shiny*