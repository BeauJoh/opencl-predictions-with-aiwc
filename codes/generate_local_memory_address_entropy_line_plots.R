library(ggplot2)
source('./analysis_tools/load_aiwc_dataframes.R')

#traverse all featdata.* variables
all_featdata <- ls(all.names = TRUE)
featdata_objects <- grep("featdata\\..*",all_featdata,value=TRUE)

for (featdata_string in featdata_objects){
    featdata <- eval(parse(text=featdata_string))
    for (kernel in unique(featdata$kernel)){
        for (size in unique(featdata$size)){
            for (invocation in unique(featdata$invocation)){
                subdata <- featdata[which(featdata$invocation == invocation & featdata$size == size & featdata$kernel==kernel),]
                if(nrow(subdata)==0){
                    break
                }
                lmae.lsbs <- c()
                lmae.entropy <- c()
                for (i in seq(1,10)){
                    lmae.lsbs <- c(lmae.lsbs, i)
                    lmae.entropy <- c(lmae.entropy, subdata[which(subdata$metric == paste("local memory address entropy -- ",i," LSBs skipped",sep='')),]$count)
                }
                #browser()
                df <- data.frame(lsbs=lmae.lsbs,entropy=lmae.entropy)
                df_plot <- ggplot(dat=df,aes(x=lsbs,y=entropy)) + geom_line() + geom_point() +
                    labs(x = "# of Bits Skipped", y = "Memory Address Local Entropy") +
                    scale_y_continuous(breaks=seq(0,12,by=2),limit=c(0,12)) +
                    scale_x_continuous(breaks=seq(0,10,by=2))
                pdf_name <- paste("./results/local-memory-address-entropy-line-plots/",kernel,"_",size,"_",invocation,".pdf",sep='')
                pdf(pdf_name)
                print(df_plot)
                dev.off()
                print(paste("wrote to ",pdf_name))
            }
        }
    }
}
