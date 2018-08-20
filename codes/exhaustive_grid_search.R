library(ellipse)
library(MASS)
library(ranger)
library(RColorBrewer)

load("../data/intermedia/test_dat.Rda")
load("../data/intermedia/train_dat.Rda")

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

#full_grid = data.frame()
#for(n in c(500,1000,1500,2000,2500)){
#    for(m in seq(1,ncol(sampled_dat)-1,by=1)){
#        for(mns in seq(1,50)){
#            rgd.aiwc <- ranger((2*((kernel_time^-0.5)+(3/8)))^-1~.,
#                               data = sampled_dat,
#                               num.trees = n,
#                               mtry = m,
#                               min.node.size = mns,
#                               importance = "impurity",
#                               splitrule = 'variance',
#                               respect.unordered.factors = 'order')
#            new_row <- data.frame('num.trees'=n,
#                                  'mtry'=m,
#                                  'min.node.size'=mns,
#                                  'r-squared'=rgd.aiwc$r.squared,
#                                  'predicted_error'=rgd.aiwc$prediction.error,
#                                  'cor'=cor(rgd.aiwc$predictions,sampled_dat$kernel_time,use = "complete.obs"))
#            print(new_row)
#            full_grid <- rbind(full_grid, new_row)
#        }
#    }
#}

#full_grid
load('exhaustive_grid_search_500_to_2500.Rdf')

#> which.min(full_grid$predicted_error)
#[1] 1264
#> which.max(full_grid$r.squared)
#[1] 1264
#> full_grid[1264,]
#     num.trees mtry min.node.size r.squared predicted_error       cor
#1264       500   26            14 0.9487496     0.001545193 0.2304378

#med_grid = data.frame()
#for(n in seq(300,600,by=1)){
#    for(m in 26){
#        for(mns in 14){
#            rgd.aiwc <- ranger((2*((kernel_time^-0.5)+(3/8)))^-1~.,
#                               data = sampled_dat,
#                               num.trees = n,
#                               mtry = m,
#                               min.node.size = mns,
#                               importance = "impurity",
#                               splitrule = 'variance',
#                               respect.unordered.factors = 'order')
#            new_row <- data.frame('num.trees'=n,
#                                  'mtry'=m,
#                                  'min.node.size'=mns,
#                                  'r-squared'=rgd.aiwc$r.squared,
#                                  'predicted_error'=rgd.aiwc$prediction.error,
#                                  'cor'=cor(rgd.aiwc$predictions,sampled_dat$kernel_time,use = "complete.obs"))
#            print(new_row)
#            med_grid <- rbind(med_grid, new_row)
#        }
#    }
#}
#
#pdf('num_trees_vs_predicted_error_on_med_grid.pdf')
#p <- ggplot(data=med_grid,aes(x=num.trees,y=predicted_error)) + geom_line() + geom_point()
#print(p)
#dev.off()

#med_grid
load('exhaustive_grid_search_300_to_600.Rdf')

#tiny_grid = data.frame()
#for(n in 310){
#    for(m in seq(1,ncol(sampled_dat)-1,by=1)){
#        for(mns in seq(1,50)){
#            rgd.aiwc <- ranger((2*((kernel_time^-0.5)+(3/8)))^-1~.,
#                               data = sampled_dat,
#                               num.trees = n,
#                               mtry = m,
#                               min.node.size = mns,
#                               importance = "impurity",
#                               splitrule = 'variance',
#                               respect.unordered.factors = 'order')
#            new_row <- data.frame('num.trees'=n,
#                                  'mtry'=m,
#                                  'min.node.size'=mns,
#                                  'r-squared'=rgd.aiwc$r.squared,
#                                  'predicted_error'=rgd.aiwc$prediction.error,
#                                  'cor'=cor(rgd.aiwc$predictions,sampled_dat$kernel_time,use = "complete.obs"))
#            print(new_row)
#            tiny_grid <- rbind(tiny_grid, new_row)
#        }
#    }
#}

#tiny_grid
load('exhaustive_grid_search_310.Rdf')

#pdf('min_node_size_vs_r_squared_on_310_num_trees.pdf')
#p <- ggplot(data=tiny_grid,aes(x=min.node.size,y=r.squared,colour=mtry)) + geom_line() + geom_point()
#print(p)
#dev.off()

#> which.min(tiny_grid$predicted_error)
#[1] 1156
#> which.max(tiny_grid$r.squared)
#[1] 1156

#select the top 5 models
#for(i in seq(1,5)){
#    indexed <- which.min(tiny_grid$predicted_error)
#    x <- tiny_grid[indexed,]
#    tiny_grid <- tiny_grid[-indexed,]
#    #NOTE: try different variance stabilising transforms -- anscombe log kernel time instead of (2*((kernel_time^-0.5)+(3/8)))^-1
#    rgd.aiwc <- ranger((2*((kernel_time^-0.5)+(3/8)))^-1~., 
#                       #log(kernel_time)~.,
#                       data = sampled_dat,
#                       num.trees = x$num.trees,
#                       mtry = x$mtry,
#                       min.node.size = x$min.node.size,
#                       importance = "impurity",
#                       splitrule = 'variance',
#                       respect.unordered.factors = 'order')
#
#    z <- data.frame(predicted=rgd.aiwc$predictions,
#                    actual=(2*((sampled_dat$kernel_time^-0.5)+(3/8)))^-1,
#                    #actual=log(sampled_dat$kernel_time),
#                    device=sampled_dat$device,
#                    size=as.numeric(sdat_size),
#                    kernel=sdat_kernel)
#
#    library(ggplot2)
#    pdf(paste('top_',i,'_predicted_error_per_size.pdf',sep=''))
#    g <- ggplot(data=z,aes(x=actual,y=predicted,colour=size)) + geom_point()
#    print(g)
#    dev.off()
#
#    pdf(paste('top_',i,'_predicted_error_per_device.pdf',sep=''))
#    g <- ggplot(data=z,aes(x=actual,y=predicted,colour=device)) + geom_point()
#    print(g)
#    dev.off()
#
#    pdf(paste('top_',i,'_predicted_error_per_kernel.pdf',sep=''))
#    g <- ggplot(data=z,aes(x=actual,y=predicted,colour=kernel)) + geom_point()
#    print(g)
#    dev.off()
#}

#indexed <- which.min(tiny_grid$predicted_error)
#x <- tiny_grid[indexed,]
##NOTE: try different variance stabilising transforms -- anscombe log kernel time instead of (2*((kernel_time^-0.5)+(3/8)))^-1
#rgd.aiwc <- ranger(#(2*((kernel_time^-0.5)+(3/8)))^-1~., 
#                   log(kernel_time)~.,
#                   data = sampled_dat,
#                   num.trees = x$num.trees,
#                   mtry = x$mtry,
#                   min.node.size = x$min.node.size,
#                   importance = "impurity",
#                   splitrule = 'variance',
#                   respect.unordered.factors = 'order')
#
#z <- data.frame(predicted=rgd.aiwc$predictions,
#                #actual=(2*((sampled_dat$kernel_time^-0.5)+(3/8)))^-1,
#                actual=log(sampled_dat$kernel_time),
#                device=sampled_dat$device,
#                size=as.numeric(sdat_size),
#                kernel=sdat_kernel)
#
#library(ggplot2)
#pdf('sans_hmm_predicted_error_per_size.pdf')
#g <- ggplot(data=z,aes(x=actual,y=predicted,colour=kernel)) + geom_point()
#print(g)
#dev.off()

library(optimization)
prediction_wrapper_function <- function(x){
    pwf.num.trees <- round(x[1])
    pwf.mtry <- round(x[2])
    pwf.min.node.size <- round(x[3])

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

out <- optim_sa(fun=prediction_wrapper_function,
                start=c(runif(1,min=1,max=10000),
                        runif(1,min=1,max=34),
                        runif(1,min=1,max=50)),
                lower=c(1    ,1 ,1 ),
                upper=c(10000,34,50),
                control=list(nlimit=10,
                             maxgood=10),
                trace=TRUE)

#Flexible Optimization With Simulated Annealing
load('optimised_search_log.Rdf')
out <- optimised_result

pdf('random_search_optimisation_improvement.pdf')
plot(out)
dev.off()

#course_grained_optimisation resulted in:
#1373   30    9
rgd.aiwc <- ranger(#(2*((kernel_time^-0.5)+(3/8)))^-1~., 
                   log(kernel_time)~.,
                   data = sampled_dat,
                   num.trees = 1373,
                   mtry = 30,
                   min.node.size = 9,
                   importance = "impurity",
                   splitrule = 'variance',
                   respect.unordered.factors = 'order')

z <- data.frame(predicted=rgd.aiwc$predictions,
                actual=log(sampled_dat$kernel_time),
                device=sampled_dat$device,
                size=as.numeric(sdat_size),
                kernel=sdat_kernel)
pdf('optimized_model.pdf')
g <- ggplot(data=z,aes(x=actual,y=predicted,colour=size)) + geom_point()
print(g)
dev.off()

out <- optim_sa(fun=prediction_wrapper_function,
                start=c(1373,
                        30,
                        9),
                lower=c(1000    ,1 ,1 ),
                upper=c(1500    ,34,50),
                trace=TRUE)

load('optimised_subsearch_log.Rdf')
out <- sub_search_1_out

pdf('optimised_subsearch_results.pdf')
plot(out)
dev.off()


simplified_prediction_wrapper_function <- function(x){
    pwf.num.trees <- round(x[1])
    pwf.mtry <- round(x[2])
    pwf.min.node.size <- 9

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
    #print(paste("trying",pwf.num.trees,'trees',
    #            pwf.mtry,'mtrys and',
    #            pwf.min.node.size,'min node size',
    #            "prediction error:",rgd.aiwc$prediction.error))
    return(rgd.aiwc$prediction.error)
}

out <- optim_sa(fun=simplified_prediction_wrapper_function,
                start=c(1373,
                        30),
                lower=c(1000    ,1 ),
                upper=c(1500    ,34),
                trace=TRUE)
# 1374 and 30
load(file='optimised_subsubsearch_log.Rdf') #into out

#TODO: generate this contour plot

super_simplified_prediction_wrapper_function <- function(x){
    pwf.num.trees <- 1374#round(x[1])
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

out <- optim_sa(fun=super_simplified_prediction_wrapper_function,
                start=c(25),
                lower=c(1),
                upper=c(50),
                trace=TRUE)
load("optimised_subsubsubsearch_log.Rdf")#into out


#my attempt to determine the control using the discrete parameter space

# Define vf
var_fun_int <- function (para_0, fun_length, rf, temp = NA) {
    print(paste("para 0 = ",para_0))
    ret_var_fun <- para_0 + sample.int(rf, fun_length, replace = TRUE) *
        ((rbinom(fun_length, 1, 0.5) * -2) + 1)
    return (ret_var_fun)
}

out <- optim_sa(fun=super_simplified_prediction_wrapper_function,
                start=c(25),
                lower=c(1),
                upper=c(50),
                control=list(t0=1.0,
                             nlimit=50,
                             r=0.1,
                             rf=3,
                             ac_acc = 0.01,
                             dyn_rf = TRUE,
                             vf = var_fun_int),
                trace=TRUE)

#test with 2 variables
simp_var_fun_int <- function (para_0, fun_length, rf, temp = NA) {
    ret_var_fun <- para_0 + sample.int(rf, fun_length, replace = TRUE) *
        ((rbinom(fun_length, 1, 0.5) * -2) + 1)
    return (ret_var_fun)
}

out <- optim_sa(fun=simplified_prediction_wrapper_function,
                start=c(9000,#1373,
                        25),#30),
                lower=c(1         ,1 ),
                upper=c(10000     ,34),
                control=list(t0=1.0,
                             nlimit=50,
                             t_min=0.001,
                             rf=c(100,1),
                             ac_acc = 0.01,
                             dyn_rf = TRUE,
                             vf = simp_var_fun_int),
                trace=TRUE)

#library(devtools)
#install_github("BeauJoh/fields")
library(fields)

x <- read.table('full_scan_random_sampled_heatmap.Rtable',header=TRUE, sep=" ")
y <- interp(x=x$mtry,y=x$num.trees,z=x$prediction.error,duplicate=TRUE,extrap=FALSE)

pdf("full_scan_random_sampled_heatmap.pdf")
image.plot(y,legend.lab="prediction.error",xlab="mtry",ylab="num.trees")
dev.off()

#The proposed optimiser for all models -- for split and fit -- just find the near optimum min.node.size
out <- optim_sa(fun=prediction_wrapper_function,
                start=c(500,#1373,
                        32,#30),
                        9),
                lower=c(1         ,1 ,1 ),
                upper=c(10000     ,34,50),
                control=list(t0=1.0,
                             nlimit=50,
                             t_min=0.001,
                             rf=c(10,1,1),
                             ac_acc = 0.01,
                             dyn_rf = TRUE,
                             vf = simp_var_fun_int),
                trace=TRUE)

#> out$par
#[1] 465  31  13

