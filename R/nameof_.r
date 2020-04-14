#' name of z column according to datasource
#'
#' @param datasource 'healthsites' predownloaded, 'who', 'healthsites_live' needs API, 'hdx' not working yet
#' @param type_column just for user provided files which column has information on type of site, default : 'Facility Type'
#' @examples
#'
#' nameof_zcol('who')
#'
#' @return character column name
#' @export
#'
nameof_zcol <- function(datasource, type_column) {
  zcol <- switch(datasource,
                 'healthsites' = 'amenity',
                 'healthsites_live' = 'amenity',
                 'hdx' = 'amenity',
                 'who'= "Facility type",
                 type_column ) #if not one of recognised datasets, use the optional user supplied option
  zcol
}


#' name of label column according to datasource
#'
#' @param datasource vector of 2 datasources from 'healthsites' predownloaded, 'who', 'healthsites_live' needs API, 'hdx' not working yet
#' @param label_column just for user provided files which column has information on name of site, default : 'Facility Name'
#'
#' @examples
#'
#' nameof_labcol('who')
#'
#' @return character column name
#' @export
#'
nameof_labcol <- function(datasource, label_column) {
  labcol <- switch(datasource,
                   'healthsites' = 'name',
                   'healthsites_live' = 'name',
                   'hdx' = 'name',
                   'who'= 'Facility name',
                   label_column ) #if not one of recognised datasets, use the optional user supplied option

  labcol
}
