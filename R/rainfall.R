# Build filename of rainfall country file ---------------------------------

build_country_string <- function(iso3c = NULL) {
  if(is.null(iso3c)) {
    stop("Please provide country names")
  }
  filenames <- country_filename_lookup[country_filename_lookup$iso3c %in% iso3c, "file"]

  return(filenames)
}


# Downloader Function -----------------------------------------------------

#' Download monthly rainfall data for countries
#'
#' \code{download_rain()} downloads monthly rainfall data from the
#' Climate Research Unit at the University of East Anglia (\url{http://www.cru.uea.ac.uk/}).
#'
#'
#' @param country Character vector of ISO3 codes for the countries for which
#' rainfall data is to be downloaded. I suggest using the excellent
#' \code{\href{https://cran.r-project.org/web/packages/countrycode/index.html}{countrycode}}
#' package to retrieve ISO3 codes from country names.
#' @param long Logical. If TRUE, the resulting data frame is a tidy output in which
#' every observation is a country-year month of rainfall data. If FALSE every row is a
#' year with the JAN to DEC monthly values as columns.
#' @param delete_raw Logical. Delete local copies of the downloaded CRU files?
#' Defaults to TRUE.
#'
#' @return If long == TRUE \code{download_rain()} returns a data frame / tibble with the following
#' variables:
#' \itemize{
#' \item \code{iso3c}: ISO3 code of a country
#' \item \code{YEAR}: Year (currently 1901 - 2015)
#' \item \code{month}: Month (character string of month, JAN - DEC)
#' \item \code{month_numeric}: Month (numeric, 1-12)
#' \item \code{rain}: Monthly mean of rainfall in milimeters per month (https://crudata.uea.ac.uk/cru/data/hrg/#info)
#' \item \code{MAM, JJA, SON, DJF}: seasonal sum
#' \item \code{ANN}: Annual sum of mean rainfall per month
#' }
#'
#'
#'
#' @examples
#'
#' \dontrun{
#' # Download rainfall data for the Democratic Republic of the Congo.
#' rain_drc <- download_rain(country = "COD", long = T, delete_raw = T)
#'
#' }
#'
#'@references
#'
#'Harris, I, PD Jones, TJ Osborn & DH Lister (2014)
#'Updated high-resolution grids of monthly climatic observations - the
#'CRU TS3.10 Dataset. \emph{International Journal of Climatology} 34(3): 623-642.
#'
#' @export
download_rain <- function(country = NULL, long = T, delete_raw = T) {
  filenames <- build_country_string(iso3c = country)

  # build url
  base_url = "https://crudata.uea.ac.uk/cru/data/hrg/cru_ts_3.24.01/crucy.1701201703.v3.24.01/countries/pre/"

  # download all files
  for(file in filenames) {
    url = paste0(base_url, file)
    download.file(url = url, destfile = file, method = "auto")
  }

  # initiate empty data.frame
  rain_data <- data.frame(iso3c = NULL,
                          YEAR = NULL,
                          JAN = NULL,
                          FEB = NULL,
                          MAR = NULL,
                          APR = NULL,
                          MAY = NULL,
                          JUN = NULL,
                          JUL = NULL,
                          AUG = NULL,
                          SEP = NULL,
                          OCT = NULL,
                          DEC = NULL,
                          MAM = NULL,
                          JJA = NULL,
                          SON = NULL,
                          DJF = NULL,
                          ANN = NULL)
  # remove first row
  rain_data <- rain_data[-1, ]

  # read and combine country rainfall files
  for(file in filenames) {
    country_rain_data <- read.table(file, sep = "", skip = 3, header = T)
    country_rain_data$iso3c <- country_filename_lookup[country_filename_lookup$file %in% file, "iso3c"]

    rain_data <- dplyr::bind_rows(rain_data, country_rain_data)

  }

  # remove files if keep_raw = T
  if(delete_raw == T){
    file.remove(filenames)
  }

  # clean missing data
  rain_data[rain_data == -999] <- NA

  if(long == F) {
    return(rain_data)
  } else {

    # long format
    rain_data <- rain_data %>%
      tidyr::gather(key = month, value = rain,
                    -YEAR, -DJF, -JJA, -SON, -MAM, -ANN, -iso3c) %>%
      group_by(month) %>%
      dplyr::mutate(month_numeric = grep(unique(month),
                                  toupper(month.abb))) %>%
      ungroup() %>%
      dplyr::select(iso3c, YEAR, month, month_numeric, rain, everything()) %>%
      arrange(iso3c, YEAR, month_numeric)

    return(rain_data)
  }

}


# Data description of country file lookup table ---------------------------

#' Country-Filename lookup table
#'
#' A dataset containing CRU country filenames and corresponding ISO3 codes.
#' The dataset is provided if users want to change ISO codes manually.
#'
#' @format A data frame with 288 rows and 2 variables
#' \describe{
#'   \item{file}{filename, character string of \href{https://crudata.uea.ac.uk/cru/data/hrg/cru_ts_3.24.01/crucy.1701201703.v3.24.01/countries/pre/}{files} }
#'   \item{iso3c}{ISO3 code}
#'   ...
#' }
#'
#'
#' @source \url{https://crudata.uea.ac.uk/cru/data/hrg/cru_ts_3.24.01/crucy.1701201703.v3.24.01/countries/pre/} and the \code{countrycode} R package.
"country_filename_lookup"
