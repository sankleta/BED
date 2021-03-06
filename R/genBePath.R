#' Construct CQL sub-query to map 2 biological entity
#'
#' Internal use
#'
#' @param from one biological entity (BE)
#' @param to one biological entity (BE)
#'
#' @return A character value corresponding to the sub-query
#'
#' @seealso \code{\link{genProbePath}}, \code{\link{listBe}}
#'
#' @importFrom neo2R prepCql cypher
#'
genBePath <- function(from, to){
    if(from==to){
        stop('from and to should be different.')
    }
    cqRes <- bedCall(
        cypher,
        query=prepCql(c(
            sprintf(
                'MATCH (f:BEType {value:"%s"})',
                from
            ),
            sprintf(
                'MATCH (t:BEType {value:"%s"})',
                to
            ),
            'MATCH p=shortestPath((f)-[:produces*1..]-(t))',
            'RETURN p'
        )),
        result="graph"
    )
    if(length(cqRes$relationships)==0){
        stop("Cannot find any paths between from and to.")
    }
    n <- cqRes$nodes
    ntable <- do.call(
        rbind,
        lapply(
            n,
            function(x){
                data.frame(
                    id=x$id,
                    value=x$properties$value,
                    stringsAsFactors=FALSE
                )
            }
        )
    )
    r <- cqRes$relationships
    rtable <- do.call(
        rbind,
        lapply(
            r,
            function(x){
                data.frame(
                    id=x$id,
                    start=x$startNode,
                    end=x$endNode,
                    how=x$properties$how,
                    stringsAsFactors=FALSE
                )
            }
        )
    )

    ##################################
    genCypher <- function(fid, usedR){
        curR <- rtable[which(
            (rtable$start==fid | rtable$end==fid) & !rtable$id %in% usedR
        ),]
        if(nrow(curR)>1){
            stop("Several possible paths")
        }
        if(nrow(curR)==0){
            return("")
        }
        if(fid==curR$"start"){
            toRet <- paste0('-[:', curR$how, ']->')
            nid <- curR$end
        }else{
            toRet <- paste0('<-[:', curR$how, ']-')
            nid <- curR$start
        }
        toApp <- genCypher(nid, c(usedR, curR$id))
        if(toApp!=""){
            toRet <- paste0(
                toRet,
                "(:",  ntable$value[which(ntable$id==nid)],")",
                toApp
            )
        }
        return(toRet)
    }
    ##################################

    return(genCypher(
        fid=ntable$id[which(ntable$value==from)],
        usedR=c()
    ))

}
