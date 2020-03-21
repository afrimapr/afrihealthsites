#' conversion from country names to iso3c code
#'
#' #todo vectorise
#'
#' @param country a character vector of country names
#'
#'
#' @examples
#'
#' iso3c <- country2iso("nigeria")
#'
#' @return character vector of iso3c codes
#' @export
#'
country2iso <- function(country) {

  if (nchar(country) > 3)
  {
    iso3c <- countrycode::countrycode(country, origin='country.name', destination='iso3c')
  } else
  {
    #to allow iso3c argument in lower case
    iso3c <- toupper(country)
  }

  iso3c
}


#' conversion from iso3c code to country names
#'
#' #todo vectorise
#'
#' @param iso3c a character vector of country codes
#'
#'
#' @examples
#'
#' name <- iso2country("nga")
#'
#' @return character vector of country names
#' @export
#'
iso2country <- function(iso3c) {

  if (nchar(iso3c) == 3)
  {
    #name <- countrycode::countrycode(iso3c, origin='iso3c', destination='country.name')

    name <- afcountries$name[which(afcountries$iso3c==toupper(iso3c))]

  } else
  {
    stop("iso3c needs to be 3 chars, not ",iso3c)
  }

  name
}


