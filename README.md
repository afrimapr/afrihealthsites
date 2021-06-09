# afrihealthsites
access to geographic locations of african health facilities from different sources.

See [web interface](https://andysouth.shinyapps.io/healthsites_viewer/) and [paper](https://wellcomeopenresearch.org/articles/5-157) demonstrating these components.

Part of the [afrimapr](https://afrimapr.github.io/afrimapr.website/) project.

In early development, will change, contact Andy South with questions.


### Install afrihealthsites

Install the development version from GitHub :

    # install.packages("remotes") # if not already installed
    
    remotes::install_github("afrimapr/afrihealthsites")
    

### First Usage

``` r
library(afrihealthsites)
library(sf)

## WHO database 

# with interactive map
sfken <- afrihealthsites("kenya", datasource='who', plot='mapview')

# static map
sfeth <- afrihealthsites("ethiopia", datasource='who', plot='sf')

## healthsites.io

# pre-downloaded data

# with interactive map
sfmali <- afrihealthsites("mali", datasource='healthsites', plot='mapview')

## compare locations from different sources

compare_hs_sources('togo')

# these are defaults
compare_hs_sources('togo', datasources=c('who', 'healthsites'), plot='mapview')

# run a shiny application allowing you to select any country
runviewer()

# live data - requires a free API key from https://healthsites.io/
library(rhealthsites)
#rhealthsites::hs_set_api_key('[requires a free API key from https://healthsites.io/]')

# with interactive map
sfmali <- afrihealthsites("mali", datasource='healthsites_live', plot='mapview')

```

### Find National Master Facility Lists

``` r

# all countries list of available MFLs
df <- national_list_avail()

# availability for a single country
national_list_avail("Togo")

# url for data (if available)
national_list_url("Ghana")

# example of reading in data direct from a url and mapping
# will only work for countries where "machine_readable" is TRUE
dfgha <- read.csv(national_list_url("Ghana"))
sfgha <- sf::st_as_sf(dfgha, coords=c("Longitude","Latitude"), crs=4326, na.fail=FALSE)
afrihealthsites('gha',datasource=sfgha, type_column='Type')

``` 

### specifying countries

The following can be used :

- capitalisation (as you would write the country name in normal text e.g. "South Africa"
- all lower caps (e.g. "south africa")
- 3 letter country iso3c code (e.g. "zaf")

```
sfzaf1 <- afrihealthsites("south africa", datasource='who', plot=FALSE)
sfzaf2 <- afrihealthsites("ZAF", datasource='healthsites', plot='sf')
sfzaf3 <- afrihealthsites("South Africa", datasource='who', plot='mapview')

```

### Research notice

Please note that this repository is participating in a study into sustainability of open source projects. Data will be gathered about this repository for approximately the next 12 months, starting from June 2021.

Data collected will include number of contributors, number of PRs, time taken to close/merge these PRs, and issues closed.

For more information, please visit [the informational page](https://sustainable-open-science-and-software.github.io/) or download the [participant information sheet](https://sustainable-open-science-and-software.github.io/assets/PIS_sustainable_software.pdf).
