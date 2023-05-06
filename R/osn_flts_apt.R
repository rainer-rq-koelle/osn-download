#' getOSNflightsByAirport
#' 
#' taken from: https://github.com/longwei66/flightR/blob/master/R/get-osn-flights-by-airports.R
#' 
#' A function to get all arrival or departure flights in a specific airport in a given time
#' interval - call to Opensky Network API
#' 
#' Retrieve flights for a certain airport which arrived or departured within a given time 
#' interval (begin, end). If no flights are found for the given period, 
#' HTTP stats 404 - Not found is returned with an empty response body.

#'
#' @param icao.code ICAO code of the airport 
#' @param type either arrival or departure
#' @param from.time Start of time interval to retrieve flights as "YYYY-MM-DD HH:MM:SS"
#' @param to.time End of time interval to retrieve flights as "YYYY-MM-DD HH:MM:SS"
#' @param login osn valid login
#' @param password osn valid password
#'
#' @seealso https://www.world-airport-codes.com/
#' @seealso https://opensky-network.org/apidoc/rest.html#arrivals-by-airport
#' @seealso https://opensky-network.org/apidoc/rest.html#departures-by-airport
#' 
#' @import httr
#' @return The response is a JSON array of flights where each flight is an object with properties
#' 
#' @export
#'
#' @examples 
#' \dontrun{
#' getOSNflightsByAirport(icao.code = "LFPG",
#'                        type = "arrival",
#'                        from.time = "2018-01-29 00:00:00",
#'                        to.time = "2018-01-29 01:00:00",
#'                        login = "login",
#'                        password = "my pasword")
#' }
getOSNflightsByAirport <- function(icao.code="JFK",
                                   type = "arrival",
                                   from.time = "2018-12-24 20:00:00",
                                   to.time = "2018-12-24 23:59:00",
                                   login = NULL,
                                   password = NULL){
  
  ## Test if login & password are provided
  if(is.null(login) | is.null(password)){
    stop('Valid "login" and/or "password" are required')
  }
  
  
  ## Test if type is null
  if(is.null(type)){
    stop('"type" cannot be NULL, value restricted to "arrival" or "departure"')
  }
  ## Test if type is known
  if(type %in% c("arrival","departure")) {
    
    ## Define OpenSky API URL
    url.base <- paste0("https://",login,":",password,"@opensky-network.org/api/flights/")
    
    if( type == "departure") {
      url.type <- "departure?"
    } else {
      url.type <- "arrival?"
    }
    url.airport <- paste0("airport=",icao.code)
    url.from.time <- paste0("&begin=",as.integer(as.POSIXct(from.time)))
    url.to.time <- paste0("&end=",as.integer(as.POSIXct(to.time)))
    
    url <- paste0(url.base, url.type, url.airport, url.from.time, url.to.time)
    message(url)
    
    ## GET request
    request <- GET(url)
    stop_for_status(request)
    if(status_code(request) == 200){
      answer <- content(request, "parsed", "application/json", encoding="UTF-8")
    } else {
      answer <- NULL
    }
    
  } else {
    answer <- NULL
    stop('Invalid "type", value restricted to "arrival" or "departure"')
  }
  
  return(answer)
}



#' loop for multi-day flight tables
#' 

extract_flt_apt <- function(.apt, .type, .from, .to, .login, .password){
  
 # from_date = paste0(.from," 00:00:00")
#  end_date  = paste0(.to , " 23:59:00")
  
#  horizon <- seq(
 #    as.POSIXct(.from, tz="UTC") 
  #  ,as.POSIXct(.to  , tz="UTC")
   # , by="day") %>% as.character()
  
  flts <- getOSNflightsByAirport(
       icao.code = .apt
      ,type      = .type
      ,from.time = .from
      ,to.time   = .to
      ,login     = .login
      ,password  = .password
      )
  
  flts <- flts %>%
    purrr::map(.f=~flatten_dfc(.)) %>%
    bind_rows()
  return(flts)
}


