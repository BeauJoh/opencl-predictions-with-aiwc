
rundata.energy <- data.frame()
rundata.cache <- data.frame()

#source('../analysis_tools/load_runtime_data.R')
#source('../analysis_tools/load_aiwc_dataframes.R')
#load('../data/intermediate/big_run.Rdf')
load('../data/intermediate/full_run.Rdf')
load('../data/intermediate/big_feat.Rdf')

source('../codes/restructure_aiwc_data.R')
full_dat <- data.frame()
#test set size
smp_size <- 10
#set.seed(123)#commented out for reproducible sampling

#featdata.all <- featdata.kmeans
#featdata.all <- rbind(featdata.all, featdata.lud)
#featdata.all <- rbind(featdata.all, featdata.dwt)
#featdata.all <- rbind(featdata.all, featdata.gem)
#featdata.all <- rbind(featdata.all, featdata.fft)
#featdata.all <- rbind(featdata.all, featdata.csr)
#featdata.all <- rbind(featdata.all, featdata.srad)

#rename kernel names in rundata to match featdata form
x <- rundata.all
x$kernel <- as.character(x$kernel)

#dropping n-queens since aiwc crashes during collection
x <- subset(x,application != 'nqueens')

#NOTE: fft main kernel triggers which sub-kernel is run and thus individual sub-kernels cannot be measured on the host-side be LSB, as such the same total times are all copied/repeated.
y <- x[x$kernel=="fft_kernel",]
y$kernel <- 'fft16_kernel'
x <- rbind(x,y)
y$kernel <- 'fft8_kernel'
x <- rbind(x,y)
y$kernel <- 'fft4_kernel'
x <- rbind(x,y)
remove(y)

#renames take the following format:
#"invert_mapping"                 <-    device_side_buffer_setup (just for kmeans application)
#"kmeansPoint"                    <-    kmeans_kernel
#"calc_potential_single_step_dev" <-    gem_kernel
#"lud_diagonal"                   <-    diagonal_kernel
#"lud_internal"                   <-    internal_kernel
#"lud_perimeter"                  <-    perimeter_kernel
#"c_CopySrcToComponents"          <-    c_CopySrcToComponents_kernel
#"cl_fdwt53Kernel"                <-    kl_fdwt53Kernel_kernel
#"fftRadix16Kernel"               <-    fft_kernel
#"fftRadix8Kernel"                <-    fft_kernel
#"fftRadix4Kernel"                <-    fft_kernel
#"fftRadix2Kernel"                <-    fft_kernel
#"csr"                            <-    csr_kernel
#"srad_cuda_1"                    <-    srad1_kernel
#"srad_cuda_2"                    <-    srad2_kernel

x$kernel[x$kernel == "device_side_buffer_setup"    ] <- "invert_mapping"
x$kernel[x$kernel == "kmeans_kernel"               ] <- "kmeansPoint"
x$kernel[x$kernel == "gem_kernel"                  ] <- "calc_potential_single_step_dev"
x$kernel[x$kernel == "diagonal_kernel"             ] <- "lud_diagonal"
x$kernel[x$kernel == "internal_kernel"             ] <- "lud_internal"
x$kernel[x$kernel == "perimeter_kernel"            ] <- "lud_perimeter"
x$kernel[x$kernel == "c_CopySrcToComponents_kernel"] <- "c_CopySrcToComponents"
x$kernel[x$kernel == "kl_fdwt53Kernel_kernel"      ] <- "cl_fdwt53Kernel"
x$kernel[x$kernel == "fft16_kernel"                ] <- "fftRadix16Kernel"
x$kernel[x$kernel == "fft8_kernel"                 ] <- "fftRadix8Kernel"
x$kernel[x$kernel == "fft4_kernel"                 ] <- "fftRadix4Kernel"
x$kernel[x$kernel == "fft_kernel"                  ] <- "fftRadix2Kernel"
x$kernel[x$kernel == "csr_kernel"                  ] <- "csr"
x$kernel[x$kernel == "srad1_kernel"                ] <- "srad_cuda_1"
x$kernel[x$kernel == "srad2_kernel"                ] <- "srad_cuda_2"
#bfs
x$kernel[x$kernel == "kernel1_kernel"              ] <- "kernel1"
x$kernel[x$kernel == "kernel2_kernel"              ] <- "kernel2"
#hmm
x$kernel[x$kernel == "_cl_kernel_acc_b_dev_kernel" ] <- "acc_b_dev"
x$kernel[x$kernel == "_cl_kernel_calc_alpha_dev_kernel"] <- "calc_alpha_dev"
x$kernel[x$kernel == "_cl_kernel_calc_beta_dev_kernel"] <- "calc_beta_dev"
x$kernel[x$kernel == "_cl_kernel_calc_gamma_dev_kernel"] <- "calc_gamma_dev"
x$kernel[x$kernel == "_cl_kernel_calc_xi_dev_kernel"] <- "calc_xi_dev"
x$kernel[x$kernel == "_cl_kernel_est_a_dev_kernel"] <- "est_a_dev"
x$kernel[x$kernel == "_cl_kernel_est_b_dev_kernel"] <- "est_b_dev"
x$kernel[x$kernel == "_cl_kernel_est_pi_dev_kernel"] <- "est_pi_dev"
x$kernel[x$kernel == "_cl_kernel_init_alpha_dev_kernel"] <- "init_alpha_dev"
x$kernel[x$kernel == "_cl_kernel_init_beta_dev_kernel"] <- "init_beta_dev"
x$kernel[x$kernel == "_cl_kernel_init_ones_dev_kernel"] <- "init_ones_dev"
x$kernel[x$kernel == "_cl_kernel_sgemvn_kernel_naive_kernel"] <- "mvm_non_kernel_naive"
x$kernel[x$kernel == "_cl_kernel_sgemvt_kernel_naive_kernel"] <- "mvm_trans_kernel_naive"
x$kernel[x$kernel == "_cl_kernel_scale_a_dev_kernel"] <- "scale_a_dev"
x$kernel[x$kernel == "_cl_kernel_scale_alpha_dev_kernel"] <- "scale_alpha_dev"
x$kernel[x$kernel == "__cl_kernel_scale_alpha_dev_kernel"] <- "scale_alpha_dev"
x$kernel[x$kernel == "_cl_kernel_scale_b_dev_kernel"] <- "scale_b_dev"
x$kernel[x$kernel == "__cl_kernel_s_dot_kernel_naive_kernel"] <- "s_dot_kernel_naive"
#nw
x$kernel[x$kernel == "clKernel_nw1_kernel"         ] <- "needle_opencl_shared_1" 
x$kernel[x$kernel == "clKernel_nw2_kernel"         ] <- "needle_opencl_shared_2"
#crc
x$kernel[x$kernel == "kernel_compute_kernel"       ] <- "crc32_slice8"

x$kernel <- as.factor(x$kernel)
rundata.redux <- x

##reduce by summation over featdata to remove invocation
#featdata.redux <- aggregate(featdata.all$count,by=list(metric=featdata.all$metric,
#                                                       application=featdata.all$application,
#                                                       kernel=featdata.all$kernel,
#                                                       size=featdata.all$size),
#                            FUN=sum)
#featdata.redux <- rename(featdata.redux,c('x'='count'))

test_dat <- data.frame()
train_dat <- data.frame()
for (a in unique(featdata.all$application)){
    for (s in unique(featdata.all$size)){
        for (k in unique(featdata.all$kernel)){
            j <- subset(featdata.all, application == a & size == s & kernel == k)
            j <- reorder_features(j)
            j <- j[1,]

            for (d in unique(rundata.redux$device)){
                z <- subset(rundata.redux, device == d & application == a & size == s & kernel == k)
                if (nrow(z) == 0){
                    print(paste("Warning: Dataframe is empty! Skipping: device",d,"application",a,"size",s,"and kernel",k))
                    next
                }

                #full dataset:
                sampled_indices <- seq_len(nrow(z))
                sample <- z[sampled_indices,]
                full_dat <-  rbind(test_dat,merge(j,sample,by=c("application","size","kernel")))

                #sub-sampled dataset:
                sampled_indices <- sample(seq_len(nrow(z)), size = smp_size)
                sample <- z[-sampled_indices, ]

                test_dat <- rbind(test_dat,merge(j,sample,by=c("application","size","kernel")))
                sample <- z[sampled_indices, ]
                train_dat <- rbind(train_dat,merge(j,sample,by=c("application","size","kernel")))

                #comb_dat[is.na(comb_dat)] <- 0 #replacing any NA encountered -- one of the entropy computations may do this!
            }
    }
    }
}

save(test_dat, file="test_dat.Rda")
save(train_dat, file="train_dat.Rda")

#sampled dataset:
#sampled_dat <- comb_dat
#save(sampled_dat, file="sampled_dat.Rda")

#full dataset:
#full_dat <- comb_dat
save(full_dat, file="full_dat.Rda")

#load("sampled_dat.Rda")
