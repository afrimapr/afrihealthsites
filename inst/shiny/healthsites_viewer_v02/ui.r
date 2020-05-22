#afrihealthsites/healthsites_viewer2/ui.r
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


fluidPage(

  headerPanel('afrimapr healthsites viewer'),

  p("There are 2 main sources for locations of > 100k hospital and health facilities in Africa. Neither is perfect.
      This app allows detailed comparison to inform pandemic response and allow improvement."),

  sidebarLayout(

  sidebarPanel( width=3,

    #p(tags$strong("There are 2 main sources for locations of > 100k hospital and health facilities in Africa. Neither is perfect.
    #  This app allows detailed comparison to inform pandemic response and allow improvement.")),

    p("data from",
                  a("healthsites.io", href="https://www.healthsites.io", target="_blank"),
                  " & ",
                  a("KEMRI Wellcome", href="https://www.nature.com/articles/s41597-019-0142-2", target="_blank"),
                  " / ",
                  a("WHO", href="https://www.who.int/malaria/areas/surveillance/public-sector-health-facilities-ss-africa/en/", target="_blank")),

    p("By ", a("afrimapr", href="http://www.afrimapr.org", target="_blank"),
      " a project to create R building-blocks to ease use of health data in Africa"),


    #selectInput('country', 'Country', afcountries$name, size=10, selectize=FALSE, multiple=TRUE, selected="Angola"),
    #miss out Western Sahara because no healthsites or WHO
    selectInput('country', 'Country', choices = sort(afcountries$name[!afcountries$name=="Western Sahara"]),
                size=10, selectize=FALSE, multiple=TRUE, selected="Angola"),

    checkboxGroupInput("hs_amenity", label = "healthsites categories",
                       choices = list("hospital"="hospital", "clinic"="clinic", "doctors"="doctors", "pharmacy"="pharmacy", "unlabelled"="", "dentist" = "dentist"),
                       selected = c("hospital","clinic","doctors","pharmacy")),

    # dynamic who category selection
    uiOutput("select_who_cat"),

    p("active development May 2020, v0.2\n"),

    #p("Contact : ", a("@southmapr", href="https://twitter.com/southmapr", target="_blank")),
    p("Open source ", a("R code", href="https://github.com/afrimapr/afrihealthsites", target="_blank")),

    p("\nWHO data Sub-Sahara only, symbols shown smaller, rings indicate overlap\n"),

    p("Input and suggestions ", a("welcome", href="https://github.com/afrimapr/suggestions_and_requests", target="_blank"),
      "Contact : ", a("@southmapr", href="https://twitter.com/southmapr", target="_blank")),

    p(tags$small("Disclaimer : Data used by afrimapr are sourced from published open data sets. We provide no guarantee of accuracy.")),

  ),

  mainPanel(

    #when just had the map
    #leafletOutput("serve_healthsites_map", height=1000)

    #tabs
    tabsetPanel(type = "tabs",
                tabPanel("map", leafletOutput("serve_healthsites_map", height=800)),
                tabPanel("facility types", plotOutput("plot_fac_types", height=600)),
                tabPanel("healthsites data", DT::dataTableOutput("table_raw_hs")),
                tabPanel("WHO data", DT::dataTableOutput("table_raw_who"))
                #tabPanel("about", NULL)
    )
  )
)
)


# navbarPage("healthsites in Africa, from healthsites.io and WHO", id="main",
#            tabPanel("map", leafletOutput("serve_healthsites_map", height=1000)) )
#            #tabPanel("map", mapviewOutput("serve_healthsites_map", height=1000)) )
#            #tabPanel("Data", DT::dataTableOutput("data")),
#            #tabPanel("Read Me",includeMarkdown("readme.md")))
