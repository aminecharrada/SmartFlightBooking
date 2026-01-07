# 🚀 Deployment Guide

## Option 1: Deploy Shiny Dashboard to shinyapps.io (FREE)

### Step 1: Install rsconnect
```r
install.packages("rsconnect")
```

### Step 2: Create Account
1. Go to https://www.shinyapps.io/
2. Sign up for a free account
3. Free tier includes: 5 applications, 25 active hours/month

### Step 3: Get Credentials
1. Log in to shinyapps.io
2. Go to **Account** → **Tokens**
3. Click **Show** and copy your token information

### Step 4: Configure Authentication
In R console or RStudio:
```r
rsconnect::setAccountInfo(
  name='YOUR_ACCOUNT_NAME',
  token='YOUR_TOKEN_HERE',
  secret='YOUR_SECRET_HERE'
)
```

### Step 5: Deploy
```r
# Make sure you're in the project directory
setwd("path/to/SmartFlightBooking")

# Deploy the app
rsconnect::deployApp(
  appName = "smart-flight-booking",
  forceUpdate = TRUE
)
```

Or use the deploy.R script:
```bash
Rscript deploy.R
```

### Your app will be live at:
```
https://YOUR_ACCOUNT_NAME.shinyapps.io/smart-flight-booking/
```

---

## Option 2: Deploy Presentation to GitHub Pages (FREE)

### Step 1: Enable GitHub Pages
1. Go to your GitHub repository
2. Settings → Pages
3. Source: Deploy from a branch
4. Branch: Select `gh-pages` → `/ (root)`
5. Click Save

### Step 2: Push the workflow
```bash
git add .github/workflows/publish.yml deploy.R DEPLOYMENT.md
git commit -m "Add deployment configuration"
git push
```

The workflow will automatically deploy your presentation!

### Your presentation will be live at:
```
https://aminecharrada.github.io/SmartFlightBooking/presentation.html
```

---

## Option 3: Docker Deployment (Advanced)

Create a Dockerfile:
```dockerfile
FROM rocker/shiny:latest

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-gnutls-dev \
    libssl-dev \
    libxml2-dev

# Install R packages
RUN R -e "install.packages(c('shiny', 'shinydashboard', 'shinydashboardPlus', 'shinyWidgets', 'tidyverse', 'plotly', 'DT', 'scales', 'viridis', 'patchwork'))"

# Copy app files
COPY . /srv/shiny-server/smart-flight-booking/

# Expose port
EXPOSE 3838

# Run app
CMD ["/usr/bin/shiny-server"]
```

Build and run:
```bash
docker build -t smart-flight-booking .
docker run -p 3838:3838 smart-flight-booking
```

Deploy to cloud platforms:
- **Heroku**: Use buildpack for R/Shiny
- **AWS**: ECS or Elastic Beanstalk
- **Google Cloud Run**: Container deployment
- **DigitalOcean**: App Platform

---

## Recommended: Start with shinyapps.io

**Pros:**
✅ Easiest deployment
✅ Free tier available
✅ No server management
✅ Automatic scaling
✅ SSL included

**Limitations:**
⚠️ 25 active hours/month (free tier)
⚠️ App sleeps after inactivity
⚠️ Limited memory/CPU

For production apps with more traffic, upgrade to paid tiers or use RStudio Connect/Shiny Server.
