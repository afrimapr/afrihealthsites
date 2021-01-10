#' availability of a national master facility list by country
#'
#' returns data availability dataframe for 'all' countries or 1 row for a single country
#' TODO add calculation of stats on numbers of countries satisfying criteria
#'
#' @param country 'all' (default) or a single country name or iso3c character code.
# @param
#'
#' @examples
#' national_list_avail('Togo')
#'
#' @return dataframe or single value
#' @export
#'
national_list_avail <- function(country = 'all'
                      ) {
  # country <- 'Togo'

  #read in csv file
  #later may want to auto read in the csv to an R object but will need to be careful
  #it gets auto-updated following any changes

  df <- utils::read.csv(system.file("extdata/afrihealthsites-country-facility-list-availability.csv", package="afrihealthsites"),
                 skip=1)

  if (country != 'all')
  {
    #check and convert country names to iso codes
    #copes better with any naming differences
    iso3c <- country2iso(country)

    # subset by specified countries
    # first go only works for single country
    df <- df[ which(iso3c == df$iso3c), ]
  }

  invisible(df)
}
