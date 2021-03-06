#' Feeding BED: Load taxonomic information from NCBI
#'
#' Not exported to avoid unintended modifications of the DB.
#'
#' @param reDumpThr time difference threshold between 2 downloads
#' @param orgOfInt organisms of interest: a character vector
#' @param curDate current date as given by \code{\link{Sys.Date}}
#'
loadNcbiTax <- function(
   reDumpThr,
   orgOfInt=c("human", "rat", "mouse"),
   curDate
){
   names.dmp <- NULL
   dumpNcbiTax(reDumpThr=reDumpThr, toDump="names.dmp", curDate=curDate)
   taxNames <- names.dmp[,-seq(2, 8, by=2)]
   colnames(taxNames) <- c(
      "tax_id", "name_txt", "unique_name", "name_class"
   )

   ###############################
   toLoad <- unique(taxNames$tax_id[which(taxNames$name_txt %in% orgOfInt)])
   toLoad <- taxNames[which(taxNames$tax_id %in% toLoad),]
   loadOrganisms(toLoad)
}
