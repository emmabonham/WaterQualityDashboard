# fetch_data.R
# Script to fetch water quality data from USGS National Water Information System

library(dataRetrieval)
library(dplyr)
library(lubridate)

# Function to fetch water quality data from USGS
fetch_usgs_wq_data <- function(state_cd = "AZ", 
                               start_date = "2023-01-01",
                               end_date = Sys.Date(),
                               parameter_codes = c("00010", "00300", "00400")) {
  
  # Parameter codes:
  # 00010 = Temperature, water, degrees Celsius
  # 00300 = Dissolved oxygen, mg/L
  # 00400 = pH
  # 00095 = Specific conductance, µS/cm at 25°C
  
  # Get sites in state
  sites <- whatNWISsites(stateCd = state_cd,
                         parameterCd = parameter_codes,
                         siteType = "ST")  # Stream sites
  
  if(nrow(sites) == 0) {
    stop("No sites found for the given criteria")
  }
  
  # Limit to first 20 sites for demo (remove this for full dataset)
  sites <- sites[1:min(20, nrow(sites)), ]
  
  # Fetch water quality data
  wq_data <- readNWISqw(siteNumbers = sites$site_no,
                        parameterCd = parameter_codes,
                        startDate = start_date,
                        endDate = end_date)
  
  # Add site info
  wq_data <- left_join(wq_data, 
                       sites %>% select(site_no, station_nm, 
                                       dec_lat_va, dec_long_va),
                       by = "site_no")
  
  return(list(data = wq_data, sites = sites))
}

# Example usage (uncomment to test):
# az_data <- fetch_usgs_wq_data(state_cd = "AZ", 
#                               start_date = "2023-01-01")
# View(az_data$data)
# View(az_data$sites)
