query_osn <- function(.start_date, .session, .bbox){
  start_date <- .start_date
  session    <- .session
  message(paste("extracting ", start_date, sep = ""))
  
  # bbox_eddf_trjs <- c(xmin = 7.536746, xmax = 9.604390, ymin = 49.36732, ymax = 50.69920)
  # c(xmin = min(Radius_coord$LON), xmax = max(Radius_coord$LON), ymin = min(Radius_coord$LAT), ymax = max(Radius_coord$LAT))
  
  #start_date <- lubridate::ymd_hms("2019-04-22 11:00:00", tz="UTC")
  
  end_date   <- start_date + lubridate::hours(1)
  start_hr   <- lubridate::hour(start_date)
  end_hr     <- start_hr + 1
  
  start_date_c <- as.character(start_date)
  end_date_c   <- as.character(end_date)
  
#  file_name <- paste("./data/adsb_eidw_"
#                     , lubridate::date(start_date),"_", sprintf("%02d",start_hr), "00-"
#                     , sprintf("%02d",end_hr),"00.csv", sep="")
  
  sv <- state_vector(
    session, icao24 = NULL
    , wef = start_date_c
    , til = end_date_c
    ,bbox = .bbox
  )
  
#  readr::write_csv(sv, file_name )
 return(sv) 
}