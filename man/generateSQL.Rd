% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/query.R
\name{generateSQL}
\alias{generateSQL}
\title{Generate query from an SQL template file}
\usage{
generateSQL(sqlTemplate, activate = NULL, tagMap = NULL)
}
\arguments{
\item{sqlTemplate}{String: path to SQL Template File}

\item{activate}{String: Vector of column names that should be uncommented.
If using alias, include the alias: c('prod.CORP_DIV_CD','cust.ADDRESS')}

\item{tagMap}{List: Tags and the string they should be replaced with}
}
\value{
string
}
\description{
Generate query from an SQL template file
}
\examples{
generateSQL(sqlTemplate = 'exampleQuery.sql', 'MARKET', "CORP_DIV_CD = 'DIV_A'")
}
\seealso{
\code{vignette(“sqlTemplateR”)}
}
