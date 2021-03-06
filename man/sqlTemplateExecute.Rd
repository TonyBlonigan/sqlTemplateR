% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/query.R
\name{sqlTemplateExecute}
\alias{sqlTemplateExecute}
\title{Build and run a sqlTemplate file}
\usage{
sqlTemplateExecute(sqlTemplate, activate = NULL, tagMap = NULL,
  stringsAsFactors = TRUE, connectVar, debug = FALSE)
}
\arguments{
\item{sqlTemplate}{String: path to SQL Template File}

\item{activate}{String: Vector of column names that should be uncommented.
If using alias, include the alias: c('prod.CORP_DIV_CD','cust.ADDRESS')}

\item{tagMap}{List: Tags and the string they should be replaced with}

\item{stringsAsFactors}{Boolean. Will strings be converted to factors?}

\item{connectVar}{RODBC Connection. Name of the object holding your ODBC connection.}

\item{debug}{Boolean: Default False, weather to print query for debug}
}
\value{
Data frame of sql query results
}
\description{
Build and run a sqlTemplate file
}
