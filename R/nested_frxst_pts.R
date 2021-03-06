if(FALSE) {
## Generated by the nudging branch with only preprocessing flag
## CHANNEL_CONNECTIVITY=1
chanConnFile <- '~/WRF_Hydro/FRNG_NHD/DOMAIN/CHANNEL_CONNECTIVITY_KS.nc'
fullDomFile <- '~/WRF_Hydro/FRNG_NHD/DOMAIN/Fulldom_hires_netcdf_file_KS.nc'

options(warn=1)

devtools::load_all()
rlFile <- ChanConnToRouteLink(chanConnFile, fullDomFile, overwrite=TRUE)

library(doMC)
registerDoMC(8)
## This takes a while, but is a one-time calculation per route-link.
reExFiles <- ReExpressRouteLink(routeLink.nc=rlFile, parallel=TRUE)

PlotRL <- VisualizeRouteLink(rlFile,reExFiles['downstream.Rdb'])
plotObj <- PlotRL()

rlGages <- subset(plotObj$rl, gages != formatC('',width=15))

plotObj$ggObj +
  ggplot2::geom_segment(data=rlGages, 
                        ggplot2::aes(x=lon, y=lat, xend=to_lon, yend=to_lat), 
                        color='red', size=3) +
  ggplot2::geom_text(data=rlGages, 
                     ggplot2::aes(x=lon/2+to_lon/2, 
                                  y=lat/2+to_lat/2, 
                                  label=trimws(gages)), 
                     color='black') 

## Bring in the route link
rl <- as.data.frame(GetNcdfFile(rlFile))




## Bring in the upstream re expression file
print(load(reExFiles['upstream.Rdb']))

frxstPts <- as.numeric(rl$gages[which(rl$gages != formatC('', width=15))])
frxstInds <- which(rl$gages != formatC('', width=15))
names(frxstPts) <- frxstInds

wh11 <- which(frxstPts==11)


GetBasinFrxst <- function(start){
  print(start)
  up <- GatherStreamInds(from, start, length=rl$Length)
  up$frxstPt <- frxstPts[as.character(up$startInd)]
  up$frxstAbove <- intersect(frxstInds, up$ind)
  if(length(up$frxstAbove)) up$frxstAbove <- frxstPts[as.character(up$frxstAbove)]
  up
} 


#nestFrxst <- plyr::llply(setdiff(frxstInds, c(294428)), GetBasinFrxst)
up11 <- GetBasinFrxst(frxstInds[wh11])

PrintFrxstAbove <- function(ii) {
  ll=nestFrxst[[ii]]
  if(!length(ll$frxstAbove)) return(invisible(FALSE))
  cat("\n(Index: ",ii,')\n')
  cat("Frxst pt: ", ll$frxstPt, '\n')
  cat("Frxst above: ", paste(ll$frxstAbove, collapse=', '), '\n')
  TRUE
}

plyr::laply(1:length(nestFrxst), PrintFrxstAbove)

}
