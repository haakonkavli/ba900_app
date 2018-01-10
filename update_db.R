library(data.table)
library(RMySQL)

source('config.R')  # Important: Create non-public gitignore file with username and password for DB

banks <- c('TOT','ASA','ABL','CPI','FSR','INL','NED', 'SBK')
ba900 <- data.table()
for (bank in banks) {

    dat <- data.table(read.csv(paste0('H:/Haakon/Research/BA900/BA900 data/Data_OutPut/BA900_ExportData/',bank,'.csv')))

    dm <- melt(dat,id.var = 'Dates')

    ba900 <- rbind(ba900,dm[,.(datestamp,
                               bank = bank,
                               item = substr(variable,4,6),
                               value = value)])

}

write.csv(ba900,'ba900.csv',row.names = F)

cnx <- dbConnect(MySQL(),
                 user = config$username,
                 password = config$password,
                 dbname = config$dbname,
                 host = config$host)

# Update ts_raw_macro and ts_pit_macro:
table_name <- 'table_name'
dbWriteTable(cnx,table_name,ba900, append = T,row.names = F)
dbDisconnect(cnx)

