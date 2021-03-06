#' Feeding BED: Load history of BEIDs
#'
#' Not exported to avoid unintended modifications of the DB.
#'
#' @param d a data.frame with information about the history.
#' It should contain the following fields: "old" and "new".
#' @param be a character corresponding to the BE type (default: "Gene")
#' @param dbname the DB of BEID
#'
loadHistory <- function(d, dbname, be="Gene"){

    beid <- paste0(be, "ID", sep="")

    ##
    dColNames <- c("old", "new")
    if(any(!dColNames %in% colnames(d))){
        stop(paste(
            "The following columns are missing:",
            paste(setdiff(dColNames, colnames(d)), collapse=", ")
        ))
    }

    ################################################
    cql <- c(
        sprintf(
            paste(
                'MERGE',
                '(old:BEID:%s',
                '{value: row.old, database:"%s"}',
                ')'
            ),
            beid, dbname
        ),
        sprintf(
            paste(
                'MERGE',
                '(new:BEID:%s',
                '{value: row.new, database:"%s"})'
            ),
            beid, dbname
        ),
        "CREATE UNIQUE (old)-[:is_replaced_by]->(new)"
    )
    bedImport(cql, d)

}
