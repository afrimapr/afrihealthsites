# afrihealthsites
access to geographic locations of african health sites from different sources


A part of the [afrimapr](www.afrimapr.org) project.

In early development, will change, contact Andy South with questions.


### Install afriadmin

Install the development version from GitHub using [devtools](https://github.com/hadley/devtools).

    # install.packages("devtools") # if not already installed
    
    devtools::install_github("afrimapr/afrihealthsites")


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
