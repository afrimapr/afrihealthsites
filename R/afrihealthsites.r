#' Get healthsite points for a country
#'
#' returns healthsite locations for specified countries and optionally plots map
#'
#' @param country a character vector of country names or iso3c character codes.
#' @param datasource data source, 'healthsites' predownloaded, 'who', 'healthsites_live' needs API, 'hdx' not working yet
#' @param plot option to display map 'mapview' for interactive, 'sf' for static
#' @param hs_amenity filter healthsites data by amenity. 'all', 'clinic', 'dentist', 'doctors', 'pharmacy', 'hospital'
#'                   to exclude dentist hs_amenity=c('clinic', 'doctors', 'pharmacy', 'hospital')
#' @param returnclass 'sf' or 'dataframe', currently 'dataframe' only offered for WHO so that can have points with no coords
#' @param type_column just for user provided files which column has information on type of site, default : 'Facility Type'
#' @param label_column just for user provided files which column has information on name of site, default : 'Facility Name'
#'
#' @examples
#'
#' sfnga <- afrihealthsites("nigeria", datasource='who', plot='sf')
#'
#' afrihealthsites('chad', datasource='who', plot='sf')
#' afrihealthsites('chad', datasource='healthsites', plot='sf')
#'
#' sfnga <- afrihealthsites("nigeria", plot='mapview')
#'
#' #to return raw dataframe for WHO data including any rows with no coordinates
#' dfzaf <- afrihealthsites("south africa", datasource='who', plot=FALSE, returnclass='dataframe')
#' #note that ISO 3 letter codes and country names with upper case letters can also be used
#' #afrihealthsites("ZAF")
#' #afrihealthsites("South Africa")
#'
#' @return \code{sf}
#' @export
#'
afrihealthsites <- function(country,
                      datasource = 'healthsites', #'hdx', #'who',
                      plot = 'mapview',
                      hs_amenity = 'all',
                      returnclass = 'sf',
                      type_column = 'Facility Type',
                      label_column = 'Facility Name'
                      ) {


  #path <- system.file(package="afriadmin","/external")

  #check and convert country names to iso codes
  #copes better with any naming differences
  iso3c <- country2iso(country)


  if (datasource == 'who')
  {
    if (country=='all')
    {
      #it's not yet sf gets converted later if requested
      sfcountry <- df_who_sites

    } else
    {
      #filter_country <- tolower(df_who_sites$Country) %in% tolower(country)
      filter_country <- tolower(df_who_sites$iso3c) %in% tolower(iso3c)
      #filter <- filter & filter_country

      nsites <- sum(filter_country)

      if (nsites==0)
      {
        warning("no sites in ",datasource, " for ", country, " iso:", iso3c)
        #this creates an empty sf that may save plotting errors with things that use this e.g. mapview
        #return(sf::st_sf(st_sfc()))
        return()
      }

      #sfcountry <- df_who_sites[ tolower(df_who_sites$Country) == tolower(country),]
      sfcountry <- df_who_sites[ filter_country, ]
    }

   if (returnclass == 'sf')
   {
     # identify rows with no coords
     indices_na_coords <- which(is.na(sfcountry$Long) | is.na(sfcountry$Lat))
     #remove rows with no coords
     if (length(indices_na_coords) > 0) sfcountry <- sfcountry[-indices_na_coords,]
     #convert to sf
     sfcountry <- sf::st_as_sf(sfcountry, coords = c("Long", "Lat"), crs = 4326)
   }

  } else if (datasource == 'healthsites') #pre-downloaded healthsites data stored in this package
  {

    if (country=='all')
    {
      sfcountry <- sf_healthsites_af

    } else
    {
      #beware different country names may be better to use iso3c
      #filter_country <- tolower(sf_healthsites_af$country) %in% tolower(country)
      filter_country <- tolower(sf_healthsites_af$iso3c) %in% tolower(iso3c)

      nsites <- sum(filter_country)

      if (nsites==0)
      {
        warning("no sites in ",datasource, " for ", country, " iso:", iso3c)
        #this creates an empty sf that may save plotting errors with things that use this e.g. mapview
        #return(sf::st_sf(st_sfc()))
        return()
      }

      sfcountry <- sf_healthsites_af[filter_country,]

      # filter by amenity type
      if (!isTRUE(hs_amenity == 'all'))
      {
        filter_amenity <- tolower(sfcountry$amenity) %in% tolower(hs_amenity)
        sfcountry <- sfcountry[filter_amenity,]
      }
    }

  } else if (file.exists(datasource)) # a user supplied file
  {
    ######################################
    #TODO test whether it is sf compatible

    # most options are likely to be csvs
    #set check.names to FALSE to stop names being changed e.g. spaces to dots
    dfcountry <- utils::read.csv(datasource, as.is=TRUE, check.names = FALSE)

    #TODO allow names of coord columns to be set by user
    #ideally detect which they are likely to be

    #convert to sf
    sfcountry <- sf::st_as_sf(dfcountry, coords = c("Longitude", "Latitude"), crs = 4326)

    #other option if it is shp and 1 country already
    #sfcountry <- sf::st_read(datasource)



  } else if (datasource == 'healthsites_live')
  {
    # access healthsites.io data by country from rhealthsites package
    # using healthsites_live requires API key to be set first
    if (country=='all')
    {
      warning("no country='all' option for healthsites_live, choose countries\n")
      #this creates an empty sf that may save plotting errors with things that use this e.g. mapview
      #return(sf::st_sf(st_sfc()))
      return()
    }

    check_rhealthsites()

    #rhealthsites::hs_set_api_key('[requires a free API key from https://healthsites.io/]')

    #previously this returned polygons for some facilities and points for others
    sfcountry <- rhealthsites::hs_facilities(country = country, geometry_type='point')

  }


  # access healthsites.io data by country stored monthly at hdx
  # NOT WORKING YET, has advantage that no API key needed
  # but now that I save data in the package this not a priority
  if (datasource == 'hdx')
  {
    if (country=='all')
    {
      warning("no country='all' option for hdx, choose countries\n")
      #this creates an empty sf that may save plotting errors with things that use this e.g. mapview
      #return(sf::st_sf(st_sfc()))
      return()
    }

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

  # set the zcolumn that determines symbol colour on map and legend
  # for type of facility e.g. hospital, doctors

  if (plot != FALSE)
    {
     zcol <- nameof_zcol(datasource, type_column)
     labcol <- nameof_labcol(datasource, label_column)
    }



  if (plot != FALSE & returnclass != 'sf') warning('plots only possible when returnclass="sf" chosen\n')

  if (plot == 'mapview' & returnclass == 'sf')
    print(mapview::mapview(sfcountry, zcol=zcol, label=paste(sfcountry[[zcol]],sfcountry[[labcol]]))) #, legend=FALSE))

  else if (plot == 'sf' & returnclass == 'sf') plot(sf::st_geometry(sfcountry))

  invisible(sfcountry)
}
