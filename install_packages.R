# ============================================================================
# 📦 INSTALL REQUIRED PACKAGES FOR SMART FLIGHT BOOKING DASHBOARD
# ============================================================================
# Run this script once to install all required packages

packages <- c(
  "shiny",
  "shinydashboard", 
  "shinydashboardPlus",
  "shinyWidgets",
  "tidyverse",
  "plotly",
  "DT",
  "scales",
  "viridis"
)

# Install packages that are not already installed
new_packages <- packages[!(packages %in% installed.packages()[,"Package"])]

if(length(new_packages) > 0) {
  cat("Installing packages:", paste(new_packages, collapse = ", "), "\n")
  install.packages(new_packages, dependencies = TRUE)
} else {
  cat("All packages are already installed!\n")
}

# Load all packages to verify installation
cat("\nVerifying package installation...\n")
for(pkg in packages) {
  if(require(pkg, character.only = TRUE, quietly = TRUE)) {
    cat("✓", pkg, "loaded successfully\n")
  } else {
    cat("✗", pkg, "failed to load\n")
  }
}

cat("\n============================================\n")
cat("Setup complete! Run the dashboard with:\n")
cat("  shiny::runApp('app.R')\n")
cat("============================================\n")
