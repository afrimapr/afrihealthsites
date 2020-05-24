#' afrihealthsites : healthsite locations for Africa
#'
#' locations from WHO and healthsites.io. Part of afrimapr project.
#'
#' @name afrihealthsites
#' @docType package
#' @seealso \code{\link{afrihealthsites}} \code{\link{compare_hs_sources}}
#' @import sf
NULL

# to avoid 'no visible binding' notes at R CMD CHECK
if (getRversion() >= "2.15.1") {
  utils::globalVariables(c("afcountries","df_who_sites","sf_healthsites_af","who_type_lookup"))
}
