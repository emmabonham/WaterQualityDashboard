# Water Quality Dashboard

An interactive dashboard visualizing water quality data from USGS monitoring stations across Arizona.

## Overview

This project demonstrates spatial analysis and interactive visualization of environmental monitoring data. The dashboard displays:

- **Interactive map** of water quality monitoring stations
- **Time series trends** for multiple water quality parameters
- **Distribution analysis** using box plots
- **Summary statistics** table

## Data Source

Data is retrieved from the **USGS National Water Information System (NWIS)** using the `dataRetrieval` R package.

**Water Quality Parameters:**
- Temperature (°C)
- Dissolved Oxygen (mg/L)
- pH

**Geographic Coverage:** Arizona  
**Time Period:** January 2023 - Present

## Tools & Technologies

- **R** - Data processing and analysis
- **flexdashboard** - Dashboard framework
- **leaflet** - Interactive mapping
- **plotly** - Interactive charts
- **dataRetrieval** - USGS data API
- **dplyr & tidyr** - Data manipulation

## How to Run

### Prerequisites
Install required R packages:
```r
install.packages(c("flexdashboard", "leaflet", "plotly", "dplyr", 
                   "tidyr", "dataRetrieval", "DT", "lubridate"))
```

### Run the Dashboard

1. Clone this repository
2. Open `dashboard.Rmd` in RStudio
3. Click **"Knit"** or run:
```r
rmarkdown::render("dashboard.Rmd")
```

The dashboard will open in your browser.

## Project Structure
```
water-quality-dashboard/
├── dashboard.Rmd          # Main dashboard file
├── scripts/
│   └── fetch_data.R       # USGS data fetching functions
├── data/                  # Cached data (optional)
└── README.md              # This file
```

## Customization

You can modify the dashboard to:
- Change the state: Edit `state_cd = "AZ"` to any US state code
- Adjust date range: Modify `start_date` parameter
- Add more parameters: See [USGS parameter codes](https://help.waterdata.usgs.gov/codes-and-parameters/parameters)

## Future Enhancements

- Add date range selector
- Include additional water quality parameters (turbidity, conductance)
- Compare multiple states
- Add seasonal analysis
- Export functionality for filtered data

## Author

Emma Bonham  
Postdoctoral Research Associate, Arizona State University

## License

MIT License - Feel free to use and modify
