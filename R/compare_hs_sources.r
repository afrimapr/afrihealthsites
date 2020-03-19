#' compare healthsite points from different sources for a country
#'
#' main aim to plot map comparing different sources
#'
#' @param country a character vector of country names or iso3c character codes.
#' @param datasources vector of 2 datasources from 'healthsites' predownloaded, 'who', 'healthsites_live' needs API, 'hdx' not working yet
#' @param plot option to display map 'mapview' for interactive, 'sf' for static
#' @param plotshow whether to show the plot, otherwiser just return plot object
#'
#'
#' @examples
#'
#' #compare_hs_sources("nigeria", datasources=c('who', 'healthsites'), plot='mapview')
#' #compare_hs_sources(c('malawi','zambia'))
#'
#' @return \code{sf}
#' @export
#'
compare_hs_sources <- function(country,
                            datasources = c('who', 'healthsites'), #'hdx',
                            plot = 'mapview',
                            plotshow = TRUE) {

  sf1 <- afrihealthsites(country, datasource = datasources[1], plot=FALSE)
  sf2 <- afrihealthsites(country, datasource = datasources[2], plot=FALSE)

  #TODO add a plot='sf' option


  if (plot == 'mapview')
  {
    set_zcol <- function(datasource) {
      zcol <- switch(datasource,
                      'healthsites' = 'amenity',
                      'healthsites_live' = 'amenity',
                      'hdx' = 'amenity',
                      'who'= "Facility type",
                      NULL)
      zcol
    }

    zcol1 <- set_zcol(datasources[1])
    zcol2 <- set_zcol(datasources[2])

    #library(RColorBrewer)

    mapplot <- mapview::mapview(list(sf1,sf2),
                           zcol=list(zcol1,zcol2),
                           cex=list(4,6),
                           #col.regions=list(RColorBrewer::brewer.pal(5, "Reds"), RColorBrewer::brewer.pal(5, "Blues")),
                           col.regions=list(RColorBrewer::brewer.pal(5, "YlGn"), RColorBrewer::brewer.pal(5, "BuPu")),
                           #fill=list(brewer.pal(9, "YlGn"),'blue'),
                           layer.name=list(datasources[1],datasources[2])) #, legend=FALSE))
  }


  if (plotshow) print(mapplot)

  invisible(mapplot)
  # of course can't do the below because they have different numbers columns
  # TODO I could subset just the geometry and zcol columns (and maybe name) and then rbind to return
  #add source column, rbind and return in case it is useful
  # sf1$datasource <- datasources[1]
  # sf2$datasource <- datasources[2]
  #
  # sfboth <- rbind(sf1,sf2)
  # invisible(sfboth)
}
