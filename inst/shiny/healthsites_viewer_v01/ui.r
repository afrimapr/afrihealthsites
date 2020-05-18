#afrihealthsites/healthsites_viewer_v01/ui.r
# keeping this very simple partly so it can be used as a template by other (maybe new) R users
# v0.1 just showed a map, and only allowed selection of healthsites facility types

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
  headerPanel('afrimapr healthsites viewer v0.1'),
  sidebarPanel( width=3,

    p(tags$strong("view healthsite locations provided by",
                  a("healthsites.io", href="https://www.healthsites.io", target="_blank"),
                  " & ",
                  a("KEMRI Wellcome", href="https://www.nature.com/articles/s41597-019-0142-2", target="_blank"),
                  " / ",
                  a("WHO", href="https://www.who.int/malaria/areas/surveillance/public-sector-health-facilities-ss-africa/en/", target="_blank"))),

    #selectInput('country', 'Country', afcountries$name, size=10, selectize=FALSE, multiple=TRUE, selected="Angola"),
    #miss out Western Sahara because no healthsites or WHO
    selectInput('country', 'Country', choices = sort(afcountries$name[!afcountries$name=="Western Sahara"]),
                size=10, selectize=FALSE, multiple=TRUE, selected="Angola"),

    checkboxGroupInput("hs_amenity", label = h5("healthsites amenities"),
                       choices = list("hospital"="hospital", "clinic"="clinic", "doctors"="doctors", "pharmacy"="pharmacy", "unlabelled"="", "dentist" = "dentist"),
                       selected = c("hospital","clinic","doctors","pharmacy")),

    p("under development March 2020\n"),

    p("Developed by ", a("afrimapr", href="http://www.afrimapr.org", target="_blank"), "Contact : ", a("@southmapr", href="https://twitter.com/southmapr", target="_blank")),
    p("Open source ", a("R code", href="https://github.com/afrimapr/afrihealthsites", target="_blank")),

    #p("Compares data from :"),
    #p(a("healthsites.io", href="https://www.healthsites.io", target="_blank")),
    #p("\n", a("WHO", href="https://www.who.int/malaria/areas/surveillance/public-sector-health-facilities-ss-africa/en/", target="_blank")),

    p("\nWHO data Sub-Sahara only, symbols shown smaller, rings indicate overlap\n"),

    p("Input and suggestions ", a("welcome", href="https://github.com/afrimapr/suggestions_and_requests", target="_blank")),

    p(tags$small("Disclaimer : Data used by afrimapr are sourced from published open data sets. We provide no guarantee of accuracy.")),

  ),
  mainPanel(
    leafletOutput("serve_healthsites_map", height=1000)
  )
)


