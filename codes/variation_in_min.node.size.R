library(ranger)

load("../data/intermediate/test_dat.Rda")
load("../data/intermediate/train_dat.Rda")

sampled_dat <- train_dat

#sampled_dat = subset(sampled_dat, application != 'hmm')
#attach(sampled_dat)
#sampled_dat = sampled_dat[which(!(application == 'hmm' & device == 'knl')),]
#detach(sampled_dat)
sdat_size = sampled_dat$size
sdat_kernel = sampled_dat$kernel
sampled_dat = subset(sampled_dat, select = -size)
sampled_dat = subset(sampled_dat, select = -application)
sampled_dat = subset(sampled_dat, select = -kernel)
sampled_dat = subset(sampled_dat, select = -total_time)

#determine location of integer and factor variables
is.wholenumber <- function(x, tol = .Machine$double.eps^0.5){
    if (is.factor(x)){
        return(FALSE)
    }
    return(abs(x - round(x)) < tol)
}
int.inds <- c()
for(i in seq(1,ncol(sampled_dat))){
    if (length(unique(sapply(sampled_dat[i], is.wholenumber)))==1){
        int.inds <- c(int.inds,i)
    }
}
#int.inds <- c(1,5,6,7,8,9,10,12,15,16,29,32,33,35)

#standardise numeric variables
num.inds <- lapply(sampled_dat, is.numeric)
num.inds <- as.logical(num.inds)

for (i in seq(along = num.inds)){
			feature.name = names(sampled_dat[i])
			ifelse((any(i == int.inds) || num.inds[i] == 'FALSE' || feature.name == "kernel_time"), next, sampled_dat[i] <- scale(sampled_dat[i]))
								} #end i loop


prediction_wrapper_function <- function(x){
    pwf.num.trees <- 300#round(x[1])
    pwf.mtry <- 30#round(x[2])
    pwf.min.node.size <-round(x[1]) 

    rgd.aiwc <- ranger(#(2*((kernel_time^-0.5)+(3/8)))^-1~., 
                       log(kernel_time)~.,
                       data = sampled_dat,
                       num.trees = pwf.num.trees,
                       mtry = pwf.mtry,
                       min.node.size = pwf.min.node.size,
                       importance = "impurity",
                       splitrule = 'variance',
                       respect.unordered.factors = 'order')
    #print(paste("trying",pwf.num.trees,'trees',
    #            pwf.mtry,'mtrys and',
    #            pwf.min.node.size,'min node size',
    #            "prediction error:",rgd.aiwc$prediction.error))
    return(rgd.aiwc$prediction.error)
}

z <- data.frame()
for(i in seq(1,50,by=1)){
    z <- rbind(z, data.frame(x=i, y=prediction_wrapper_function(i)))
    print(paste("determined ",i, " min.node.size has the prediction.error ",z[i,]$y))
}


save(z,file="../data/intermediate/variation_in_min.node.size.Rdf")

