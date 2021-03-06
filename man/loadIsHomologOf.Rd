% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/loadIsHomologOf.R
\name{loadIsHomologOf}
\alias{loadIsHomologOf}
\title{Feeding BED: Load homology between BE IDs}
\usage{
loadIsHomologOf(d, db1, db2, be = "Gene")
}
\arguments{
\item{d}{a data.frame with information about the homologies
to be loaded. It should contain the following fields: "id1" and "id2".}

\item{db1}{the DB of id1}

\item{db2}{the DB of id2}

\item{be}{a character corresponding to the BE type (default: "Gene")}
}
\description{
Not exported to avoid unintended modifications of the DB.
}
