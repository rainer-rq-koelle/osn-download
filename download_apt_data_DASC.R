library(tidyverse)
library(readr)
library(osn)
source("./R/bounding_box.R")
source('./R/osn_query_apt_bbox.R')

# script to download study data from Opensky Network

############### DEFINE STUDY AIRPORTS ############################
# study airport(s)
study_apts <- c("LSZH","EGKK","VTBS")

######################################
# airport look-up table
######################################
apt_file <- "./data/apt_openairports.csv"
if(!file.exists(apt_file)){
  message("Downloading airport reference table from OpenAirports.com.")
  url    <- "https://ourairports.com/data/airports.csv"
  apts   <- readr::read_csv(url)
  readr::write_csv(apts, apt_file )
}else{
  message("Loading airport reference table from OpenAirports.com")
  apts   <- readr::read_csv(apt_file)
}

#####################################
# retrieve bounding box
#####################################
radius <- 42 # 102
apts   <- apts 

apt <- apts %>% dplyr::filter(ident == "VTBS") %>% 
  dplyr::select(
    ICAO = ident
    , LON = longitude_deg
    , LAT = latitude_deg
    ,ELEV = elevation_ft
  )

# apt <- data.frame(ICAO = "EGKK", LAT = 51.148101807, LON = -0.19027799, ELEV = 202)
apt <- data.frame(ICAO = "LSZH", LAT = 47.464699, LON = 8.54917, ELEV=1416)
#apt <- data.frame(ICAO = "SBSP", LAT = -23.626110077, LON =-46.65638733, ELEV=2631)

# https://www.airport-data.com/api/ap_info.json?icao=ESSA
library("httr")
library(jsonlite)
get_apt_info <- function(.icao){
  request <- httr::GET("https://www.airport-data.com/api/ap_info.json", query = list(icao=.icao))
  payload <- jsonlite::fromJSON(rawToChar(request$content))
  payload <- tibble::as_tibble(payload)
  return(payload)
}

apt <- get_apt_info("ESSA") %>% 
  rename(ICAO = icao, LAT = latitude, LON = longitude) %>%
  mutate(LAT = as.numeric(LAT), LON = as.numeric(LON))
bbox  <- apt_bb(apt_info, .dist = 42)

apt_bb <- function(.apt, .dist=radius){
  apt_bb <- bounding_box(lat = .apt$LAT, lon = .apt$LON, .dist)
  # coerce apt_bb matrix into vector c(LONmin, LONmax, LATmin, LATmax)
  apt_bb <- apt_bb %>% t() %>% as.vector()
  # apply naming convention for Opensky Network
  names(apt_bb) <- c("xmin","xmax","ymin","ymax")
  return(apt_bb)
}

bbox <- apt_bb(apt, radius)

## LSZH 42NM bbox <- 7.514402  9.583938 46.765171 48.164227 
## SBSP 102NM bbox   -48.51072 -44.80206 -25.32496 -21.92726
## ESSA 42NM bbox 16.53400 19.30323 58.95242 60.35147 


######################################
# query Opensky Network helper functions
######################################

extract_osn_adsb <- function(.start_date, .session, .bbox){
  start_dy <- lubridate::date(.start_date)
  adsb     <- query_osn(.start_date, .session, .bbox)
}

write_adsb <- function(.adsb, .start_date, .apt, .id, .subfolder=NULL, ...){
  ## construct filename
  start_dy <- lubridate::date(.start_date)
  start_hr <- lubridate::hour(.start_date)
  end_hr   <- start_hr + 1
  
  out_fn <- "./data-raw/"   ## construct filename ------------------------
  if(!is.null(.subfolder)){
    out_fn <- paste0(out_fn, .subfolder, "/")
  }
  out_fn <- paste0(
    out_fn, "osn_", .apt, "_", .id, "_"
    ,start_dy, "_", sprintf("%02d",start_hr), "00-"
                       , sprintf("%02d",end_hr),"00.csv"
  ) ############# end file-name ------------------------------------------
  
  message("\n writing ", out_fn)
  write_csv(.adsb, out_fn)
}

download_osn <- function(
  .start_date, .session, .bbox, .apt=apt$ICAO, .id, .subfolder, ...){
  
  adsb <- extract_osn_adsb(.start_date, .session, .bbox)
  write_adsb(adsb, .start_date, .apt, .id, .subfolder )
}


#################################################################
######  FOR DOWNLOAD - SESSION ##################################

session <- osn_connect(usr    = Sys.getenv("osn_usr") , passwd = Sys.getenv("osn_pw"))
## at work: launch putty and go via VPN tunnel ##################
## ... asks for password
# session <- osn_connect(Sys.getenv("osn_usr"), host = "localhost", port = 6666)

############## DOWNLOAD HORIZON ##################################

horizon <- seq(
  as.POSIXct("2019-05-01 00:00:00",tz="UTC")  # start date
 ,as.POSIXct("2019-05-07 23:00:00",tz="UTC")  # horizon end date 23:00hrs
  , by="hour")

############## ITERATE AND DOWNLOAD ###############################

horizon %>% purrr::walk(
  .f=~download_osn(., .session=session, .bbox = bbox)
  )

############### CLOSE SESSION WHEN DONE ###########################

osn::osn_disconnect(session)

