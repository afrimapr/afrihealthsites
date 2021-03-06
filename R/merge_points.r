#' merge healthsite points from different sources for a country
#'
#' IN DEVELOPMENT
#' aim is to identify and remove duplicates
#' first version just tests distance, between points in layer1 and 2
#' BUT problem maybe that there are points in each layer that are duplicates too
#' may want to move this to separate package later
#'
#' @param country a character vector of country names or iso3c character codes.
#' @param datasources vector of 2 datasources from 'healthsites' predownloaded, 'who', 'healthsites_live' needs API, 'hdx' not working yet
#' @param dist_same_m distance below which a site from source 1 and 2 is considered same
#' @param hs_amenity filter healthsites data by amenity. 'all', 'clinic', 'dentist', 'doctors', 'pharmacy', 'hospital'
#'                   to exclude dentist hs_amenity=c('clinic', 'doctors', 'pharmacy', 'hospital')
#' @param toreturn whether to return 'summary' or the merged 'sf' object

# @param plot option to display map 'mapview' for interactive, 'sf' for static
# @param plotshow whether to show the plot, otherwiser just return plot object
# @param plotcex sizes of symbols for each source default=c(6,3), helps view symbol overlap
# @param col.regions list of two colour palettes to pass to mapview
# @param plotlegend whether to add legend to mapview plot
# @param canvas mapview plotting option, TRUE by default for better performance with larger data
#'
#'
#' @examples
#'
#' #merge_points("nigeria", datasources=c('who', 'healthsites'), plot='mapview')
#' #merge_points(c('malawi','zambia'))
#'
#' @return \code{sf}
#' @export
#'
merge_points <- function(country,
                          datasources = c('healthsites','who'),
                          hs_amenity = c('clinic', 'doctors', 'pharmacy', 'hospital'), #exclude dentist 'all',
                          dist_same_m = 50,
                          toreturn = 'summary' ) {
                          #priority #could offer option to preferentially keep one or other source
                          #later work out what to do with attributes

                               # plot = 'mapview',
                               # plotshow = TRUE,
                               # plotcex = c(6,3),
                               # col.regions = list(RColorBrewer::brewer.pal(5, "YlGn"), RColorBrewer::brewer.pal(5, "BuPu")),
                               # plotlegend = TRUE,
                               # hs_amenity = 'all',
                               # canvas = TRUE) {

  sf1 <- afrihealthsites(country, datasource = datasources[1], plot=FALSE, hs_amenity=hs_amenity)
  sf2 <- afrihealthsites(country, datasource = datasources[2], plot=FALSE, hs_amenity=hs_amenity)

  #TODO put in some protection for if either sf1,2 doesn't exist, e.g. for N.Africa with no WHO
  #firstly if either is null just return other and no overlap to summary
  if (is.null(sf1) | is.null(sf2) )
  {

    if (is.null(sf1) & is.null(sf2) ) return(NULL)

    same_index1 <- NULL

    if ( is.null(sf1) )
      {
       numpoints1 <- 0
       numpoints2 <- nrow(sf2)
       sf3 <- sf2
      }
    else if ( is.null(sf2) )
    {
      numpoints2 <- 0
      numpoints1 <- nrow(sf1)
      sf3 <- sf1
    }
  }
  else
  {
    # for each point in sf1 what is the index of the closest point in sf2
    nrst_index1 <- st_nearest_feature(sf1, sf2)

    # distance from each point in sf1 to it's nearest neighbour in sf2
    distances1 <- st_distance(sf1$geometry, sf2$geometry[nrst_index1], by_element = TRUE)

    # set units for threshold to m
    units(dist_same_m) <- 'm'

    #find index of points in sf1 that are closer than the threshold to a point in sf2
    same_index1 <- which(distances1 < dist_same_m)

    #TODO improve this
    #FIRST ATTEMPT merge sf1 & sf2 missing out the sf1 points that are too close
    #LATER I will have to make the attribute columns the same
    #FOR FIRST ATTEMPT just keep a few select columns, e.g. the zcol and the namecol for each datasource
    #i think geometry columns will be kept automatically
    # if no overlap then keep all
    if (length(same_index1)==0) sf1new <- sf1[, c(nameof_labcol(datasources[1]), nameof_zcol(datasources[1]))]
    else                        sf1new <- sf1[-same_index1, c(nameof_labcol(datasources[1]), nameof_zcol(datasources[1]))]
    sf2new <- sf2[,c(nameof_labcol(datasources[2]), nameof_zcol(datasources[2]))]
    names(sf2new) <- names(sf1new)

    sf3 <- rbind(sf1new, sf2new)

    numpoints1 <- nrow(sf1)
    numpoints2 <- nrow(sf2)

    # BUT BURUNDI at 50m gives who:665 healthsites:1416 shared:680 merged:1401
    # so the % of max is > 100
    # probably due to internal overlaps in healthsites
    # i.e. at least 15 healthsites locations must be <50m from another healthsites location

    #see near_points()



  }



  # summarise results in a dataframe, maybe keep it tidy can summarise after
  # todo may want to save hs_amenity filter too
  dfsumm <- data.frame(country = country,
                       source1 = datasources[1],
                       numpoints1 = numpoints1,
                       source2 = datasources[2],
                       numpoints2 = numpoints2,
                       threshdistm = dist_same_m,
                       num_shared = length(same_index1),
                       num_merged = nrow(sf3) )


  cat(country,
      "num points:",
      datasources[1], ":", numpoints1,
      datasources[2], ":", numpoints2,
      " shared at dist thresh", dist_same_m, "m :", length(same_index1),
      " after merging:", nrow(sf3),
      "\n"
      )


  # for vis show lines linking point to its closest equivalent
  #link_lines <- st_sfc(mapply(function(a,b){st_cast(st_union(a,b),"LINESTRING")}, sf1$geometry, sf2$geometry[nrst_index1], SIMPLIFY=FALSE))

  #mapview(list(sf1,sf2,link_lines))
  #mapview(list(sf1,sf2,link_lines), col.regions=list('blue','red','green'), layer.name=list(datasources[1],datasources[2],'closest'))


  if ( toreturn == 'summary')
  {
    invisible(dfsumm)

  } else
  {
    invisible(sf3)
  }


  # for all countries - to run externally
  # dfallcountries <- NULL
  # for( country in afcountries$name)
  # {
  #   dfsumm <- merge_points(country, toreturn='summary', hs_amenity=c('clinic', 'doctors', 'pharmacy', 'hospital'))
  #   dfallcountries <- rbind(dfallcountries, dfsumm)
  # }


  # of course can't do the below because they have different numbers columns
  # TODO I could subset just the geometry and zcol columns (and maybe name) and then rbind to return
  #add source column, rbind and return in case it is useful
  # sf1$datasource <- datasources[1]
  # sf2$datasource <- datasources[2]
  #
  # sfboth <- rbind(sf1,sf2)
  # invisible(sfboth)
}
