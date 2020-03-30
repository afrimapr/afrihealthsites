#afrihealthsites/senegal_healthsites/ui.r
# keeping this very simple partly so it can be used as a template by other (maybe new) R users

# cran_packages <- c("shiny","leaflet","remotes")
# lapply(cran_packages, function(x) if(!require(x,character.only = TRUE)) install.packages(x))


library(shiny)
library(leaflet)
library(remotes)
library(afrihealthsites)
#library(mapview)


pageWithSidebar(
  headerPanel('senegal healthsites pilot viewer'),
  sidebarPanel( width=3,

    # checkboxGroupInput("hs_amenity", label = h5("healthsites amenities"),
    #                    choices = list("hospital"="hospital", "clinic"="clinic", "doctors"="doctors", "pharmacy"="pharmacy", "unlabelled"="", "dentist" = "dentist"),
    #                    selected = c("hospital","clinic","doctors","pharmacy")),

    radioButtons("attribute_to_plot", label = h3("Attribute to plot"),
                 choices = list("Number.of.Beds" = "Number.of.Beds",
                                "Number.of.Doctors" = "Number.of.Doctors",
                                "Number.of.Nurses"= "Number.of.Nurses"),
                 selected = "Number.of.Beds"),

    p("under development March 2020\n"),

    p("Developed by ", a("afrimapr", href="http://www.afrimapr.org", target="_blank"), "Contact : ", a("@southmapr", href="https://twitter.com/southmapr", target="_blank")),
    p("Open source ", a("R code", href="https://github.com/afrimapr/afrihealthsites", target="_blank")),

    p("Input and suggestions ", a("welcome", href="https://github.com/afrimapr/suggestions_and_requests", target="_blank")),

    p(tags$small("Disclaimer : Data used by afrimapr are sourced from published open data sets. We provide no guarantee of accuracy.")),

  ),
  mainPanel(
    leafletOutput("serve_healthsites_map", height=1000)
  )
)


