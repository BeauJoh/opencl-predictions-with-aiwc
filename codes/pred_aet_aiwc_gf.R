####### Prediction of Accelerator Execution Times using AIWC and Random Regession Forests (pred_aet_aiwc.r)
# v1.3
# 18/01/18
# B. Johnston, G.Falzon, J. Milthorpe

#purpose: to predict accelerator execution times using AIWC features and assess the resulting model fit, variable importance and prediction error

#requirements assumes R 3.3.3 for Mac OS with libraries ellipse, MASS (in-built), ranger and RColorBrewer installed

#key changes 1.1: size feature removed from predictors fro random forest model, Proportinal Odds Logistic Regression model added
#key changes 1.2: feature processing, rf model feature trimming, rf model parameter optimisation
#key changes 1.3: application and size features removed from predictors for random forest model

#Load Required Libraries
library(ellipse)
library(MASS)
library(ranger)
library(RColorBrewer)

#load the sampled dataframe
#load('./sampled_dat.Rda')

#load the full dataframe
#load('./full_dat.Rda')

#sampled_dat <- full_dat
sampled_dat <- train_dat

#copy dataframe
sampled_dat_cop <- sampled_dat

#examine data frame
print(str(sampled_dat))

#Exploratory Plots
#Brew Color Panel
aiwc_colors <- brewer.pal(10, "Spectral")
aiwc_colors <- colorRampPalette(aiwc_colors)(100)

#Not visually nice (yet) but informative of importance of qualitative factors to execution time performance
pdf("execution_time_vs_problem_size.pdf")
plot(y = sampled_dat$kernel_time, x = sampled_dat$size, main = "Execution time vs. problem size", xlab = "size", ylab = "execution time")
dev.off()

pdf("execution_time_vs_application.pdf")
plot(y = sampled_dat$kernel_time, x = sampled_dat$application, main = "Execution time vs. application", xlab = "application", ylab = "execution time")
dev.off()

pdf("execution_time_vs_device.pdf")
plot(y = sampled_dat$kernel_time, x = sampled_dat$device, main = "Execution time vs. device", xlab = "device", ylab = "execution time")
dev.off()

pdf("execution_time_vs_kernel.pdf")
plot(y = sampled_dat$kernel_time, x = sampled_dat$kernel, main = "Execution time vs. kernel", xlab = "kernel", ylab = "execution time")
dev.off()
#relationship between time and kernel type

pdf("execution_time_density_plot.pdf")
plot(density(sampled_dat$kernel_time), main = "Execution time density plot")
dev.off()
#long-tailed, minor modes potentially governed by different (above) qualitative factors


#remove size, application, kernel from dataframe
sdat_size = sampled_dat$size
sdat_kernel = sampled_dat$kernel
sampled_dat = subset(sampled_dat, select = -size)
sampled_dat = subset(sampled_dat, select = -application)
sampled_dat = subset(sampled_dat, select = -kernel)

##correlation ellipse plot 
pred_dat <- subset(sampled_dat, select = -kernel_time) #remove the time variable and form new dataframe
num_inds <- sapply(pred_dat, is.numeric) #get indices of numeric factors in data frame
pred_dat_num <- pred_dat[,num_inds] #subset the dataframe again to extract only numeric predictors
cor_pred_dat <- cor(pred_dat_num) #correlation between predictor variables
cor_ord <- order(cor_pred_dat[1,]) #order correlation matrix
pred_dat_num_ord <- cor_pred_dat[cor_ord,cor_ord] #order numeric predictor correlations according to cor_ord indices
pdf("correlation_matrix_1.pdf")
plotcorr(pred_dat_num_ord, col = aiwc_colors[pred_dat_num_ord*50 + 50], mar = c(1,1,1,1), main = "Correlation matrix of possible predictor variables for execution time")
dev.off()
#suggest add legend and reduce names of variables using substr()

pdf("correlation_matrix_2.pdf")
plotcorr(pred_dat_num_ord, numbers = TRUE, col = aiwc_colors[pred_dat_num_ord*50 + 50], mar = c(1,1,1,1), main = "Correlation matrix of possible predictor variables for execution time")
dev.off()

#manually typecast integer variables
int.inds <- c(2,6,7,8,9,10,11,12,13,16,17,29,30,34,37)

#standardise numeric variables
num.inds <- lapply(sampled_dat, is.numeric)
num.inds <- as.logical(num.inds)

for (i in seq(along = num.inds)){
			feature.name = names(sampled_dat[i])
			ifelse((any(i == int.inds) || num.inds[i] == 'FALSE' || feature.name == "kernel_time"), next, sampled_dat[i] <- scale(sampled_dat[i]))
								} #end i loop

#Random Forest Regression
rg.aiwc <- ranger(kernel_time~., data = sampled_dat, importance = "impurity", respect.unordered.factors = 'order') #fit ranger (RandomForests for large data sets), using node impurity metric for regression
print(rg.aiwc$r.squared)
print(rg.aiwc$prediction.error)
print(sort(rg.aiwc$variable.importance, decreasing = TRUE))
#order of relative importance of variables to the model fit

N <- length(sampled_dat$kernel_time) #how many samples?
holdout.ind <- rbinom(n = N, size = 1, prob = 0.5) #randomly generate binary indices for holdout vector

rg.aiwc.holdout <- ranger(kernel_time~., data = sampled_dat, importance = "permutation", respect.unordered.factors = 'order', case.weights = holdout.ind, holdout = TRUE)
#fit a ranger holdout model
rg.aiwc.ip <- importance_pvalues(rg.aiwc.holdout, method = "altmann", formula = kernel_time~., data = sampled_dat)
#now get p-values associated with variable importance using altmann method

print(rg.aiwc.ip)

m <- min(rg.aiwc.ip[,1] ) #get minimum of importance scores
M <- max(rg.aiwc.ip[,1] ) #get maximum of importance scores
R <- M-m #get range of importance scores
NIS <- (rg.aiwc.ip[,1]-m)/R #normalise importance scores
NIS <- sort(NIS) #sort NIS smallest to largest

op <- par(xaxs = 'i') 
dotchart(NIS, xlim = c(0,1)) #dotchart of normalised variable importance scores
par(op)


#compare predicted execution times to actual execution times
rg.aiwc.error <- rg.aiwc$predictions - sampled_dat$kernel_time
summary(rg.aiwc.error)

pdf("predicted_vs_actual_execution_times.pdf")
plot(y = rg.aiwc$predictions, x = sampled_dat$kernel_time, main = "Predicted vs. actual execution time for basic random forest model", ylab = "Predicted Execution Time", xlab = "Actual Execution Time", type = 'p', col = rainbow(5)[as.numeric(sdat_size)])
legend("bottomright", legend = unique(sdat_size), fill = rainbow(5))
dev.off()
#reasonable linear relationship although suggests model could be further improved. Note large sizes in lower right of plot (very long actual execution times but much smaller predicted execution times). The rf model needs to be investigated/improved for this major error (has consequences later). Also note 'large' size with very low execution time and predicted exection time, odd? This is another important source of error for the later logistic regression model. Similar manner for 'tiny' problem size but to a lesser extent.

pdf("predicted_error.pdf")
plot(y = rg.aiwc.error, x = sdat_size)
dev.off()
#error tends to increase with problem size but it is still reasonably symmetrical

### Now refine rf model


cut.list <- c('instructions_per_operand','max_simd_width','mean_simd_width','stddev_simd_width', 'invocation', 'run')

cut.inds <- vector('numeric', length(cut.list))
for (i in 1:length(cut.inds)){
						cut.inds[i] <- which(names(sampled_dat) == cut.list[i])
						}
						
red.df <- sampled_dat[-cut.inds]


rgd.aiwc <- ranger(kernel_time~., data = red.df, importance = "impurity", respect.unordered.factors = 'order')
#fit ranger (RandomForests for large data sets), using node impurity metric for regression on reduced data set
print(rgd.aiwc$r.squared)
print(rgd.aiwc$prediction.error)
print(sort(rgd.aiwc$variable.importance, decreasing = TRUE))

#compare predicted execution times to actual execution times
rgd.aiwc.error <- rgd.aiwc$predictions - red.df$kernel_time
summary(rgd.aiwc.error)
#note the major improvement being that the rf predictions are now unbiased

pdf('predicted_vs_execution_time_for_reduced_rfm.pdf')
plot(y = rgd.aiwc$predictions,x = red.df$kernel_time, main = "Predicted vs. actual execution time for reduced random forest model", ylab = "Predicted Execution Time", xlab = "Actual Execution Time", type = 'p', col = rainbow(5)[as.numeric(sdat_size)])
legend("bottomright", legend = unique(sdat_size), fill = rainbow(5))
dev.off()

#suggest tuning rf model on ntree, mtry, nodesize

#1000 trees
rgd.aiwc.1000 <- ranger(kernel_time~., data = red.df, num.trees = 1000, mtry = 5, importance = "impurity", respect.unordered.factors = 'order')
#fit ranger (RandomForests for large data sets), using node impurity metric for regression on reduced data set
print(rgd.aiwc.1000$r.squared)
#increasing number of trees unlikely to improve R-sq for this problem

rgd.aiwc.1001 <- ranger((2*((kernel_time^-0.5)+(3/8)))^-1~., data = red.df, num.trees = 1001, mtry = 28, min.node.size = 11, importance = "impurity", splitrule = 'variance', respect.unordered.factors = 'order')
#fit ranger (RandomForests for large data sets), using node impurity metric for regression on reduced data set
print(rgd.aiwc.1001$r.squared)
print(rgd.aiwc.1001$prediction.error)
print(sort(rgd.aiwc.1001$variable.importance, decreasing = TRUE))

pdf('predicted_vs_execution_time_for_optimised_rfm.pdf')
plot(y = rgd.aiwc.1001$predictions, x = (2*((red.df$kernel_time^-0.5)+(3/8)))^-1, main = "Predicted vs. actual execution time for optimized random forest model", ylab = "Predicted Execution Time", xlab = "Actual Execution Time", type = 'p', col = rainbow(5)[as.numeric(sdat_size)])
legend("bottomright", legend = unique(sdat_size), fill = rainbow(5))
dev.off()

z <- data.frame(predicted=rgd.aiwc.1001$predictions,actual=(2*((red.df$kernel_time^-0.5)+(3/8)))^-1,device=red.df$device,size=as.numeric(sdat_size),kernel=sdat_kernel)

#exhaustive grid search
#R-squared, numerical summary and out-of-bag error per iteration

library(ggplot2)
pdf('predicted_error_per_size.pdf')
ggplot(data=z,aes(x=actual,y=predicted,colour=size)) + geom_point()
dev.off()

pdf('predicted_error_per_device.pdf')
ggplot(data=z,aes(x=actual,y=predicted,colour=device)) + geom_point()
dev.off()

pdf('predicted_error_per_kernel.pdf')
ggplot(data=z,aes(x=actual,y=predicted,colour=kernel)) + geom_point()
dev.off()

#y$device <- 'knl'
#predict(rgd.aiwc.1001,type='response',data=y)$predictions
#probs.Size0 <- predict(stest.polr, type = 'p', data = test_dat)

#NOTE: 
#library(ggplot)
#for(k in unique())
#geom_point()
#
#
### Proportional Odds Logistic Regression to predict problem size using ranger rf model predicted execution time
##first a test: what happens in the ideal case where the ranger rf perfectly predicts the execution times?
#stest.df <- data.frame('Size' = sdat_size, 'acttime' = sampled_dat$kernel_time, 'app' = sampled_dat$application)
#stest.df$Size <- ordered(stest.df$Size) #specify that the levels of sdat_size are ordered e.g. Levels: tiny < small < medium < large
#
##m <- min(stest.df$acttime) #get minimum of acttime
##M <- max(stest.df$acttime) #get maximum of acttime
##R <- M-m #get range of acttime
##stest.df$acttime <- (stest.df$acttime-m)/R #normalise acttime
#
#mpt0 <- mean(stest.df$acttime)
#spt0 <- sd(stest.df$acttime)
#stest.df$acttime <- (stest.df$acttime - mpt0)/spt0 #studentise prediction times
#
#stest.polr <- polr(Size~acttime+app, data = stest.df, method = 'logistic', start = runif(8), Hess = TRUE) #fit ordered logit model
##note: if get fitting error in optim, attempt re-fit again will eventually find suitable starting parameters
#summary(stest.polr)
#
#
##determine estimated problem size using model
#probs.Size0 <- predict(stest.polr, type = 'p', data = stest.df)
#
#pred.Size0 = vector('numeric', length = dim(probs.Size0)[1])
#for (i in 1:dim(probs.Size0)[1]){
#				pred.Size0[i] <- which.max(probs.Size0[i,])
#											} # end i loop
#											
#NSize0 <- as.numeric(stest.df$Size) # typecast Size into a numeric vector
#
#pred.Size0.error <- NSize0-pred.Size0 #compare error of prediction for problem size
#
#H.pred.error0 <- hist(pred.Size0.error, breaks = seq(-3,3,by = 1), right = TRUE, plot = FALSE)
#print(H.pred.error0)
#Counts0 = H.pred.error0$counts
#Mag0 = H.pred.error0$breaks[2:length(H.pred.error0$breaks)]
#pred.error.counts0 <- cbind(Counts0,Mag0)
#print(pred.error.counts0)
##Counts0 Mag0
##[1,]     240   -2
##[2,]     358   -1
##[3,]    1871    0
##[4,]     971    1
##[5,]       0    2
##[6,]       0    3
#
##execution time by itself is not the best indicator (average indicator) of problem size
#(1871)/dim(probs.Size0)[1]
##0.5438953 at actual problem size
#(1871+971+358)/dim(probs.Size0)[1]
##0.9302326 within +/- 1 of actual size
#
##predicted execution times
#
#size.df <- data.frame('Size' = sdat_size, 'predtime' = rg.aiwc$predictions, 'app' = sampled_dat$application, 'dev' = sampled_dat$device)
#size.df$Size <- ordered(size.df$Size) #specify that the levels of sdat_size are ordered e.g. Levels: tiny < small < medium < large
#mpt <- mean(size.df$predtime)
#spt <- sd(size.df$predtime)
#size.df$predtime <- (size.df$predtime - mpt)/spt #studentise prediction times
#
#size.polr <- polr(Size~predtime+app, data = size.df, method = 'logistic', Hess = TRUE) #fit ordered logit model
#summary(size.polr)
##Call:
##polr(formula = Size ~ predtime + app, data = size.df, Hess = TRUE, 
##    method = "logistic")
#
##Coefficients:
##            Value Std. Error t value
##predtime  3.89986    0.12484 31.2387
##applud    0.04276    0.08974  0.4765
##appgem   -0.74344    0.16293 -4.5629
##appfft    1.85940    0.11763 15.8075
##appcsr    1.90874    0.14420 13.2364
#
##Intercepts:
##             Value    Std. Error t value 
##tiny|small    -2.0932   0.0877   -23.8642
##small|medium  -0.4577   0.0814    -5.6233
##medium|large   1.8335   0.0895    20.4819
#
##Residual Deviance: 6721.094 
##AIC: 6737.094 
#
##We see that predtime is a highly statistically significant predictor of Size t = 31.2387
## Deviance suggests considerable errors in predictions
#
##Get p-value values using large sample approximation to normal distribution
#ctable <- coef(summary(size.polr))
#pvals <- pnorm(abs(ctable[,"t value"]), lower.tail = FALSE)*2
#ctable <- cbind(ctable, "p value" = pvals)
#print(ctable)
#
## Value Std. Error     t value       p value
##predtime      3.8998614 0.12484058  31.2387317 3.175801e-214
##applud        0.0427566 0.08973581   0.4764719  6.337382e-01
##appgem       -0.7434425 0.16293184  -4.5629049  5.045068e-06
##appfft        1.8593975 0.11762730  15.8075346  2.760605e-56
##appcsr        1.9087392 0.14420394  13.2363874  5.408858e-40
##tiny|small   -2.0932325 0.08771424 -23.8642271 7.207588e-126
##small|medium -0.4577045 0.08139361  -5.6233469  1.872927e-08
##medium|large  1.8335490 0.08952049  20.4818925  3.122867e-93
#
##lots of very small p-values indicating statistical signficance
##note the cut-point coefficients (transition thresholds) between Sizes (on log scale)
#
#ci <- confint(size.polr) #95% Confidence Interval for predtime coefficient using profiling
#print(ci)
##  2.5 %     97.5 %
##predtime  3.6588156  4.1481542
##applud   -0.1329089  0.2189100
##appgem   -1.0658945 -0.4266659
##appfft    1.6297064  2.0908643
##appcsr    1.6271897  2.1925774
##those which don't overlap zero, further evidence of statistically significant effect
#
##get odds ratios
#OR <- exp(cbind(OR = coef(size.polr),ci))
#print(OR)
##  OR      2.5 %     97.5 %
##predtime 49.3956047 38.8153412 63.3170223
##applud    1.0436838  0.8755448  1.2447193
##appgem    0.4754743  0.3444196  0.6526816
##appfft    6.4198679  5.1023765  8.0919059
##appcsr    6.7445802  5.0895516  8.9582727
##for every one unit increase in studentised prediction time, it is 38.81 times more likely that Size is 'small' instead of 'tiny' and so forth.
#
#fitted.Size <- size.polr$fitted.values #get fitted values of model e.g. cumulative probabilities
#probs.Size <- predict(size.polr, type = 'p', data = size.df)
#
#cutpoints <- size.polr$zeta
#print(cutpoints)
## tiny|small small|medium medium|large 
##  -2.0932325   -0.4577045    1.8335490 
#  
#size.polr.ll <- logLik(size.polr)
#size.polr.cll <- logLik(update(size.polr, .~1))
#McFR2 <- 1 - (size.polr.ll[1]/size.polr.cll[1])
#print(McFR2)
## 0.294894
##indicates not very good predictive model, but needs to further assessment to determine if it is sufficient for our needs
#
##determine estimated problem size using model
#pred.Size = vector('numeric', length = dim(probs.Size)[1])
#for (i in 1:dim(probs.Size)[1]){
#				pred.Size[i] <- which.max(probs.Size[i,])
#											} # end i loop
#											
#NSize <- as.numeric(size.df$Size) # typecast Size into a numeric vector
#
#pred.Size.error <- NSize-pred.Size #compare error of prediction for problem size
#
##-2: actual problem size two levels smaller than predicted problem size
##-1: actual problem size one level smaller than predicted problem size
##0: actual problem size same as predicted problem size
##1: actual problem size one level greater than predicted problem size
##2: actual problem size two levels greater than predicted problem size
##3: actual problem size three levels greater than predicted problem size
#
#										
#H.pred.error <- hist(pred.Size.error, breaks = seq(-3,3,by = 1), right = TRUE, plot = FALSE)
#print(H.pred.error)
##observe H.pred.error$counts, this is number of predictions with error in magnitude given by interval in H.pred.error$breaks. Since right = TRUE, the intervals are of the form (a,b]. This means e.g. counts = 80 189 2023 and breaks = -3 -2 -1  has 80 predictions with error in interval (-3,-2], 189 predictions in interval (-2, -1] and 2023 predictions in the interval (-1, 0]. Noting that the error differences can only be integers, this means each count corresponds to the right-side closed boundary e.g. 80 prediction with magnitude -2, 189 predictions with magnitude -1 and 2023 predictions with magnitude 0. ))
##thus
#Counts = H.pred.error$counts
#Mag = H.pred.error$breaks[2:length(H.pred.error$breaks)]
#pred.error.counts <- cbind(Counts,Mag)
#print(pred.error.counts)
##Counts Mag
##[1,]    319  -2
##[2,]    405  -1
##[3,]   1609   0
##[4,]   1107   1
##[5,]      0   2
##[6,]      0   3
#
#1609/dim(probs.Size)[1]
##[1] 0.4677326 approx 47% of size predictions were correct
#(1609+1107+405)/dim(probs.Size)[1]
##[1] 0.9072674 approx 90% of size predictions were correct or within the next smallest or largest size
#
