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
  sidebarPanel( width=3,
    selectInput('country', 'Country', afcountries$name, size=10, selectize=FALSE, multiple=TRUE, selected="Angola"),

    #p("This app was developed by", a(tags$strong("data-analysis OG"), href="http://www.data-analysis.at", target="_blank")),

    p("Developed by ", a("afrimapr", href="http://www.afrimapr.org", target="_blank")),
    p("Open source ", a("R code", href="https://github.com/afrimapr/afrihealthsites", target="_blank")),

    p("under development March 2020, some countries not yet working"),

    p("Compares data from :\n"),
    p(a("healthsites.io", href="https://www.healthsites.io", target="_blank")),
    p("\n", a("WHO", href="https://www.who.int/malaria/areas/surveillance/public-sector-health-facilities-ss-africa/en/", target="_blank")),

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
