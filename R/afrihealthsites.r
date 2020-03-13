#' Get healthsite points for a country
#'
#' returns healthsite locations for specified countries and optionally plots map
#'
#' @param country a character vector of country names or iso3c character codes.
#' @param datasource data source, initial default 'who'
#' @param plot option to display map 'mapview' for interactive, 'sf' for static
#'
#'
#' @examples
#'
#' sfnga <- afrihealthsites("nigeria")
#'
#' @return \code{sf}
#' @export
#'
afrihealthsites <- function(country,
                      datasource = 'who',
                      plot = 'mapview') {


  #path <- system.file(package="afriadmin","/external")

  # check and convert country names to iso codes
  #iso3c <- country2iso(country)


  if (datasource == 'who')
  {
    # todo check that this country is available for this datasource
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

  # display map if option chosen
  # helps with debugging, may not be permanent

  if (plot == 'mapview') print(mapview::mapview(sfcountry, zcol="Facility type", legend=FALSE))
  else if (plot == 'sf') plot(sf::st_geometry(sfcountry))

  invisible(sfcountry)
}
