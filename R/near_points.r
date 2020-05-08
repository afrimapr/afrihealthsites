#' find near points for a country initially in one datasource
#'
#' IN DEVELOPMENT
#' aim is to help identify and remove duplicates
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
#' #near_points("burundi", datasources=c('who', 'healthsites'), plot='mapview')
#'
#' @return \code{sf}
# @import nngeo
#' @export
#'
near_points <- function(country,
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


    # BUT BURUNDI at 50m gives who:665 healthsites:1416 shared:680 merged:1401
    # so the % of max is > 100
    # probably due to internal overlaps in healthsites
    # i.e. at least 15 healthsites locations must be <50m from another healthsites location

    # checking proximity of points within a single dataset
    #library(nngeo)

    # find neighbours within 50m to each point (max 10)
    # passing same object twice, it will always return index of same point, & others if there are any
    neighb_indices <- nngeo::st_nn(sf1,sf1, k=10, maxdist=50)


    # function which can be used with lapply to remove first element of each list
    remove_first <- function(x) { x <- x[c(-1)] }
    # remove first element of each list
    neighb_indices2 <- lapply(neighb_indices, remove_first)


    #lengths(nn) gives 1+ numbers of neighbours for each point (because the point is included)
    #num_neighbs <- lengths(neighb_indices) -1
    #just retaining points that have at least a neighbour
    #BEWARE for points that do have a neighbour their link to themselves is still left in
    #COULD do it better way by just removing first neighbour for all points
    #neighb_indices2 <- neighb_indices[which(num_neighbs > 0)]
    sf1_w_neighb <- sf1[which(num_neighbs > 0),]

    # create lines between neighbours for visualisation
    ll <- nngeo::st_connect(sf1, sf1, neighb_indices2)

    #ll <- nngeo::st_connect(sf1_w_neighb, sf1_w_neighb, neighb_indices2)

    #mapview::mapview(ll)

    #for healthsites TEMPORARY
    zcol1 <- 'amenity'
    labcol1 <- 'name'

    #want to be able to see points with names too
    mapplot <- mapview::mapview(sf1,
                                zcol=zcol1,
                                label=paste(sf1[[zcol1]],sf1[[labcol1]]),
                                #cex=plotcex[1],
                                #col.regions=col.regions[[1]],
                                layer.name=datasources[1])
                                #legend=plotlegend)

    mapplot <- mapplot + mapview::mapview(ll)




  # # summarise results in a dataframe, maybe keep it tidy can summarise after
  # # todo may want to save hs_amenity filter too
  # dfsumm <- data.frame(country = country,
  #                      source1 = datasources[1],
  #                      numpoints1 = numpoints1,
  #                      source2 = datasources[2],
  #                      numpoints2 = numpoints2,
  #                      threshdistm = dist_same_m,
  #                      num_shared = length(same_index1),
  #                      num_merged = nrow(sf3) )
  #
  #
  # cat(country,
  #     "num points:",
  #     datasources[1], ":", numpoints1,
  #     datasources[2], ":", numpoints2,
  #     " shared at dist thresh", dist_same_m, "m :", length(same_index1),
  #     " after merging:", nrow(sf3),
  #     "\n"
  # )
  #
  #
  # # for vis show lines linking point to its closest equivalent
  # #link_lines <- st_sfc(mapply(function(a,b){st_cast(st_union(a,b),"LINESTRING")}, sf1$geometry, sf2$geometry[nrst_index1], SIMPLIFY=FALSE))
  #
  # #mapview(list(sf1,sf2,link_lines))
  # #mapview(list(sf1,sf2,link_lines), col.regions=list('blue','red','green'), layer.name=list(datasources[1],datasources[2],'closest'))
  #
  #
  # if ( toreturn == 'summary')
  # {
  #   invisible(dfsumm)
  #
  # } else
  # {
  #   invisible(sf3)
  # }



}
