# afrihealthsites
access to geographic locations of african health sites from different sources

A [web interface](https://andysouth.shinyapps.io/healthsites_viewer/) demonstrating these components.

Part of the [afrimapr](https://afrimapr.github.io/afrimapr.website/) project.

In early development, will change, contact Andy South with questions.


### Install afrihealthsites

Install the development version from GitHub :

    # install.packages("remotes") # if not already installed
    
    remotes::install_github("afrimapr/afrihealthsites")
    
### Note

To specify country, it is possible to use the following:

- capitalisation (as you would write the country name in normal text e.g. "South Africa"
- all lower caps (e.g. "south africa")
- 3 letter country iso3c code (e.g. "zaf")

```
dfzaf <- afrihealthsites("south africa", datasource='who', plot=FALSE, returnclass='dataframe')
dfzaf <- afrihealthsites("ZAF", datasource='who', plot=FALSE, returnclass='dataframe')
dfzaf <- afrihealthsites("South Africa", datasource='who', plot=FALSE, returnclass='dataframe')

```

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

## compare healthsite locations from different sources

compare_hs_sources('togo')

# these are defaults
compare_hs_sources('togo', datasources=c('who', 'healthsites'), plot='mapview'))

# run a shiny application allowing you to select any country
runviewer()

# live data - requires a free API key from https://healthsites.io/
library(rhealthsites)
#rhealthsites::hs_set_api_key('[requires a free API key from https://healthsites.io/]')

# with interactive map
sfmali <- afrihealthsites("mali", datasource='healthsites_live', plot='mapview')



# todo move the readme to an Rmd to allow plots

```
