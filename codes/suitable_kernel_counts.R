load("full_dat.Rda")

#standardise numeric variables
num.inds <- lapply(full_dat, is.numeric)
num.inds <- as.logical(num.inds)

for (i in seq(along = num.inds)){
            feature.name = names(full_dat[i])
            ifelse((any(i == int.inds) || num.inds[i] == 'FALSE' || feature.name == "kernel_time"), next, full_dat[i] <- scale(full_dat[i]))
                                } #end i loop

library(tictoc)
library(Metrics)
library(ranger)
library(ggplot2)

results <- data.frame()

k <- unique(full_dat$kernel)
k <- levels(droplevels(k))

num_samples <- 500

for(i in seq(1,length(k))){
    tic(paste('combinations of model score for ',i))

    tp <- c()
    ta <- c()

    #collect that many samples
    for(m in seq(1,num_samples)){

        #shuffle vector and collect i kernel samples
        y <- sample(k)[1:i]

        #subset the data frame
        train_dat <- subset(full_dat,kernel == y)
        test_dat <-  subset(full_dat,kernel != y)

        #remove certain variables unavailable during real-world training
        train_dat = subset(train_dat, select = -size)
        train_dat = subset(train_dat, select = -application)
        train_dat = subset(train_dat, select = -kernel)
        train_dat = subset(train_dat, select = -total_time)

        test_dat = subset(test_dat, select = -size)
        test_dat = subset(test_dat, select = -application)
        test_dat = subset(test_dat, select = -kernel)
        test_dat = subset(test_dat, select = -total_time)

        #build random forest model and make the prediction
        rgd.aiwc <- ranger(#(2*((kernel_time^-0.5)+(3/8)))^-1~., 
                           log(kernel_time)~.,
                           data = train_dat,
                           num.trees = 505,
                           mtry = 30,
                           min.node.size = 34,
                           importance = "impurity",
                           splitrule = 'variance',
                           respect.unordered.factors = 'order')

        p <- predict(rgd.aiwc,type='response',data=test_dat)
        z <- log(test_dat$kernel_time)

        #add the predictions and actual times to the big lists
        tp <- c(tp,p$predictions)
        ta <- c(ta,z)

    }
  
    #compute the root mean squared error and store the result for that number of kernels
    results <- rbind(results,
                     data.frame('number.of.kernels'=i,
                                'rmse'=rmse(ta,tp),
                                'mae'=mae(ta,tp)))
    toc()

}

write.table(results, '../data/intermediate/rmse_vs_kernel_count.Rtable', col.names=TRUE, row.names=FALSE, sep=" ")

pdf('rmse_vs_kernels.pdf')
ggplot(dat=results,aes(x=number.of.kernels,y=rmse)) + geom_line() + labs(x="# of kernels",y="rmse")  + ylim(0,max(results$rmse))
dev.off()

pdf('mae_vs_kernels.pdf')
ggplot(dat=results,aes(x=number.of.kernels,y=mae)) + geom_line() + labs(x="# of kernels",y="rmse") + ylim(0,max(results$mae))
dev.off()

