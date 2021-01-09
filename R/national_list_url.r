#' data url for national master facility lists by country
#'
#' returns urls for 'all' available countries or url for a single country
#'
#' @param country 'all' (default) or a single country name or iso3c character code.
# @param
#'
#' @examples
#' national_list_url('South Sudan')
#'
#' #example of reading in data direct from a url and mapping
#' #will only work for countries where "machine_readable" is TRUE
#' #dfgha <- read.csv(national_list_url("Ghana"))
#' #sfgha <- sf::st_as_sf(dfgha, coords=c("Longitude","Latitude"), crs=4326, na.fail=FALSE)
#' #mapview::mapview(sfgha, zcol='Type')
#' #TODO fix why this fails
#' #compare_hs_sources("ghana",datasources=c("who",sfgha))
#' #in compare_hs_sources country=ghana admin_level= admin_names=
#' #Error in afrihealthsites(country, datasource = datasources[[2]], plot = FALSE,  :
#' #                            object 'sfcountry' not found
#'
#' #to return a dataframe with all countries that have urls
#' national_list_url()
#'
#' @return dataframe or single value
#' @export
#'
national_list_url <- function(country = 'all'
) {

  df1 <- national_list_avail(country=country)

  url_data <- df1$url_data

  names(url_data) <- df1$country

  if (country != 'all')
  {
    if (url_data=="")
      warning("no recorded url for the facility list for", country," if you are ware of one let us know")
    else if ( !isTRUE(df1$machine_readable) )
      warning("url returned but the data are not machine readable")
    else
      message("returning url, machine readable, file format:", df1$format)
  } else
  {
    message("returning all recorded urls for national facility lists, if you are aware of others let us know")

    #returning most useful columns
    #users can use national_list_avail() if they want more
    cols_to_return <- c("country","iso3c","url_data","downloadable","machine_readable","format","geocoded","mfl_satisfies","exclusion_reasons")


    df2 <- df1[which(df1$url_data!=""), cols_to_return]

    # #convert to dataframe probably more useful
    # #named character vector was difficult to view
    # df2 <- data.frame( country=names(url_data),
    #                    url_data=url_data
    #                  )
    url_data <- df2

  }

  url_data
}
