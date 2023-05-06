library(osn)
library(readr)

# Option 1 to run from ectl server
# session <- osn_connect(usr = "rqkoelle", passwd = "dilbert1967", host = "localhost", port = 6666)
 session <- osn_connect(usr = "rqkoelle", "dilbert1967")
                       
# MUAC
bb_muac <- c(xmin = 1.5, xmax = 11.5, ymin = 49.0, ymax = 55.5)
min_alt <- 245

# Script from Rainer, modified (excluded apt and radius)

query_osn <- function(.start_date, .session, .bbox){
  start_date <- .start_date
  session    <- .session
  message(paste("extracting ", start_date, sep = ""))
  
  end_date   <- start_date + lubridate::hours(1)
  start_hr   <- lubridate::hour(start_date)
  end_hr     <- start_hr + 1
  
  start_date_c <- as.character(start_date)
  end_date_c   <- as.character(end_date)
  
  sv <- state_vector(
    session, icao24 = NULL
    , wef = start_date_c
    , til = end_date_c
    ,bbox = .bbox
  )
  
  #  readr::write_csv(sv, file_name )
  return(sv)
}

# extract_osn_adsb() extracts the state vectors
extract_osn_adsb <- function(.start_date, .session, .bbox){
  start_dy <- lubridate::date(.start_date)
  adsb     <- query_osn(.start_date, .session, .bbox)
}

write_adsb <- function(.adsb, .start_date,...){
  ## construct filename
  start_dy <- lubridate::date(.start_date)
  start_hr <- lubridate::hour(.start_date)
  end_hr   <- start_hr + 1
  
  out_fn <- paste0(
    getwd(), "/data-raw/", "/MUAC_"
    ,start_dy, "_", sprintf("%02d",start_hr), "00-"
    , sprintf("%02d",end_hr),"00.csv.gz"
  ) ############# end file-name
  message("writing ", out_fn)
  write_csv(.adsb, gzfile(out_fn))
}

download_osn <- function(
  .start_date, .session, .bbox, ...){
  
  adsb <- extract_osn_adsb(.start_date, .session, .bbox)
  write_adsb(adsb, .start_date)
}

# START execution time
t1 <- lubridate::now()
t1
############## DOWNLOAD HORIZON ##################################
# define the time horizon and then wrap all in a purrr
horizon <- seq(
  # start date updated in accordance with latest download.
  # start download with: 2019-06-09 18:00:00 
   as.POSIXct("2019-06-09 18:00:00", tz="UTC")  # start date 22:00hrs Friday
  ,as.POSIXct("2019-06-10 04:00:00", tz="UTC")
  ,by="hour")

############## ITERATE AND DOWNLOAD ###############################

horizon %>% purrr::walk(
  .f=~download_osn(., .session=session, .bbox = bb_muac)
)
# END execution time
t2 <- lubridate::now()
t2-t1
