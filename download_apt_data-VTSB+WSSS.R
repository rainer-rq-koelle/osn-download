library(tidyverse)
library(readr)
library(osn)
source("./R/bounding_box.R")
source('./R/osn_query_apt_bbox.R')

################## AIRPORT INFORMATION ##################################
# https://www.airport-data.com/api/ap_info.json?icao=ESSA
library(httr)
library(jsonlite)

# helper function to retrieve apt information
get_apt_info <- function(.icao){
  request <- httr::GET("https://www.airport-data.com/api/ap_info.json", query = list(icao=.icao))
  payload <- jsonlite::fromJSON(rawToChar(request$content))
  payload <- tibble::as_tibble(payload)
  return(payload)
}

apt <- get_apt_info("VTBS") %>% 
  rename(ICAO = icao, LAT = latitude, LON = longitude) %>%
  mutate(LAT = as.numeric(LAT), LON = as.numeric(LON))


################### DEFINE BOUNDING BOX ##############################
radius <- 22 # 42NM adding buffer to 40NM

calc_bb <- function(.apt, .dist=radius){
  apt_bb <- bounding_box(lat = .apt$LAT, lon = .apt$LON, .dist)
  # coerce apt_bb matrix into vector c(LONmin, LONmax, LATmin, LATmax)
  apt_bb <- apt_bb %>% t() %>% as.vector()
  # apply naming convention for Opensky Network
  names(apt_bb) <- c("xmin","xmax","ymin","ymax")
  return(apt_bb)
}

bbox <- calc_bb(apt, radius)

# bbox ESSA: 16.53400 19.30323 58.95242 60.35147 
# LSZH 22NM: 8.007157  9.091177 47.098302 47.831142 

#VTSB + VTBD bbox 205 NM
bbox <- c(xmin = 97.04984, ymin = 10.24641, xmax = 104.28611, ymax = 17.35681) 

######################################
# query Opensky Network helper functions
######################################

extract_osn <- function(.start_datetime, .end_datetime, .session, .bbox, .icao24 = NULL, ...){
  adsb <- state_vector( session = .session
                       ,wef = .start_datetime
                       ,til = .end_datetime
                       ,bbox = .bbox
                       ,icao24 = .icao24)
}

construct_filename <- function(.apt_icao, .start_datetime, .end_datetime, .id="R20", .folder="data-raw",  .subfolder=NULL){
  start_dy <- lubridate::date(.start_datetime)
  start_hr <- lubridate::hour(.start_datetime)
  end_hr   <- lubridate::hour(.end_datetime)
  
  fn <- paste0("./", .folder, "/") 
  if(!is.null(.subfolder)){ fn <- paste0(fn, .subfolder, "/")}
  fn <- paste0(fn, "osn_", .apt_icao, "_", .id, "_")
  fn <- paste0(fn, start_dy, "_" ,sprintf("%02d",start_hr), "00-", sprintf("%02d",end_hr),"00.csv")
  
  return(fn)
}

download_osn <- function(.apt, .start_datetime, .end_datetime, .session, .bbox, ...){
  # extract from OSN
  message(paste0("\nExtracting data for ", .apt$ICAO))
  adsb <- extract_osn(.start_datetime, .end_datetime, .session, .bbox, ...)
 
  # save on disk
  fn <- construct_filename(apt$ICAO, .start_datetime, .end_datetime, ...)
  readr::write_csv(adsb, fn)
  message(paste0("---------- data written: ", fn))
}

#################################################################
######  FOR DOWNLOAD - SESSION ##################################
# set options --> check with getOption("timeout")
options(timeout=666)

session <- osn_connect(usr    = Sys.getenv("osn_usr") , passwd = Sys.getenv("osn_pw"))
## at work: launch putty and go via VPN tunnel ##################
## ... asks for password
# session <- osn_connect(Sys.getenv("osn_usr"), host = "localhost", port = 6666)

############## DOWNLOAD HORIZON ##################################

horizon <- seq(
   as.POSIXct("2022-09-01 00:00:00",tz="UTC")  # start date
  ,as.POSIXct("2022-09-02 23:00:00",tz="UTC")  # horizon end date 23:00hrs
  , by="hour")

############## ITERATE AND DOWNLOAD ###############################

myid <- "R205"
subfolder <- "VTBS_VTBD"

horizon %>% 
  purrr::walk(
    .f = ~ download_osn(.apt = apt
                        , .start_datetime = .
                        , .end_datetime   = . + 3600   # add one hour = 3600 sec
                        , .session = session
                        , .bbox    = bbox
                        , .id = myid
                        #, .subfolder = apt$ICAO
                        , .subfolder = subfolder
                        )
    )


############### CLOSE SESSION WHEN DONE ###########################

osn::osn_disconnect(session)
