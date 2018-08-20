source('../analysis_tools/load_runtime_data.R')
source('../analysis_tools/load_aiwc_dataframes.R')
source('../analysis_tools/studentise.R')

if (!exists("comb_dat")){
    comb_dat <- merge(rundata.all,pca_dat,by=c("application","size"))
    comb_dat[is.na(comb_dat)] <- 0 #replacing any NA encountered -- one of the entropy computations may do this!
}

## 75% of the sample size
smp_size <- floor(0.75 * nrow(comb_dat))
## set the seed to make your partition reproducible
set.seed(123)
train_ind <- sample(seq_len(nrow(comb_dat)), size = smp_size)

train_dat <- comb_dat[train_ind, ]
test_dat <- comb_dat[-train_ind, ]

#Ask Greg: what about a linear model per device?

library('VGAM')

fit <- vglm(formula= time ~ #cbind(factor(device)) ~ #opcode +
                                     #workitems +
                                     total_memory_footprint +
                                     #ninety_percent_memory_footprint +
                                     #global_memory_address_entropy +
                                     local_memory_address_entropy_1 +
                                     #local_memory_address_entropy_2 +
                                     #local_memory_address_entropy_3 +
                                     #local_memory_address_entropy_4 +
                                     #local_memory_address_entropy_5 +
                                     #local_memory_address_entropy_6 +
                                     #local_memory_address_entropy_7 +
                                     #local_memory_address_entropy_8 +
                                     #local_memory_address_entropy_9 +
                                     #local_memory_address_entropy_10 +
                                     #total_unique_branch_instructions +
                                     #ninety_percent_branch_instructions +
                                     #branch_entropy_yokota +
                                     branch_entropy_average_linear,
            data=train_dat,
            family=multinomial)
#predict response
#vglm

