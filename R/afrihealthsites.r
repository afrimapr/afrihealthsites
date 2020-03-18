#' Get healthsite points for a country
#'
#' returns healthsite locations for specified countries and optionally plots map
#'
#' @param country a character vector of country names or iso3c character codes.
#' @param datasource data source, 'healthsites' predownloaded, 'who', 'healthsites_live' needs API, 'hdx' not working yet
#' @param plot option to display map 'mapview' for interactive, 'sf' for static
#'
#'
#' @examples
#'
# sometimes get this error at CHECK and after but not when I browse to debug
# seems to occur both for mapview and sf options
# Error in st_geometry.sf(x) :
# attr(obj, "sf_column") does not point to a geometry column.
# Did you rename it, without setting st_geometry(obj) <- "newname"?
# so commented examples out for now
#'
#' #sfnga <- afrihealthsites("nigeria", plot='sf')
#'
#' #afrihealthsites('chad', datasource='who', plot='sf')
#' #afrihealthsites('chad', datasource='healthsites', plot='sf')
#'
#' #sfnga <- afrihealthsites("nigeria", plot='mapview')
#'
#' @return \code{sf}
#' @export
#'
afrihealthsites <- function(country,
                      datasource = 'healthsites', #'hdx', #'who',
                      plot = 'mapview') {


  #path <- system.file(package="afriadmin","/external")

  # check and convert country names to iso codes
  #iso3c <- country2iso(country)


  if (datasource == 'who')
  {

    filter_country <- tolower(sf_who_sites$Country) %in% tolower(country)
    #filter <- filter & filter_country

    nsites <- sum(filter_country)

    if (nsites==0)
    {
      warning("no sites in ",datasource, " for ", country)
      return()
    }

    #sfcountry <- sf_who_sites[ tolower(sf_who_sites$Country) == tolower(country),]
    sfcountry <- sf_who_sites[ filter_country, ]
  }

  #access pre-downloaded healthsites data stored in this package
  if (datasource == 'healthsites')

  {
    #beware different country names may be better to use iso3c
    filter_country <- tolower(sf_healthsites_af$country) %in% tolower(country)

    nsites <- sum(filter_country)

    if (nsites==0)
    {
      warning("no sites in ",datasource, " for ", country)
      return()
    }

    sfcountry <- sf_healthsites_af[filter_country,]

  }


  # access healthsites.io data by country from rhealthsites package
  # using healthsites_live requires API key to be set first
  if (datasource == 'healthsites_live')
  {

    check_rhealthsites()

    #rhealthsites::hs_set_api_key('[requires a free API key from https://healthsites.io/]')

    #previously this returned polygons for some facilities and points for others
    sfcountry <- rhealthsites::hs_facilities(country = country)

  }


  # access healthsites.io data by country stored monthly at hdx
  # not working yet, has advantage that no API key needed
  if (datasource == 'hdx')
  {
    #library(rhdx)
    rhdx::set_rhdx_config()


    querytext <- 'name:"kenya-healthsites"'
    #querytext <- 'name:"kenya-healthsites"'
    datasets_list <- rhdx::search_datasets(query = querytext)

    #query needs to return a single dataset (with multiple resources)
    ds <- datasets_list[[1]]

    #get list of resources
    list_of_rs <- rhdx::get_resources(ds)
    list_of_rs

    #selecting resource
    ds_id <- which( rhdx::get_formats(ds) %in% c("zipped shapefiles","zipped shapefile"))

    rs <- rhdx::get_resource(ds, ds_id)

    # find which layers in file (fails)
    #mlayers <- rhdx::get_resource_layers(rs, download_folder=getwd())

    #should read 1st layer by default
    #DOES download data but
    #FAILS TO READ LAYER DUE TO SUBFOLDER - shapefiles and that file called healthsites
    #Problem that the error crashes it out of this function

    sflayer <- rhdx::read_resource(rs, download_folder=getwd())

    #can temporarily sort that now
    utils::unzip("kenya-shapefiles.zip")

    sfcountry <- sf::read_sf(dsn = "shapefiles/healthsites.shp")

  }



  # display map if option chosen
  # helps with debugging, may not be permanent


  if (plot != FALSE) zcol <- switch(datasource,
         'healthsites' = 'amenity',
         'healthsites_live' = 'amenity',
         'hdx' = 'amenity',
         'who'= "Facility type",
          NULL)

  if (plot == 'mapview') print(mapview::mapview(sfcountry, zcol=zcol)) #, legend=FALSE))

  else if (plot == 'sf') plot(sf::st_geometry(sfcountry))

  invisible(sfcountry)
}
