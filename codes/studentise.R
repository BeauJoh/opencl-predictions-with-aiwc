source('../analysis_tools/numerical_summary.R')
source('../analysis_tools/load_aiwc_dataframes.R')

featdata.all <- rbind(featdata.kmeans,featdata.lud)
featdata.all <- rbind(featdata.all,featdata.csr)
featdata.all <- rbind(featdata.all,featdata.fft)
featdata.all <- rbind(featdata.all,featdata.gem)

#studentise the data
pca_dat <- reorder_features(featdata.all)

pca_dat$opcode <- scale(pca_dat$opcode,scale=TRUE)[,1]
pca_dat$workitems <- scale(pca_dat$workitems,scale=TRUE)[,1]
pca_dat$total_barriers_hit <- scale(pca_dat$total_barriers_hit,scale=TRUE)[,1]
pca_dat$min_instructions_to_barrier <- scale(pca_dat$min_instructions_to_barrier,scale=TRUE)[,1]
pca_dat$max_instructions_to_barrier <- scale(pca_dat$max_instructions_to_barrier,scale=TRUE)[,1]
pca_dat$median_instructions_to_barrier <- scale(pca_dat$median_instructions_to_barrier,scale=TRUE)[,1]
pca_dat$max_simd_width <- scale(pca_dat$max_simd_width,scale=TRUE)[,1]
pca_dat$mean_simd_width <- scale(pca_dat$mean_simd_width,scale=TRUE)[,1]
pca_dat$stddev_simd_width <- scale(pca_dat$stddev_simd_width,scale=TRUE)[,1]
pca_dat$total_memory_footprint <- scale(pca_dat$total_memory_footprint,scale=TRUE)[,1]
pca_dat$ninety_percent_memory_footprint <- scale(pca_dat$ninety_percent_memory_footprint,scale=TRUE)[,1]
pca_dat$global_memory_address_entropy <- scale(pca_dat$global_memory_address_entropy,scale=TRUE)[,1]
pca_dat$local_memory_address_entropy_1 <- scale(pca_dat$local_memory_address_entropy_1,scale=TRUE)[,1]
pca_dat$local_memory_address_entropy_2 <- scale(pca_dat$local_memory_address_entropy_2,scale=TRUE)[,1]
pca_dat$local_memory_address_entropy_3 <- scale(pca_dat$local_memory_address_entropy_3,scale=TRUE)[,1]
pca_dat$local_memory_address_entropy_4 <- scale(pca_dat$local_memory_address_entropy_4,scale=TRUE)[,1]
pca_dat$local_memory_address_entropy_5 <- scale(pca_dat$local_memory_address_entropy_5,scale=TRUE)[,1]
pca_dat$local_memory_address_entropy_6 <- scale(pca_dat$local_memory_address_entropy_6,scale=TRUE)[,1]
pca_dat$local_memory_address_entropy_7 <- scale(pca_dat$local_memory_address_entropy_7,scale=TRUE)[,1]
pca_dat$local_memory_address_entropy_8 <- scale(pca_dat$local_memory_address_entropy_8,scale=TRUE)[,1]
pca_dat$local_memory_address_entropy_9 <- scale(pca_dat$local_memory_address_entropy_9,scale=TRUE)[,1]
pca_dat$local_memory_address_entropy_10 <- scale(pca_dat$local_memory_address_entropy_10,scale=TRUE)[,1]
pca_dat$total_unique_branch_instructions <- scale(pca_dat$total_unique_branch_instructions,scale=TRUE)[,1]
pca_dat$ninety_percent_branch_instructions <- scale(pca_dat$ninety_percent_branch_instructions,scale=TRUE)[,1]
pca_dat$branch_entropy_yokota <- scale(pca_dat$branch_entropy_yokota,scale=TRUE)[,1]
pca_dat$branch_entropy_average_linear <- scale(pca_dat$branch_entropy_average_linear,scale=TRUE)[,1]

