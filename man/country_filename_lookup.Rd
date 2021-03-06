% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rainfall.R
\docType{data}
\name{country_filename_lookup}
\alias{country_filename_lookup}
\title{Country-Filename lookup table}
\format{A data frame with 288 rows and 2 variables
\describe{
  \item{file}{filename, character string of \href{https://crudata.uea.ac.uk/cru/data/hrg/cru_ts_3.24.01/crucy.1701201703.v3.24.01/countries/pre/}{files} }
  \item{iso3c}{ISO3 code}
  ...
}}
\source{
\url{https://crudata.uea.ac.uk/cru/data/hrg/cru_ts_3.24.01/crucy.1701201703.v3.24.01/countries/pre/} and the \code{countrycode} R package.
}
\usage{
country_filename_lookup
}
\description{
A dataset containing CRU country filenames and corresponding ISO3 codes.
The dataset is provided if users want to change ISO codes manually.
}
\keyword{datasets}

