#see split_and_fit.log for output log
load("full_dat.Rda")
library(tictoc)

results <- data.frame()
prog_count <- 0
for(k in unique(full_dat$kernel)){
    sampled_dat <- full_dat
    prog_count <- prog_count +1
    print(paste("PROGRESS:",prog_count,"of",length(unique(sampled_dat$kernel))))
    print(paste("Attempting split and fit without",k,"..."))
    sampled_dat <- subset(sampled_dat,kernel != k)
    sdat_size = sampled_dat$size
    sdat_kernel = sampled_dat$kernel
    sampled_dat = subset(sampled_dat, select = -size)
    sampled_dat = subset(sampled_dat, select = -application)
    sampled_dat = subset(sampled_dat, select = -kernel)
    sampled_dat = subset(sampled_dat, select = -total_time)

    #determine location of integer and factor variables
    #is.wholenumber <- function(x, tol = .Machine$double.eps^0.5){
    #    if (is.factor(x)){
    #        return(FALSE)
    #    }
    #    return(abs(x - round(x)) < tol)
    #}
    #int.inds <- c()
    #for(i in seq(1,ncol(sampled_dat))){
    #    if (length(unique(sapply(sampled_dat[i], is.wholenumber)))==1){
    #        int.inds <- c(int.inds,i)
    #    }
    #}
    int.inds <- c(1,5,6,7,8,9,10,12,15,16,29,32,33,35)

    #standardise numeric variables
    num.inds <- lapply(sampled_dat, is.numeric)
    num.inds <- as.logical(num.inds)

    for (i in seq(along = num.inds)){
                feature.name = names(sampled_dat[i])
                ifelse((any(i == int.inds) || num.inds[i] == 'FALSE' || feature.name == "kernel_time"), next, sampled_dat[i] <- scale(sampled_dat[i]))
                                    } #end i loop
    library(ranger) 
    library(optimization)
    prediction_wrapper_function <- function(x){
        pwf.num.trees <- x[1]
        pwf.mtry <- x[2]
        pwf.min.node.size <- x[3]

        rgd.aiwc <- ranger(#(2*((kernel_time^-0.5)+(3/8)))^-1~., 
                           log(kernel_time)~.,
                           data = sampled_dat,
                           num.trees = pwf.num.trees,
                           mtry = pwf.mtry,
                           min.node.size = pwf.min.node.size,
                           importance = "impurity",
                           splitrule = 'variance',
                           respect.unordered.factors = 'order')
        filename <- 'heatmap.Rtable'
        x <- data.frame('num.trees'=pwf.num.trees,
                        'mtry'=pwf.mtry,
                        'min.node.size'=pwf.min.node.size,
                        'prediction.error'=rgd.aiwc$prediction.error)
        if(!file.exists(filename)){
            write.table(x,file=filename,col.names=TRUE)
        }else{
            write.table(x,file=filename,append=TRUE,col.names=FALSE)
        }
        return(rgd.aiwc$prediction.error)
    }

    var_fun_int <- function (para_0, fun_length, rf, temp = NA) {
        ret_var_fun <- para_0 + sample.int(rf, fun_length, replace = TRUE) *
            ((rbinom(fun_length, 1, 0.5) * -2) + 1)
        return (ret_var_fun)
    }

    tic("search for optima")
    out <- optim_sa(fun=prediction_wrapper_function,
                    start=c(500,32,9),
                    lower=c(1    ,1 ,1),
                    upper=c(10000,34,50),
                    control=list(t0=1.0,
                                 nlimit=50,
                                 r=0.1,
                                 rf=c(10,1,1),
                                 ac_acc = 0.01,
                                 dyn_rf = TRUE,
                                 vf =var_fun_int),
                    trace=TRUE)
    toc()
    
    file.rename(from='heatmap.Rtable',to=paste('sans_',k,'_heatmap.Rtable',sep=''))
    pdf(paste('optim_sa_contour_model_fit_sans_',k,'.pdf',sep=''))
    p <- plot(out)#,'contour')
    print(p)
    dev.off()
    save(out,file=paste("optim_sa_model_fit_sans_",k,".Rdf",sep=''))
    print(paste("Optimised SA model fit sans",k,"found the optimal parameters",out$par))

    rgd.aiwc <- ranger(#(2*((kernel_time^-0.5)+(3/8)))^-1~., 
                       log(kernel_time)~.,
                       data = sampled_dat,
                       num.trees = round(out$par[1]),
                       mtry = round(out$par[2]),
                       min.node.size = round(out$par[3]),
                       importance = "impurity",
                       splitrule = 'variance',
                       respect.unordered.factors = 'order')

    print(paste("with prediction error:",rgd.aiwc$prediction.error,"and r-squared:",rgd.aiwc$r.squared))
  
    results <- rbind(results, data.frame('kernel.omitted'=k,
                                         'num.trees'=out$par[1],
                                         'mtry'=out$par[2],
                                         'min.node.size'=out$par[3],
                                         'prediction.error'=rgd.aiwc$prediction.error,
                                         'r.squared'=rgd.aiwc$r.squared))

    library(ggplot2) 
    z <- data.frame(predicted=rgd.aiwc$predictions,
                actual=log(sampled_dat$kernel_time),
                device=sampled_dat$device,
                size=as.numeric(sdat_size),
                kernel=sdat_kernel)
    pdf(paste('optimized_model_sans_',k,'.pdf',sep=''))
    g <- ggplot(data=z,aes(x=actual,y=predicted,colour=size)) + geom_point()
    print(g)
} # end k loop

write.table(x=results,file="tuning-variations.Rtable")

