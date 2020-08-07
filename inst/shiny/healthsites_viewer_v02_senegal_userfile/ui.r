#afrihealthsites/healthsites_viewer_v02_senegal_userfile/ui.r

# add ability for Senegal to show user supplied file for Senegal data collection (alongside existing kemri & healthsites data)

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

  # couldn't quite get internationalisation to work
  # # Initialize shi18ny
  # useShi18ny(),
  # # Language selector input
  # langSelectorInput("lang", position = "fixed"),


  #headerPanel('afrimapr Senegal healthsites data collection viewer'),
  headerPanel('Visionneuse de collecte de données des sites de santé au Sénégal'),
  #headerPanel(ui_('Senegal healthsites data collection viewer')),

  #p(ui_("View data being collected in a 2020 HOTOSM project and compare with existing data from healthsites.io and WHO.")),
  p("Consultez les données collectées dans un projet HOTOSM 2020 et comparez-les avec les données existantes de healthsites.io et de l'OMS."),

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

    p("by ", a("afrimapr", href="http://www.afrimapr.org", target="_blank"),
      ": creating R building-blocks to ease use of open health data in Africa"),


    #miss out Western Sahara because no healthsites or WHO
    selectInput('country', 'Country', choices = sort(afcountries$name[!afcountries$name=="Western Sahara"]),
                selectize=TRUE, multiple=TRUE, selected="Senegal"),

    #country <- "Senegal",

    checkboxGroupInput("hs_amenity", label = "healthsites categories",
                       choices = list("hospital"="hospital", "clinic"="clinic", "doctors"="doctors", "pharmacy"="pharmacy", "unlabelled"="", "dentist" = "dentist"),
                       selected = c("hospital","clinic","doctors","pharmacy")),

    #who cats whether to display raw or 9 broad
    selectInput("who_type_option", label = "WHO-KEMRI categories",
                choices = list("raw" = "Facility type", "reclassified to 9" = "facility_type_9"),
                selected = 1),

    # dynamic who category selection
    uiOutput("select_who_cat"),

    p("active development Aug 2020, v0.2 senegal_userfile\n"),

    #p("Contact : ", a("@southmapr", href="https://twitter.com/southmapr", target="_blank")),
    p("Open source ", a("R code", href="https://github.com/afrimapr/afrihealthsites", target="_blank")),


    p("\nWHO data Sub-Sahara only, symbols shown smaller, rings indicate overlap",
      a(",  blog post", href="https://afrimapr.github.io/afrimapr.website/blog/2020/healthsites-app/", target="_blank")),

    p("Input and suggestions ", a("welcome", href="https://github.com/afrimapr/suggestions_and_requests", target="_blank")),
    #  "Contact : ", a("@southmapr", href="https://twitter.com/southmapr", target="_blank")),

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
                tabPanel("WHO data", DT::dataTableOutput("table_raw_who")),
                tabPanel("new data", DT::dataTableOutput("table_raw_user"))
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
