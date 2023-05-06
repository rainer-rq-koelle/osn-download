library(lubridate)
library(stringr)
library(here)


base_url <- "https://secure.flightradar24.com/2020-04-15-Eurocontrol"

# sequence of dates
# d <- seq(ymd('2019-11-01'), ymd('2020-04-15'), by = '1 day')
# test
d <- seq(ymd('2020-03-01'), ymd('2020-04-15'), by = '1 day')
# d <- seq(ymd('2019-12-01'), ymd('2020-04-15'), by = '1 day')

# file names
flt_file <- str_glue("{YYYY}{MM}{DD}_flights.csv"  , YYYY = format.Date(d, "%Y"), MM = format.Date(d, "%m"), DD = format.Date(d, "%d"))
pts_file <- str_glue("{YYYY}{MM}{DD}_positions.zip", YYYY = format.Date(d, "%Y"), MM = format.Date(d, "%m"), DD = format.Date(d, "%d"))

# build the urls
flt_url <- str_glue("{base_url}", "{YYYY}_{MM}", "{flt_file}"  ,
                    base_url = base_url, flt_file = flt_file,
                    YYYY = format.Date(d, "%Y"),
                    MM   = format.Date(d, "%m"),
                    DD   = format.Date(d, "%d"),
                    .sep = "/")
pts_url <- str_glue("{base_url}", "{YYYY}_{MM}", "{pts_file}"  ,
                    base_url = base_url, pts_file = pts_file,
                    YYYY = format.Date(d, "%Y"),
                    MM   = format.Date(d, "%m"),
                    DD   = format.Date(d, "%d"),
                    .sep = "/")

# download the files
purrr::walk2(c(flt_url, pts_url), c(flt_file, pts_file),
             ~download.file(.x, here::here("data-raw", "fr24" , .y),
                            quiet = TRUE,
                           method = "wget",
                            extra = "--user 2020-04-15-Eurocontrol --password MhtLwu6fFO"
             )
)





#GET(as.character(dat[r, i]), 
#    authenticate("username", "password"),
#    write_disk(destfile=paste(names(dat)[i], dat$id[r], "wav", sep="."))
# )