# Deploy R Shiny App to shinyapps.io
# 
# Steps:
# 1. Install rsconnect package
# 2. Create account at https://www.shinyapps.io/
# 3. Get your token from Account > Tokens
# 4. Run this script

# Install rsconnect if not already installed
if (!require("rsconnect")) {
  install.packages("rsconnect")
}

library(rsconnect)

# Set account info (replace with your credentials from shinyapps.io)
# rsconnect::setAccountInfo(
#   name='YOUR_ACCOUNT_NAME',
#   token='YOUR_TOKEN',
#   secret='YOUR_SECRET'
# )

# Deploy the app
rsconnect::deployApp(
  appDir = ".",
  appName = "smart-flight-booking",
  forceUpdate = TRUE
)
