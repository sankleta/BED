#' Get a table of biological entity (BE) identifiers and symbols
#'
#' @param be one BE
#' @param source the BE ID database
#' @param organism organism name
#' @param restricted boolean indicating if the results should be restricted to
#' direct symbols
#' @param entity boolean indicating if the technical ID of BE should be
#' returned
#' @param verbose boolean indicating if the CQL query should be displayed
#' @param recache boolean indicating if the CQL query should be run even if
#' the table is already in cache
#' @param filter character vector on which to filter id. If NULL (default),
#' the result is not filtered: all IDs are taken into account.
#'
#' @return a data.frame with the
#' following fields:
#' \describe{
#'  \item{id}{the from BE ID}
#'  \item{symbol}{the BE symbol}
#'  \item{canonical}{true if the symbol is canonical for the direct BE ID}
#'  \item{direct}{false if the symbol is not directly associated to the BE ID}
#'  \item{entity}{(optional) the technical ID of to BE}
#' }
#'
#' @examples \dontrun{
#' getBeIdSymbolTable(
#'    be="Gene",
#'    source="EntrezGene",
#'    organism="human"
#' )
#' }
#'
#' @seealso \code{\link{getBeIdSymbols}},
#' \code{\link{getBeIdNameTable}}
#'
#' @importFrom neo2R prepCql cypher
#' @export
#'
getBeIdSymbolTable <- function(
    be,
    source,
    organism,
    restricted,
    entity=TRUE,
    verbose=FALSE,
    recache=FALSE,
    filter=NULL
){
    ## Organism
    taxId <- getTaxId(name=organism)
    if(length(taxId)==0){
        stop("organism not found")
    }
    if(length(taxId)>1){
        print(getOrgNames(taxId))
        stop("Multiple TaxIDs match organism")
    }

    ## Filter
    if(length(filter)>0 && !inherits(filter, "character")){
        stop("filter should be a character vector")
    }

    ## Other verifications
    echoices <- c(listBe())
    match.arg(be, echoices)
    match.arg(source, listBeIdSources(be, organism)$database)

    ## Entity symbol
    qs <- c(
        sprintf(
            paste0(
                'MATCH (id:%s {database:"%s"})',
                '-[:is_replaced_by|is_associated_to*0..]->()',
                '-[:identifies]->(be:%s)'
            ),
            paste0(be, "ID"), source, be
        ),
        'MATCH (bes:BESymbol)<-[c:is_known_as]-(sid)',
        '-[:is_associated_to*0..]->()-[:identifies]->(be)'
    )

    ## Organism
    oqs <- paste0(
        'MATCH (og)',
        '-[:belongs_to]->',
        sprintf(
            '(:TaxID {value:"%s"})',
            taxId
        )
    )
    if(be=="Gene"){
        oqs <- c(
            oqs,
            'MATCH (be)-[*0]-(og)'
        )
    }else{
        oqs <- c(
            oqs,
            paste0(
                'MATCH (be)',
                genBePath(from=be, to="Gene"),
                '(og)'
            )
        )
    }
    qs <- c(qs, oqs)

    ## Filter
    if(length(filter)>0){
        qs <- c(qs, 'WHERE id.value IN $filter')
    }

    ##
    cql <- c(
        qs,
        paste(
            'RETURN id.value as id, bes.value as symbol',
            ', c.canonical as canonical, id(id)=id(sid) as direct',
            ', sid.preferred as preferred',
            ', id(be) as entity'
        )
    )
    if(verbose){
        message(prepCql(cql))
    }
    ##
    if(length(filter)==0){
        tn <- gsub(
            "[^[:alnum:]]", "_",
            paste(
                match.call()[[1]],
                be, source,
                taxId,
                sep="_"
            )
        )
        toRet <- cacheBedCall(
            f=cypher,
            query=prepCql(cql),
            tn=tn,
            recache=recache
        )
    }else{
        toRet <- bedCall(
            f=cypher,
            query=prepCql(cql),
            parameters=list(filter=as.list(filter))
        )
    }
    toRet <- unique(toRet)
    ##
    if(!is.null(toRet)){
        toRet$canonical <- as.logical(toRet$canonical)
        toRet$direct <- as.logical(toRet$direct)
        toRet <- toRet[order(toRet$direct, decreasing=T),]
        toRet <- toRet[which(!duplicated(toRet[,c("id", "symbol")])),]
        ##
        if(!entity){
            toRet <- toRet[, setdiff(colnames(toRet), c("entity"))]
        }
        if(restricted){
            toRet <- toRet[which(toRet$direct),]
        }
    }
    ##
    return(toRet)
}
