
#source('../analysis_tools/load_aiwc_dataframes.R')

featdata_labels <- c("Opcode",
                     "Granularity",
                     "Barriers Per Instruction",
                     "Instructions Per Operand",
                     "Total Instruction Count",
                     "Workitems",
                     "Operand Sum",
                     "Total Barriers Hit",
                     "Min ITB",
                     "Max ITB",
                     "Median ITB",
                     "Max SIMD Width",
                     "Mean SIMD Width",
                     "SD SIMD Width",
                     "Total Memory Footprint",
                     "90\\% Memory Footprint",
                     "Global Memory Address Entropy",
                     "LMAE -- LSBs Skipped = 1",
                     "LMAE -- LSBs Skipped = 2",
                     "LMAE -- LSBs Skipped = 3",
                     "LMAE -- LSBs Skipped = 4",
                     "LMAE -- LSBs Skipped = 5",
                     "LMAE -- LSBs Skipped = 6",
                     "LMAE -- LSBs Skipped = 7",
                     "LMAE -- LSBs Skipped = 8",
                     "LMAE -- LSBs Skipped = 9",
                     "LMAE -- LSBs Skipped = 10",
                     "Total Unique Branch Instructions",
                     "90\\% Branch Instructions",
                     "Branch Entropy (Yokota)",
                     "Branch Entropy (Average Linear)")
#example usage:
#   reorder_and_subset(featdata=featdata.lud,size="tiny",kernel="lud_perimeter")
reorder_and_subset <- function(featdata,size,kernel){
    df <- featdata
    s <- size
    k <- kernel
    x <- data.frame(opcode = subset(df,
                                    size==s & kernel==k & metric=="opcode")$count,
                    granularity = subset(df,
                                    size==s & kernel==k & metric=="granularity")$count,
                    barriers_per_instruction = subset(df,
                                    size==s & kernel==k & metric=="barriers per instruction")$count,
                    instructions_per_operand = subset(df,
                                    size==s & kernel==k & metric=="instructions per operand")$count,
                    total_instruction_count = subset(df,
                                                     size==s & kernel==k & metric=="total instruction count")$count,
                    workitems = subset(df,
                                       size==s & kernel==k & metric=="workitems")$count,
                    operand_sum = subset(df,
                                         size==s & kernel==k & metric=="operand sum")$count,
                    total_barriers_hit = subset(df,
                                                size==s & kernel==k & metric=="total # of barriers hit")$count,
                    min_instructions_to_barrier = subset(df,
                                                         size==s & kernel==k & metric=="min instructions to barrier")$count,
                    max_instructions_to_barrier = subset(df,
                                                         size==s & kernel==k & metric=="max instructions to barrier")$count,
                    median_instructions_to_barrier = subset(df,
                                                            size==s & kernel==k & metric=="median instructions to barrier")$count,
                    max_simd_width = subset(df,
                                            size==s & kernel==k & metric=="max simd width")$count,
                    mean_simd_width = subset(df,
                                             size==s & kernel==k & metric=="mean simd width")$count,
                    stddev_simd_width = subset(df,
                                               size==s & kernel==k & metric=="stdev simd width")$count,
                    total_memory_footprint = subset(df,
                                                    size==s & kernel==k & metric=="total memory footprint")$count,
                    ninety_percent_memory_footprint = subset(df,
                                                             size==s & kernel==k & metric=="90% memory footprint")$count,
                    global_memory_address_entropy = subset(df,
                                                           size==s & kernel==k & metric=="global memory address entropy")$count,
                    local_memory_address_entropy_1 = subset(df,
                                                            size==s & kernel==k & metric=="local memory address entropy -- 1 LSBs skipped")$count,
                    local_memory_address_entropy_2 = subset(df,
                                                            size==s & kernel==k & metric=="local memory address entropy -- 2 LSBs skipped")$count,
                    local_memory_address_entropy_3 = subset(df,
                                                            size==s & kernel==k & metric=="local memory address entropy -- 3 LSBs skipped")$count,
                    local_memory_address_entropy_4 = subset(df,
                                                            size==s & kernel==k & metric=="local memory address entropy -- 4 LSBs skipped")$count,
                    local_memory_address_entropy_5 = subset(df,
                                                            size==s & kernel==k & metric=="local memory address entropy -- 5 LSBs skipped")$count,
                    local_memory_address_entropy_6 = subset(df,
                                                            size==s & kernel==k & metric=="local memory address entropy -- 6 LSBs skipped")$count,
                    local_memory_address_entropy_7 = subset(df,
                                                            size==s & kernel==k & metric=="local memory address entropy -- 7 LSBs skipped")$count,
                    local_memory_address_entropy_8 = subset(df,
                                                            size==s & kernel==k & metric=="local memory address entropy -- 8 LSBs skipped")$count,
                    local_memory_address_entropy_9 = subset(df,
                                                            size==s & kernel==k & metric=="local memory address entropy -- 9 LSBs skipped")$count,
                    local_memory_address_entropy_10 = subset(df,
                                                            size==s & kernel==k & metric=="local memory address entropy -- 10 LSBs skipped")$count,
                    total_unique_branch_instructions = subset(df,
                                                              size==s & kernel==k & metric=="total unique branch instructions")$count,
                    ninety_percent_branch_instructions = subset(df,
                                                                size==s & kernel==k & metric=="90% branch instructions")$count,
                    branch_entropy_yokota = subset(df,
                                                   size==s & kernel==k & metric=="branch entropy (yokota)")$count,
                    branch_entropy_average_linear = subset(df,
                                                           size==s & kernel==k & metric=="branch entropy (average linear)")$count)
    x[is.na(x)] <- 0
    return(x)
}

reorder_features <- function(featdata){
    df <- featdata
    x <- data.frame(opcode = subset(df,metric=="opcode")$count,
                    granularity = subset(df,metric=="granularity")$count,
                    barriers_per_instruction = subset(df,metric=="barriers per instruction")$count,
                    instructions_per_operand = subset(df,metric=="instructions per operand")$count,
                    total_instruction_count = subset(df,metric=="total instruction count")$count,
                    workitems = subset(df,metric=="workitems")$count,
                    operand_sum = subset(df, metric=="operand sum")$count,
                    total_barriers_hit = subset(df,metric=="total # of barriers hit")$count,
                    min_instructions_to_barrier = subset(df,metric=="min instructions to barrier")$count,
                    max_instructions_to_barrier = subset(df,metric=="max instructions to barrier")$count,
                    median_instructions_to_barrier = subset(df,metric=="median instructions to barrier")$count,
                    max_simd_width = subset(df,metric=="max simd width")$count,
                    mean_simd_width = subset(df,metric=="mean simd width")$count,
                    stddev_simd_width = subset(df,metric=="stdev simd width")$count,
                    total_memory_footprint = subset(df,metric=="total memory footprint")$count,
                    ninety_percent_memory_footprint = subset(df,metric=="90% memory footprint")$count,
                    global_memory_address_entropy = subset(df,metric=="global memory address entropy")$count,
                    local_memory_address_entropy_1 = subset(df,metric=="local memory address entropy -- 1 LSBs skipped")$count,
                    local_memory_address_entropy_2 = subset(df,metric=="local memory address entropy -- 2 LSBs skipped")$count,
                    local_memory_address_entropy_3 = subset(df,metric=="local memory address entropy -- 3 LSBs skipped")$count,
                    local_memory_address_entropy_4 = subset(df,metric=="local memory address entropy -- 4 LSBs skipped")$count,
                    local_memory_address_entropy_5 = subset(df,metric=="local memory address entropy -- 5 LSBs skipped")$count,
                    local_memory_address_entropy_6 = subset(df,metric=="local memory address entropy -- 6 LSBs skipped")$count,
                    local_memory_address_entropy_7 = subset(df,metric=="local memory address entropy -- 7 LSBs skipped")$count,
                    local_memory_address_entropy_8 = subset(df,metric=="local memory address entropy -- 8 LSBs skipped")$count,
                    local_memory_address_entropy_9 = subset(df,metric=="local memory address entropy -- 9 LSBs skipped")$count,
                    local_memory_address_entropy_10 = subset(df,metric=="local memory address entropy -- 10 LSBs skipped")$count,
                    total_unique_branch_instructions = subset(df,metric=="total unique branch instructions")$count,
                    ninety_percent_branch_instructions = subset(df,metric=="90% branch instructions")$count,
                    branch_entropy_yokota = subset(df,metric=="branch entropy (yokota)")$count,
                    branch_entropy_average_linear = subset(df,metric=="branch entropy (average linear)")$count,
                    kernel=subset(df,metric=="opcode")$kernel,
                    invocation=subset(df,metric=="opcode")$invocation,
                    size=subset(df,metric=="opcode")$size,
                    application=subset(df,metric=="opcode")$application)
    x[is.na(x)] <- 0
    return(x)
}

drop_metrics_for_simple_kiviat <- function(x){
    x <- subset(x,metric!="total instruction count")
    x <- subset(x,metric!="workitems")
    x <- subset(x,metric!="operand sum")
    x <- subset(x,metric!="total # of barriers hit")
    x <- subset(x,metric!="min instructions to barrier")
    x <- subset(x,metric!="max instructions to barrier")
    x <- subset(x,metric!="median instructions to barrier")
    x <- subset(x,metric!="max simd width")
    x <- subset(x,metric!="mean simd width")
    x <- subset(x,metric!="stdev simd width")
return(x)
}
