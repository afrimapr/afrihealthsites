#' takes a vector of facility types and classes them into 4 tiers following Falchetta type definition
#'
#' to reclass facility types into a 4 tier classification, any types not passed will be classed as 0
#'
#' @param types facility types, one per health facility as a vector
#' @param tier1 types to be classed as tier1
#' @param tier2 types to be classed as tier2
#' @param tier3 types to be classed as tier3
#' @param tier4 types to be classed as tier4
#' @param to_return "Tier" or "Tier_name" potentially others later
#' @param nametier0 name for tier0 i.e. when it isn't classed into other tiers
#' @param nametier1 name for tier1
#' @param nametier2 name for tier2
#' @param nametier3 name for tier3
#' @param nametier4 name for tier4
#'
#' @examples
#'
#' tiers4(c("a","b","c"), tier1=c("a","b"), tier2="c", to_return="Tier_name")
#'
#' @return vector of numeric values or strings representing tiers
#' @export
#'
tiers4 <- function(types,
                   tier1 = NULL,
                   tier2 = NULL,
                   tier3 = NULL,
                   tier4 = NULL,
                   nametier0="Tier0 unknown",
                   nametier1="Tier1 health post",
                   nametier2="Tier2 health centre",
                   nametier3="Tier3 provincial hospital",
                   nametier4="Tier4 central hospital",
                   to_return = "Tier") {


  tiers <- ifelse(types %in% tier1, 1,
             ifelse(types %in% tier2, 2,
               ifelse(types %in% tier3, 3,
                 ifelse(types %in% tier4, 4,
                  0))))

  if ( to_return == "Tier_name" )
  {
    tiers <- ifelse(tiers==1, nametier1,
               ifelse(tiers==2, nametier2,
                  ifelse(tiers==3,nametier3,
                     ifelse(tiers==4,nametier4, nametier0))))
  }

  #TODO this just returns a vector, do I want it to return a named column ?

  tiers

}
