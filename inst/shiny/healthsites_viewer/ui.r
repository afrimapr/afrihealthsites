#afrihealthsites/healthsites_viewer/ui.r
# keeping this very simple partly so it can be used as a template by other (maybe new) R users

cran_packages <- c("shiny","leaflet","remotes")

lapply(cran_packages, function(x) if(!require(x,character.only = TRUE)) install.packages(x))

library(shiny)
library(leaflet)
library(remotes)

if(!require(afrihealthsites)){
  remotes::install_github("afrimapr/afrihealthsites")
}

library(afrihealthsites)


# library(mapview)


pageWithSidebar(
  headerPanel('healthsites in Africa, from healthsites.io and WHO'),
  sidebarPanel( width=2,
    selectInput('country', 'Country', afcountries$name)
  ),
  mainPanel(
    leafletOutput("serve_healthsites_map", height=1000)
  )
)


# navbarPage("healthsites in Africa, from healthsites.io and WHO", id="main",
#            tabPanel("map", leafletOutput("serve_healthsites_map", height=1000)) )
#            #tabPanel("map", mapviewOutput("serve_healthsites_map", height=1000)) )
#            #tabPanel("Data", DT::dataTableOutput("data")),
#            #tabPanel("Read Me",includeMarkdown("readme.md")))
