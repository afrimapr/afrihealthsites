#' availability of a national master facility list by country
#'
#' initially return whole row for countries
#' later add a function partic to access 'url_data'
#'
#' @param country a character vector of country names or iso3c character codes.
# @param
#'
# @examples
#'
#'
#' @return dataframe or single value
#' @export
#'
national_list_avail <- function(country
                      ) {
  # country <- 'Togo'

  #check and convert country names to iso codes
  #copes better with any naming differences
  iso3c <- country2iso(country)

  #read in csv file
  #later may want to auto read in the csv to an R object but will need to be careful
  #it gets auto-updated following any changes

  df <- read.csv(system.file("extdata/afrihealthsites-country-facility-list-availability.csv", package="afrihealthsites"),
                 skip=1)

  # subset by specified countries
  # first go only works for single country
  df[ which(iso3c == df$iso3c),  ]

}
