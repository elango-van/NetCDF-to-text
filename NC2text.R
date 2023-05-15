
rm(list=ls(all=TRUE))
library('ncdf4')

## NC file list
scrfiles <- read.delim('E:/NEXGDDP_CMIP6_NC_INDIA/Merged/MME/ncfileslist.txt',header=F,sep='\t',stringsAsFactors=F)
## list of lat lon to extract
grids <- read.delim('E:/NEXGDDP_CMIP6_NC_INDIA/Merged/GRIDs.csv',header=T,sep=',',stringsAsFactors=F)

for(f in 1:length(scrfiles)){
	filename <- scrfiles[f]
	dr <- dirname(filename)
	ncin <- nc_open(filename)
	tmp.lat <- ncvar_get(ncin, "lat")
	tmp.lon <- ncvar_get(ncin, "lon")
	prname <- names(ncin$var)
	times <- ncvar_get( ncin, "time")
	units <- ncatt_get( ncin, "time", "units" )$value
	time.split<-strsplit(units, ' ')[[1]]
	startingdate <- format(as.Date(times[1], origin=time.split[3]), "%Y%m%d")

	ifelse(!file.exists(file.path(dr, prname)), dir.create(file.path(dr, prname )), FALSE)

	tmp.array <- ncvar_get(ncin, prname)

	nc_close(ncin)
	rm(ncin)
	gc() 

	for(r in 1:nrow(grids)){

		lt <- which(round(tmp.lat,3) == round(grids[r,]$lat,3))
		ln <- which(round(tmp.lon,3) == round(grids[r,]$lon,3))

		if(length(lt) == 0 || length(ln) == 0) print(paste0(round(grids[r,]$lat,3),', ',round(grids[r,]$lon,3)))

		outfilename=paste0(file.path(dr, prname),'/',sprintf('%05d',round(tmp.lon[ln],3)*1000),'_',sprintf("%05d",round(tmp.lat[lt],3)*1000),'.txt')

		datvalue <- as.vector(tmp.array[ln,lt,])

		## print(paste(grids[r,]$lat,grids[r,]$lon, round(max(datvalue),2),sep=','))

		newdat<-datvalue[!is.na(datvalue)]
		if(length(newdat) == 0) {
			next
		}
		cat(startingdate,file=outfilename,sep="\n")
		cat(sprintf('%5.1f',datvalue),file=outfilename,sep="\n",append=TRUE)		
	}

	rm(tmp.array,tmp.lat,tmp.lon,tmp.doy,tmp.year,tloc)
	gc()
}
print('Completed')
