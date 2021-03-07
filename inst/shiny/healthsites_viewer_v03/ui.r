#afrihealthsites/healthsites_viewer_v03/ui.r

# to add selection by admin region
# add 4 tiers from Falchetta2020
# add MoH MFL table as an extra tab

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

  p(a("Paper here. ", href="https://wellcomeopenresearch.org/articles/5-157", target="_blank"),
  "There are two main Africa-wide sources of open data on the locations of > 100k hospitals and health facilities.
   Neither is perfect.
   Some countries provide open Master Facility Lists, see 'National list availability' tab.
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

    p("by ", a("afrimapr", href="http://www.afrimapr.org", target="_blank"),
      ": creating R building-blocks to ease use of open health data in Africa"),


    #selectInput('country', 'Country', afcountries$name, size=10, selectize=FALSE, multiple=TRUE, selected="Angola"),
    #miss out Western Sahara because no healthsites or WHO
    selectInput('country', 'Country', choices = sort(afcountries$name[!afcountries$name=="Western Sahara"]),
                size=5, selectize=FALSE, multiple=TRUE, selected="Angola"),

    #to allow a reduced countries list for vaccine rollout planning
    #c('Democratic Republic of the Congo','Uganda','Liberia','Guinea','Sierra Leone')

    #selection by admin regions
    checkboxInput("cboxadmin", "Select facilities by admin1 region"),
    conditionalPanel(
      condition = "input.cboxadmin",

      #"admin regions selection to go here"

      #will want a selectInput box of potential admin levels by country

      #first try it for admin1
      uiOutput("select_admin")
    ),


    checkboxGroupInput("hs_amenity", label = "healthsites categories",
                       choices = list("hospital"="hospital", "clinic"="clinic", "doctors"="doctors", "pharmacy"="pharmacy", "unlabelled"="", "dentist" = "dentist"),
                       selected = c("hospital","clinic","doctors","pharmacy")),

    #who cats whether to display raw or 9 broad or 4 tiers
    selectInput("who_type_option", label = "WHO-KEMRI categories",
                choices = list("raw" = "Facility type",
                               "reclassified to 9" = "facility_type_9",
                               "4 Tiers (Falchetta 2020)" = "Tier_name"),
                selected = 1),

    # dynamic who category selection
    uiOutput("select_who_cat"),

    p("active development March 2021, v0.3\n"),

    #p("Contact : ", a("@southmapr", href="https://twitter.com/southmapr", target="_blank")),
    p("Open source ", a("R code", href="https://github.com/afrimapr/afrihealthsites", target="_blank")),


    p("\nWHO data Sub-Sahara only, symbols shown smaller, rings indicate overlap",
      a(",  blog post", href="https://afrimapr.github.io/afrimapr.website/blog/2020/healthsites-app/", target="_blank")),

    p("Input and suggestions ", a("welcome", href="https://github.com/afrimapr/suggestions_and_requests", target="_blank")),
    #  "Contact : ", a("@southmapr", href="https://twitter.com/southmapr", target="_blank")),
    p("admin boundary data from ", a("geoboundaries", href="https://www.geoboundaries.org/", target="_blank")),

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
                # table of availability of MoH MFL for all countries
                tabPanel("National list availability", DT::dataTableOutput("table_national_list_avail"))
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
