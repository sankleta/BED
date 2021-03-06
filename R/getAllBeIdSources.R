#' List all the source databases of BE identifiers whatever the BE type
#'
#' @param recache boolean indicating if the CQL query should be run even if
#' the table is already in cache
#'
#' @return A data.frame indicating the BE related to the ID source (database).
#'
#' @seealso \code{\link{listBeIdSources}}, \code{\link{listPlatforms}}
#'
#' @export
#'
getAllBeIdSources <- function(recache=FALSE){
    cql <- prepCql(
        'MATCH (n:BEID) RETURN DISTINCT n.database as database, labels(n) as BE'
    )
    tn <- as.character(match.call()[[1]])
    toRet <- cacheBedCall(
        f=cypher,
        query=cql,
        tn=tn,
        recache=recache
    )
    toRet$BE <- sub(
        "ID$", "",
        sub(
            "BEID [|][|] ", "",
            sub(" [|][|] BEID", "", toRet$BE)
        )
    )
    return(toRet)
}
