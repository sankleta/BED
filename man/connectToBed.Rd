% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/zzz.R
\name{connectToBed}
\alias{connectToBed}
\title{Connect to a neo4j BED database}
\usage{
connectToBed(url = NULL, username = NULL, password = NULL,
  connection = 1, remember = TRUE)
}
\arguments{
\item{url}{a character string. The host and the port are sufficient
(e.g: "localhost:7474")}

\item{username}{a character string}

\item{password}{a character string}

\item{connection}{the id of the connection already registered to use. By
default the first registered connection is used.}

\item{remember}{if TRUE the connection is registered. All the registered
connections can be listed with \code{\link{lsBedConnections}} and any of
them can be forgotten with \code{\link{forgetBedConnection}}.}
}
\value{
This function does not return any value. It prepares the BED
environment to allow transparent DB calls.
}
\description{
Connect to a neo4j BED database
}
\details{
Be carefull that you should reconnect to BED database each time
the environment is reloaded.
}
\seealso{
\code{\link{checkBedConn}}, \code{\link{lsBedConnections}},
\code{\link{forgetBedConnection}}
}
