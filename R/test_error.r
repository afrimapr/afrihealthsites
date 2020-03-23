#' temporary attempt to create reproducible example for sf error 'does not point to geometry column'
#'
#'
#' @param plot option to display map 'mapview' for interactive, 'sf' for static
#'
#'
#' @examples
#'
# trying to recreate this error from afrihealthsites::afrihealthsites()
# sometimes get this error at CHECK and after but not when I browse to debug
# seems to occur both for mapview and sf options
# Error in st_geometry.sf(x) :
# attr(obj, "sf_column") does not point to a geometry column.
# Did you rename it, without setting st_geometry(obj) <- "newname"?
#'
#' tst1 <- test_error(plot='mapview')
#'
#'
#' @return \code{sf}
#' @export
#'
test_error <- function( plot = 'sf' ) {


  #narrowing down which code in afrihealthsites::afrihealthsites() causes error at check


  sf1 <- sf_healthsites_af

  # adding a new column
  #sf1$newcolumn1 <- 'test'

  filter_country <- tolower(sf_healthsites_af$iso3c) %in% "nga"

  ###LINE BELOW CAUSES THE ERROR AT EXAMPLES CHECK - without it the check passes
  sf1 <- sf1[filter_country,]


  # example dataset from sf doesn't give the error
  # sf1 <- sf::st_read(system.file("shape/nc.shp", package="sf"))
  # # adding a new column
  # sf1$newcolumn1 <- 'test'
  # filter <- sf1$NAME %in% "Ashe"
  # sf1 <- sf1[filter,]


  if (plot == 'mapview') print(mapview::mapview(sf1))
  else if (plot == 'sf')  plot(sf::st_geometry(sf1))

}
