source('../analysis_tools/load_aiwc_dataframes.R')

x <- featdata.lud[featdata.lud$size=='tiny' & featdata.lud$kernel == 'lud_perimeter',]
df <- data.frame()
for (invocation in unique(x$invocation)){
    y <- x[x$invocation==invocation,]
    lmae.lsbs <- c()
    lmae.entropy <- c()
    for (i in seq(1,10)){
        lmae.lsbs <- c(lmae.lsbs, i)
        lmae.entropy <- c(lmae.entropy, y[which(y$metric == paste("local memory address entropy -- ",i," LSBs skipped",sep='')),]$count)
    }
    df <- rbind(df, data.frame(invocation=invocation,lsbs=lmae.lsbs,entropy=lmae.entropy))
}
library(ggplot2)
df_plot <- ggplot(dat=df,aes(x=lsbs,y=entropy,colour=invocation)) +
    geom_line() +
    geom_point() +
    labs(x = "# of Bits Skipped", y = "Memory Address Local Entropy", colour="Invocation #") +
    scale_y_continuous(breaks=seq(0,12,by=2),limit=c(0,12)) +
    scale_x_continuous(breaks=seq(0,10,by=2))
print(df_plot)

