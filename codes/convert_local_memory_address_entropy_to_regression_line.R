
#traverse all featdata.* variables
all_featdata <- ls(all.names = TRUE)
featdata_objects <- all_featdata[grep("featdata.*",all_featdata)]

for (featdata_string in featdata_objects){
    featdata <- eval(parse(text=featdata_string))
    for (kernel in unique(featdata$kernel)){
        for (size in unique(featdata$size)){
            for (invocation in unique(featdata$invocation)){
                treatment <- featdata[which(featdata$invocation == invocation & featdata$size == size & featdata$kernel==kernel),]
                lmae.lsbs <- c()
                lmae.entropy <- c()
                for (i in seq(1,10)){
                    lmae.lsbs <- c(lmae.lsbs, i)
                    lmae.entropy <- c(lmae.entropy, treatment[which(treatment$metric == paste("local memory address entropy -- ",i," LSBs skipped",sep='')),]$count)
                }
                lm_fit <- lm(lmae.lsbs ~ lmae.entropy)
                #summary(lm_fit)
                #lm_pred <- predict(lm_fit)
                #attach the offset and gradient to the data
            }
        }
    }
}
