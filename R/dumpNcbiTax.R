#' Feeding BED: Dump tables with taxonomic information from NCBI
#'
#' Not exported to avoid unintended modifications of the DB.
#'
#' @param reDumpThr time difference threshold between 2 downloads
#' @param toDump the list of tables to load
#' @param env the R environment in which to load the tables when downloaded
#' @param curDate current date as given by \code{\link{Sys.Date}}
#'
#' @importFrom utils download.file read.table
#'
dumpNcbiTax <- function(
    reDumpThr,
    toDump=c("names.dmp"),
    env=parent.frame(n=1),
    curDate
){
    dumpDir <- "taxdump"
    if(file.exists(dumpDir)){
        load(file.path(dumpDir, "dumpDate.rda"))
        message("Last download: ", dumpDate)
        if(curDate - dumpDate > reDumpThr){
            toDownload <- TRUE
        }else{
            toDownload <- FALSE
        }
    }else{
        message("Not downloaded yet")
        toDownload <- TRUE
    }
    if(toDownload){
        if(file.exists(dumpDir)){
            dumpDirBck <- paste0(dumpDir,"-BCK")
            file.remove(list.files(path = dumpDirBck, full.names = T))
            file.remove(dumpDirBck)
            file.rename(dumpDir, dumpDirBck)
        }
        dir.create(dumpDir)
        download.file(
            "ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdump.tar.gz",
            file.path(dumpDir, "taxdump.tar.gz"),
            quiet=TRUE
        )
        system(
            sprintf('cd %s ; tar xzf taxdump.tar.gz ; cd -', dumpDir),
            ignore.stdout=TRUE
        )
        dumpDate <- curDate
        save(dumpDate, file=file.path(dumpDir, "dumpDate.rda"))
        message("Data have been downloaded")
    }else{
        message("Existing data are going to be used")
    }
    ## Data files
    for(td in toDump){
        lf <- file.path(dumpDir, td)
        df <- file.path(dumpDir, paste0(td, ".rda"))
        if(!file.exists(df)){
            assign(td, read.table(
                lf,
                sep="\t",
                header=F,
                stringsAsFactors=F,
                quote="",
                comment.char=""
            ))
            save(list=td, file= df)
        }
        load(df, envir=env)
    }
}
