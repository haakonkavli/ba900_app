# Load from DB to Rdata for offline use in app:

library(data.table)
library(RMySQL)

source('user_config.R')

# Load time series data:
cnx <- dbConnect(MySQL(),
                 user = config$db_username,
                 password = config$db_password,
                 dbname = 'pim_ts',
                 host = config$db_host)

# Update ts_raw_macro and ts_pit_macro:
ba <- data.table(dbReadTable(cnx,'ts_ba900'))
ba$datestamp <- as.Date(ba$datestamp)
dbDisconnect(cnx)


# Load static data:
cnx <- dbConnect(MySQL(),
                 user = config$db_username,
                 password = config$db_password,
                 dbname = 'pim_static',
                 host = config$db_host)

# Update ts_raw_macro and ts_pit_macro:
items <- data.table(dbReadTable(cnx,'s_ba900_items'))
items$ItemName <- ''
dbDisconnect(cnx)

items$Level <- 0

for (i in 1:nrow(items)) {

    tmp <- c(items[i,])
    items[i,]$Level <- sum(nchar(tmp)>0) - 2
}


ba <- merge(ba,
            items,
            by.x = 'item',
            by.y = 'id')

for (i in 1:nrow(items)) {

    tmp <- c(items[i,])
    tmpName <- tail(tmp[nchar(tmp)>0],1)
    items[i,]$Level <- sum(nchar(tmp)>0) - 2
    items[i,]$ItemName <- paste(
        paste(rep('-',max(0,sum(nchar(tmp)>0)-2)), collapse = ''),
        i,':',tmpName)

}


print('Done...')

save(ba,items,
     file = 'ba900_data.Rdata')


