#' name of z column according to datasource
#'
#' @param datasource vector of 2 datasources from 'healthsites' predownloaded, 'who', 'healthsites_live' needs API, 'hdx' not working yet
#'
#' @examples
#'
#' nameof_zcol('who')
#'
#' @return character column name
#' @export
#'
nameof_zcol <- function(datasource) {
  zcol <- switch(datasource,
                 'healthsites' = 'amenity',
                 'healthsites_live' = 'amenity',
                 'hdx' = 'amenity',
                 'who'= "Facility type",
                 NULL)
  zcol
}


#' name of label column according to datasource
#'
#' @param datasource vector of 2 datasources from 'healthsites' predownloaded, 'who', 'healthsites_live' needs API, 'hdx' not working yet
#'
#' @examples
#'
#' nameof_labcol('who')
#'
#' @return character column name
#' @export
#'
nameof_labcol <- function(datasource) {
  labcol <- switch(datasource,
                   'healthsites' = 'name',
                   'healthsites_live' = 'name',
                   'hdx' = 'name',
                   'who'= "Facility name",
                   NULL)
  labcol
}
