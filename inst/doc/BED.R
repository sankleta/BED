## ----setup, echo=FALSE---------------------------------------------------
library(knitr)

## ---- message=FALSE------------------------------------------------------
library(BED)
connectToBed(
    url="http://localhost:5454",
    username="neo4j", password="1234"
)

## ---- message=TRUE-------------------------------------------------------
checkBedConn(verbose=TRUE)

## ------------------------------------------------------------------------
lsBedConnections()

## ---- eval=FALSE---------------------------------------------------------
#  showBedDataModel()

## ---- echo=FALSE---------------------------------------------------------
htmltools::includeHTML(system.file(
    "Documentation", "BED-Model", "BED.html",
    package="BED"
))

## ------------------------------------------------------------------------
results <- bedCall(
    cypher,
    query=prepCql(
       'MATCH (n:BEID)',
       'WHERE n.value IN $values',
       'RETURN DISTINCT n.value AS value, labels(n), n.database'
    ),
    parameters=list(values=c("10", "100"))
)
results

## ------------------------------------------------------------------------
listBe()

## ------------------------------------------------------------------------
firstCommonUpstreamBe(c("Object", "Transcript"))
firstCommonUpstreamBe(c("Peptide", "Transcript"))

## ------------------------------------------------------------------------
listOrganisms()

## ------------------------------------------------------------------------
getOrgNames(getTaxId("human"))

## ------------------------------------------------------------------------
listBeIdSources(be="Transcript", organism="human")

## ------------------------------------------------------------------------
largestBeSource(be="Transcript", organism="human", restricted=TRUE)

## ------------------------------------------------------------------------
head(listPlatforms())
getTargetedBe("GPL570")

## ------------------------------------------------------------------------
beids <- getBeIds(
    be="Gene", source="EntrezGene", organism="human",
    restricted=FALSE
)
dim(beids)
head(beids)

## ------------------------------------------------------------------------
sort(table(table(beids$Gene)), decreasing = TRUE)

## ------------------------------------------------------------------------
beids <- getBeIds(
    be="Gene", source="EntrezGene", organism="human",
    restricted = TRUE
)
dim(beids)

## ------------------------------------------------------------------------
sort(table(table(beids$Gene)), decreasing = TRUE)

## ------------------------------------------------------------------------
eid <- beids$id[which(beids$Gene==names(which(table(beids$Gene)>=8)))][1]
print(eid)
exploreBe(id=eid, source="EntrezGene", be="Gene") %>%
   visPhysics(solver="repulsion")

## ------------------------------------------------------------------------
mapt <- convBeIds(
   "MAPT", from="Gene", from.source="Symbol", from.org="human",
   to.source="Ens_gene", restricted=TRUE
)
exploreBe(
   mapt[1, "to"],
   source="Ens_gene",
   be="Gene"
)
getBeIds(
   be="Gene", source="Ens_gene", organism="human",
   restricted=TRUE,
   attributes=listDBAttributes("Ens_gene"),
   filter=mapt$to
)

## ------------------------------------------------------------------------
oriId <- c(
    "17237", "105886298", "76429", "80985", "230514", "66459",
    "93696", "72514", "20352", "13347", "100462961", "100043346",
    "12400", "106582", "19062", "245607", "79196", "16878", "320727",
    "230649", "66880", "66245", "103742", "320145", "140795"
)
idOrigin <- guessIdOrigin(oriId)
print(idOrigin$be)
print(idOrigin$source)
print(idOrigin$organism)

## ------------------------------------------------------------------------
print(attr(idOrigin, "details"))

## ------------------------------------------------------------------------
checkBeIds(ids=oriId, be="Gene", source="EntrezGene", organism="mouse")

## ------------------------------------------------------------------------
checkBeIds(ids=oriId, be="Gene", source="HGNC", organism="human")

## ------------------------------------------------------------------------
toShow <- getBeIdDescription(
    ids=oriId, be="Gene", source="EntrezGene", organism="mouse"
)
toShow$id <- paste0(
    sprintf(
        '<a href="%s" target="_blank">',
        getBeIdURL(toShow$id, "EntrezGene")
    ),
    toShow$id,
    '<a>'
)
kable(toShow, escape=FALSE, row.names=FALSE)

## ------------------------------------------------------------------------
res <- getBeIdSymbols(
    ids=oriId, be="Gene", source="EntrezGene", organism="mouse",
    restricted=FALSE
)
head(res)

## ------------------------------------------------------------------------
res <- getBeIdNames(
    ids=oriId, be="Gene", source="EntrezGene", organism="mouse",
    restricted=FALSE
)
head(res)

## ------------------------------------------------------------------------
someProbes <- c(
    "238834_at", "1569297_at", "213021_at", "225480_at",
    "216016_at", "35685_at", "217969_at", "211359_s_at"
)
toShow <- getGeneDescription(
    ids=someProbes, be="Probe", source="GPL570", organism="human"
)
kable(toShow, escape=FALSE, row.names=FALSE)

## ------------------------------------------------------------------------
getDirectProduct("ENSG00000145335", process="is_expressed_as")
getDirectProduct("ENST00000336904", process="is_translated_in")
getDirectOrigin("NM_001146055", process="is_expressed_as")

## ------------------------------------------------------------------------
res <- convBeIds(
    ids=oriId,
    from="Gene",
    from.source="EntrezGene",
    from.org="mouse",
    to.source="Ens_gene",
    restricted=TRUE,
    prefFilter=TRUE
)
head(res)

## ------------------------------------------------------------------------
res <- convBeIds(
    ids=oriId,
    from="Gene",
    from.source="EntrezGene",
    from.org="mouse",
    to="Peptide",
    to.source="Ens_translation",
    restricted=TRUE,
    prefFilter=TRUE
)
head(res)

## ------------------------------------------------------------------------
res <- convBeIds(
    ids=oriId,
    from="Gene",
    from.source="EntrezGene",
    from.org="mouse",
    to="Peptide",
    to.source="Ens_translation",
    to.org="human",
    restricted=TRUE,
    prefFilter=TRUE
)
head(res)

## ------------------------------------------------------------------------
humanEnsPeptides <- convBeIdLists(
    idList=list(a=oriId[1:5], b=oriId[-c(1:5)]),
    from="Gene",
    from.source="EntrezGene",
    from.org="mouse",
    to="Peptide",
    to.source="Ens_translation",
    to.org="human",
    restricted=TRUE,
    prefFilter=TRUE
)
unlist(lapply(humanEnsPeptides, length))
lapply(humanEnsPeptides, head)

## ------------------------------------------------------------------------
toConv <- data.frame(a=1:25, b=runif(25))
rownames(toConv) <- oriId
res <- convDfBeIds(
    df=toConv,
    from="Gene",
    from.source="EntrezGene",
    from.org="mouse",
    to.source="Ens_gene",
    restricted=TRUE,
    prefFilter=TRUE
)
head(res)

## ------------------------------------------------------------------------
from.id <- "ILMN_1220595"
res <- convBeIds(
   ids=from.id, from="Probe", from.source="GPL6885", from.org="mouse",
   to="Peptide", to.source="Uniprot", to.org="human",
   prefFilter=TRUE
)
res
exploreConvPath(
   from.id=from.id, from="Probe", from.source="GPL6885",
   to.id=res$to[1], to="Peptide", to.source="Uniprot"
)

## ------------------------------------------------------------------------
searched <- searchId("sv2A")
relIds <- getRelevantIds(
    d=searched,
    selected=1,
    be="Gene",
    source="Ens_gene",
    organism="human",
    restricted=TRUE
)

## ---- eval=FALSE---------------------------------------------------------
#  relIds <- findBe()

## ---- echo=FALSE---------------------------------------------------------
sessionInfo()

