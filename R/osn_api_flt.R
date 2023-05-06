#' Query Opensky-Network API for flight information
#'
#' @param .apt      ICAO location indicator of the airport
#' @param .type     either arrival or departure
#' @param .start    datetime for beginning of query slot
#' @param .end      ## not used ... currently start + 1 hr 
#' @param .osn_usr  Opensky-Network credentials
#' @param .osn_pw 
#'
#' @return tibble of flt information
#' @export
#'
#' @examples
osn_api_flt <- function(.apt, .type = c("arrival","departure"), .start, .end, .osn_usr=Sys.getenv("osn_usr"), .osn_pw=Sys.getenv("osn_pw")){
  url <- glue::glue("https://{.osn_usr}:{.osn_pw}@opensky-network.org/api/flights/{.type}?")
  begin_unix <- lubridate::ymd_hms(.start)  %>% as.numeric()
  end_unix   <- begin_unix + lubridate::hours(1) %>% as.numeric()
  
  # GET the flights arriving or departing, i.e. .type!
  api_call <- httr::GET(
    url   = url
    ,query = list(
      airport = .apt
      , begin = begin_unix
      ,   end = end_unix
    )
  )
  api_response = httr::content(api_call, as = "text", encoding = "UTF-8")
  flt <- tibble::tibble(fromJSON(api_response, flatten = TRUE))
}