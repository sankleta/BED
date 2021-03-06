% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/loadNcbiTax.R
\name{loadNcbiTax}
\alias{loadNcbiTax}
\title{Feeding BED: Load taxonomic information from NCBI}
\usage{
loadNcbiTax(reDumpThr, orgOfInt = c("human", "rat", "mouse"), curDate)
}
\arguments{
\item{reDumpThr}{time difference threshold between 2 downloads}

\item{orgOfInt}{organisms of interest: a character vector}

\item{curDate}{current date as given by \code{\link{Sys.Date}}}
}
\description{
Not exported to avoid unintended modifications of the DB.
}
