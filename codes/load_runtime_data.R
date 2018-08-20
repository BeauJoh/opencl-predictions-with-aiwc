
source("../analysis_tools/libscibench_utils/utils.R")
source("../analysis_tools/libscibench_utils/stats.R")
source("../analysis_tools/libscibench_utils/aes.R")
source("../analysis_tools/libscibench_utils/functions.R")

devices <- c('xeon_es-2697v2','i7-6700k','titanx','gtx1080','gtx1080ti','k20c','k40c','knl')#,'firepro_s9150')
sizes <- c('tiny','small','medium','large')
#load data if it doesn't exist in this environment
#to force a reload:
#remove(data.kmeans)

SumPerRunReduction <- function(x){
    z <- data.frame()
    for (y in unique(x$run)){
        z <- rbind(z,data.frame('time'=sum(x[x$run == y,]$time),'run'=y))
    }
    return(z)
}

#here region of interest is typically the selected kernels
SumPerRunPerROIReduction <- function(x,roi){
    z <- data.frame()
    for (y in unique(x$run)){
        tt <- sum(x[x$run == y,]$time)
        for(k in roi){
            z <- rbind(z,data.frame("kernel"=k,"time_contributed"=sum(x[x$run == y & x$region == k,]$time),"total_time"=tt,'run'=y))
        }
    }
    return(z)
}

if (!exists("rundata.kmeans")){
    rundata.kmeans <- data.frame()
    columns <- c('region','number_of_objects','number_of_features','iteration_number_hint_until_convergence','id','time','overhead')
    for(device in devices){
        for(size in sizes){
            path = paste("../data/time_data/",device,"_kmeans_",size,"_time.0/",sep='')
            print(paste("loading:",path))
            x <- ReadAllFilesInDir.AggregateWithRunIndex(dir.path=path,col=columns)
            x$device <- device
            x$size <- size
            rundata.kmeans <- rbind(rundata.kmeans, x)
        }
    }
}

if(!exists("rundata.lud")){
    rundata.lud <- data.frame()
    columns <- c('region','matrix_dimension','id','time','overhead')
    for(device in devices){
        for(size in sizes){
            path = paste("../data/time_data/",device,"_lud_",size,"_time.0/",sep='')
            print(paste("loading:",path))
            x <- ReadAllFilesInDir.AggregateWithRunIndex(dir.path=path,col=columns)
            x$device <- device
            x$size <- size
            rundata.lud <- rbind(rundata.lud, x)
        }
    }
}

if(!exists("rundata.csr")){
    rundata.csr <- data.frame()
    columns <- c('region','number_of_matrices','workgroup_size','execution_number','id','time','overhead')
    for(device in devices){
        for(size in sizes){
            path = paste("../data/time_data/",device,"_csr_",size,"_time.0/",sep='')
            print(paste("loading:",path))
            #SeparateAllNAsInFilesInDir(dir.path=path) 
            x <- ReadAllFilesInDir.AggregateWithRunIndex(dir.path=path,col=columns)
            x$device <- device
            x$size <- size
            rundata.csr <- rbind(rundata.csr, x)
        }
    }
}

if(!exists("rundata.fft")){
    rundata.fft <- data.frame()
    columns <- c('signal_length','region','id','time','overhead')
    for(device in devices){
        for(size in sizes){
            path = paste("../data/time_data/",device,"_openclfft_",size,"_time.0/",sep='')
            print(paste("loading:",path))
            x <- ReadAllFilesInDir.AggregateWithRunIndex(dir.path=path,col=columns)
            x$device <- device
            x$size <- size
            rundata.fft <- rbind(rundata.fft, x)
        }
    }
}

if(!exists("rundata.dwt")){
    rundata.dwt <- data.frame()
    columns <- c('region','dwt_level','id','time','overhead')
    for(device in devices){
        for(size in sizes){
            path = paste("../data/time_data/",device,"_dwt2d_",size,"_time.0/",sep='')
            print(paste("loading:",path))
            x <- ReadAllFilesInDir.AggregateWithRunIndex(dir.path=path,col=columns)
            x$device <- device
            x$size <- size
            rundata.dwt <- rbind(rundata.dwt, x)
        }
    }
}

if(!exists("rundata.gem")){
    rundata.gem <- data.frame()
    columns <- c('number_of_residues','number_of_vertices','region','id','time','overhead')
    for(device in devices){
        for(size in sizes){
            path = paste("../data/time_data/",device,"_gem_",size,"_time.0/",sep='')
            print(paste("loading:",path))
            x <- ReadAllFilesInDir.AggregateWithRunIndex(dir.path=path,col=columns)
            x$device <- device
            x$size <- size
            rundata.gem <- rbind(rundata.gem, x)
        }
    }
}

if(!exists("rundata.srad")){
    rundata.srad <- data.frame()
    columns <- c('region','id','time','overhead')
    for(device in devices){
        for(size in sizes){
            path = paste("../data/time_data/",device,"_srad_",size,"_time.0/",sep='')
            print(paste("loading:",path))
            x <- ReadAllFilesInDir.AggregateWithRunIndex(dir.path=path,col=columns)
            x$device <- device
            x$size <- size
            rundata.srad <- rbind(rundata.srad, x)
        }
    }
}

if(!exists("rundata.crc")){
    rundata.crc <- data.frame()
    columns <- c('number_of_pages','page_size','region','id','time','overhead')
    for(device in devices){
        for(size in sizes){
            path = paste("../data/time_data/",device,"_crc_",size,"_time.0/",sep='')
            print(paste("loading:",path))
            x <- ReadAllFilesInDir.AggregateWithRunIndex(dir.path=path,col=columns)
            x$device <- device
            x$size <- size
            rundata.crc <- rbind(rundata.crc, x)
        }
    }
}

if (!exists("rundata.all")){
    rundata.all <- data.frame()
    print("munging data...")
    ##parse kmeans
    print("munging kmeans data...")
    for(d in devices){
        for(s in sizes){
            x <- subset(rundata.kmeans, device == d & size == s)
            x <- SumPerRunPerROIReduction(x,c('kmeans_kernel','device_side_buffer_setup'))
            rundata.all <- rbind(rundata.all,data.frame('application'='kmeans',
                                                        'device'=d,
                                                        'size'=s,
                                                        'total_time'=x$total_time,
                                                        'kernel_time'=x$time_contributed,
                                                        'kernel'=x$kernel,
                                                      # 'invocation'=x$iteration_number_hint_until_convergence,
                                                        'run'=x$run))
        }
    }
    print("done.")
    #munge lud
    print("munging lud data...")
    for(d in devices){
        for(s in sizes){
            x <- subset(rundata.lud,device == d & size == s)
            x <- SumPerRunPerROIReduction(x,c('diagonal_kernel','perimeter_kernel','internal_kernel'))
            rundata.all <- rbind(rundata.all,data.frame('application'='lud',
                                                        'device'=d,
                                                        'size'=s,
                                                        'total_time'=x$total_time,
                                                        'kernel_time'=x$time_contributed,
                                                        'kernel'=x$kernel,
                                                        'run'=x$run))
        }
    }
    print("done.")
    #munge csr
    print("munging csr data...")
    for(d in devices){
        for(s in sizes){
            x <- subset(rundata.csr,device == d & size == s)
            x <- SumPerRunPerROIReduction(x,'csr_kernel')
            rundata.all <- rbind(rundata.all,data.frame('application'='csr',
                                                        'device'=d,
                                                        'size'=s,
                                                        'total_time'=x$total_time,
                                                        'kernel_time'=x$time_contributed,
                                                        'kernel'=x$kernel,
                                                        'run'=x$run))

        }
    }
    print("done.")
    #munge fft
    print("munging fft data...")
    for(d in devices){
        for(s in sizes){
            x <- subset(rundata.fft,device == d & size == s)
            x <- SumPerRunPerROIReduction(x,'fft_kernel')
            rundata.all <- rbind(rundata.all,data.frame('application'='fft',
                                                        'device'=d,
                                                        'size'=s,
                                                        'total_time'=x$total_time,
                                                        'kernel_time'=x$time_contributed,
                                                        'kernel'=x$kernel,
                                                        'run'=x$run))
        }
    }
    print("done.")
    #munge dwt
    print("munging dwt data...")
    for(d in devices){
        for(s in sizes){
            x <- subset(rundata.dwt,device == d & size == s)
            x <- SumPerRunPerROIReduction(x,c('kl_fdwt53Kernel_kernel','c_CopySrcToComponents_kernel'))
            rundata.all <- rbind(rundata.all,data.frame('application'='dwt',
                                                        'device'=d,
                                                        'size'=s,
                                                        'total_time'=x$total_time,
                                                        'kernel_time'=x$time_contributed,
                                                        'kernel'=x$kernel,
                                                        'run'=x$run))
        }
    }
    print("done.")
    #munge gem
    print("munging gem data...")
    for(d in devices){
        for(s in sizes){
            x <- subset(rundata.gem,device == d & size == s)
            x <- SumPerRunPerROIReduction(x,'gem_kernel')
            rundata.all <- rbind(rundata.all,data.frame('application'='gem',
                                                        'device'=d,
                                                        'size'=s,
                                                        'total_time'=x$total_time,
                                                        'kernel_time'=x$time_contributed,
                                                        'kernel'=x$kernel,
                                                        'run'=x$run))
        }
    }
    print("done.")
    #munge srad
    print("munging srad data...")
    for(d in devices){
        for(s in sizes){
            x <- subset(rundata.srad,device == d & size == s)
            x <- SumPerRunPerROIReduction(x,c('srad1_kernel','srad2_kernel'))
            rundata.all <- rbind(rundata.all,data.frame('application'='srad',
                                                        'device'=d,
                                                        'size'=s,
                                                        'total_time'=x$total_time,
                                                        'kernel_time'=x$time_contributed,
                                                        'kernel'=x$kernel,
                                                        'run'=x$run))

        }
    }
    print("done.")
    #munge crc
    print("munging crc data...")
    for(d in devices){
        for(s in sizes){
            x <- subset(rundata.crc,device == d & size == s)
            x <- SumPerRunPerROIReduction(x,'kernel_compute_kernel')
            rundata.all <- rbind(rundata.all,data.frame('application'='crc',
                                                        'device'=d,
                                                        'size'=s,
                                                        'total_time'=x$total_time,
                                                        'kernel_time'=x$time_contributed,
                                                        'kernel'=x$kernel,
                                                        'run'=x$run))
        }
    }
    print("done.")
}

if (!exists("rundata.energy")){
    SumEnergyPerRunReduction <- function(x){
        z <- data.frame()
        for (y in unique(x$run)){
            z <- rbind(z,data.frame('energy'=sum(x[x$run == y,]$energy),'run'=y))
        }
        return(z)
    }

    AppendColumnsPerDevice <- function(columns,device){
        if (device == 'i7-6700k'){
            columns <- c(columns,'rapl:::PP0_ENERGY:PACKAGE0','rapl:::DRAM_ENERGY:PACKAGE0')
        }
        else{
            columns <- c(columns,'nvml:::GeForce_GTX_1080:power','nvml:::GeForce_GTX_1080:temperature')
        }
        return(columns)
    }
    
    GetExtension <- function(device){
        if (device == 'i7-6700k'){
            return('_cpu_energy_nanojoules')
        }
        else{
            return('_gpu_energy_milliwatts')
        }
    }

    ConvertToJoules <- function(data,device){
        if(device == 'i7-6700k'){
            data$energy <- data$rapl...PP0_ENERGY.PACKAGE0*10**-9
        }
        else{
            data$energy <- ((data$nvml...GeForce_GTX_1080.power*10**-3) * (data$time*10**-6))
        }
        return(data)
    }

    rundata.energy <- data.frame()
    energy_devices <- c('i7-6700k','gtx1080')
    energy_sizes <- c('large')

    for(device in energy_devices){
        for(size in energy_sizes){
            #kmeans
            columns <- c('region','number_of_objects','number_of_features','iteration_number_hint_until_convergence','id','time','overhead')
            columns<-AppendColumnsPerDevice(columns,device)
            extension<-GetExtension(device)
            path = paste("../data/energy_data/",device,"_kmeans_",size,extension,".0/",sep='')
            print(paste("loading:",path))
            x <- ReadAllFilesInDir.AggregateWithRunIndex(dir.path=path,col=columns)
            x <- x[x$region=="kmeans_kernel",]
            x <- ConvertToJoules(x,device)
            x <- SumEnergyPerRunReduction(x)
            rundata.energy <- rbind(rundata.energy,data.frame('application'='kmeans',
                                                              'device'=device,
                                                              'size'=size,
                                                              'energy'=x$energy,
                                                              'run'=x$run))
            #lud
            columns <- c('region','matrix_dimension','id','time','overhead')
            columns<-AppendColumnsPerDevice(columns,device)
            path = paste("../data/energy_data/",device,"_lud_",size,extension,".0/",sep='')
            print(paste("loading:",path))
            x <- ReadAllFilesInDir.AggregateWithRunIndex(dir.path=path,col=columns)
            x <- x[(x$region=="diagonal_kernel"|x$region=="perimeter_kernel"|x$region=="internal_kernel"),]
            x <- ConvertToJoules(x,device)
            x <- SumEnergyPerRunReduction(x)
            rundata.energy <- rbind(rundata.energy,data.frame('application'='lud',
                                                              'device'=device,
                                                              'size'=size,
                                                              'energy'=x$energy,
                                                              'run'=x$run))
            #csr
            columns <- c('region','number_of_matrices','workgroup_size','execution_number','id','time','overhead')
            columns<-AppendColumnsPerDevice(columns,device)
            path = paste("../data/energy_data/",device,"_csr_",size,extension,".0/",sep='')
            print(paste("loading:",path))
            #SeparateAllNAsInFilesInDir(dir.path=path) 
            x <- ReadAllFilesInDir.AggregateWithRunIndex(dir.path=path,col=columns)
            x <- x[(x$region=="csr_kernel"),]
            x <- ConvertToJoules(x,device)
            x <- SumEnergyPerRunReduction(x)
            rundata.energy <- rbind(rundata.energy,data.frame('application'='csr',
                                                              'device'=device,
                                                              'size'=size,
                                                              'energy'=x$energy,
                                                              'run'=x$run))
            #fft
            columns <- c('signal_length','region','id','time','overhead')
            columns<-AppendColumnsPerDevice(columns,device)
            path = paste("../data/energy_data/",device,"_openclfft_",size,extension,".0/",sep='')
            print(paste("loading:",path))
            x <- ReadAllFilesInDir.AggregateWithRunIndex(dir.path=path,col=columns)
            x <- x[(x$region=="fft_kernel"),]
            x <- ConvertToJoules(x,device)
            x <- SumEnergyPerRunReduction(x)
            rundata.energy <- rbind(rundata.energy,data.frame('application'='fft',
                                                              'device'=device,
                                                              'size'=size,
                                                              'energy'=x$energy,
                                                              'run'=x$run))
            #dwt
            columns <- c('region','dwt_level','id','time','overhead')
            columns<-AppendColumnsPerDevice(columns,device)
            path = paste("../data/energy_data/",device,"_dwt2d_",size,extension,".0/",sep='')
            print(paste("loading:",path))
            x <- ReadAllFilesInDir.AggregateWithRunIndex(dir.path=path,col=columns)
            x <- x[(x$region=="kl_fdwt53Kernel_kernel"),]
            x <- ConvertToJoules(x,device)
            x <- SumEnergyPerRunReduction(x)
            rundata.energy <- rbind(rundata.energy,data.frame('application'='dwt',
                                                              'device'=device,
                                                              'size'=size,
                                                              'energy'=x$energy,
                                                              'run'=x$run))
            #gem
            columns <- c('number_of_residues','number_of_vertices','region','id','time','overhead')
            columns<-AppendColumnsPerDevice(columns,device)
            path = paste("../data/energy_data/",device,"_gem_",size,extension,".0/",sep='')
            print(paste("loading:",path))
            x <- ReadAllFilesInDir.AggregateWithRunIndex(dir.path=path,col=columns)
            x <- x[(x$region=="gem_kernel"),]
            x <- ConvertToJoules(x,device)
            x <- SumEnergyPerRunReduction(x)
            rundata.energy <- rbind(rundata.energy,data.frame('application'='gem',
                                                              'device'=device,
                                                              'size'=size,
                                                              'energy'=x$energy,
                                                              'run'=x$run))
            #srad
            columns <- c('region','id','time','overhead')
            columns<-AppendColumnsPerDevice(columns,device)
            path = paste("../data/energy_data/",device,"_srad_",size,extension,".0/",sep='')
            print(paste("loading:",path))
            x <- ReadAllFilesInDir.AggregateWithRunIndex(dir.path=path,col=columns)
            x <- x[(x$region=="srad1_kernel"|x$region=="srad2_kernel"),]
            x <- ConvertToJoules(x,device)
            x <- SumEnergyPerRunReduction(x)
            rundata.energy <- rbind(rundata.energy,data.frame('application'='srad',
                                                              'device'=device,
                                                              'size'=size,
                                                              'energy'=x$energy,
                                                              'run'=x$run))
            #crc
            columns <- c('number_of_pages','page_size','region','id','time','overhead')
            columns<-AppendColumnsPerDevice(columns,device)
            path = paste("../data/energy_data/",device,"_crc_",size,extension,".0/",sep='')
            print(paste("loading:",path))
            x <- ReadAllFilesInDir.AggregateWithRunIndex(dir.path=path,col=columns)
            x <- x[(x$region=="kernel_compute_kernel"),]
            x <- ConvertToJoules(x,device)
            x <- SumEnergyPerRunReduction(x)
            rundata.energy <- rbind(rundata.energy,data.frame('application'='crc',
                                                              'device'=device,
                                                              'size'=size,
                                                              'energy'=x$energy,
                                                              'run'=x$run))        
        }
    }
}

if (!exists("rundata.cache")){
    SumMissRatePerRunReduction <- function(x,feature){
    z <- data.frame()
    for (y in unique(x$run)){
        z <- rbind(z,data.frame('count'=eval(parse(text=paste("sum(x[x$run == y,]$",feature,')',sep=''))),'run'=y))
    }
    return(z)
}
    rundata.cache <- data.frame()
    device <- c('i7-6700k')
    sizes <- c('tiny','small','medium','large')
    for(size in sizes){
            #kmeans
            columns <- c('region','number_of_objects','number_of_features','iteration_number_hint_until_convergence','id','time','overhead')
            path = paste("../data/cache_data/",device,"_kmeans_",size,"_L1_data_cache_miss_rate.0/",sep='')
            print(paste("loading:",path))
            x <- ReadAllFilesInDir.AggregateWithRunIndex(dir.path=path,col=c(columns,'PAPI_TOT_INS','PAPI_L1_DCM'))
            x <- x[x$region=="kmeans_kernel",]
            l1misses <- SumMissRatePerRunReduction(x,'PAPI_L1_DCM')
            l1ins <- SumMissRatePerRunReduction(x,'PAPI_TOT_INS')
            rundata.cache <- rbind(rundata.cache,data.frame('application'='kmeans',
                                                            'device'=device,
                                                            'size'=size,
                                                            'cache_level'='L1',
                                                            'misses'=l1misses$count/l1ins$count,
                                                            'total_instructions'=l1ins$count,
                                                            'run'=l1misses$run))

            path = paste("../data/cache_data/",device,"_kmeans_",size,"_L2_data_cache_miss_rate.0/",sep='')
            print(paste("loading:",path))
            x <- ReadAllFilesInDir.AggregateWithRunIndex(dir.path=path,col=c(columns,'PAPI_TOT_INS','PAPI_L2_DCM'))
            x <- x[x$region=="kmeans_kernel",]
            l2misses <- SumMissRatePerRunReduction(x,'PAPI_L2_DCM')
            l2ins <- SumMissRatePerRunReduction(x,'PAPI_TOT_INS')
            rundata.cache <- rbind(rundata.cache,data.frame('application'='kmeans',
                                                            'device'=device,
                                                            'size'=size,
                                                            'cache_level'='L2',
                                                            'misses'=l2misses$count/l2ins$count,
                                                            'total_instructions'=l2ins$count,
                                                            'run'=l2misses$run))

            path = paste("../data/cache_data/",device,"_kmeans_",size,"_L3_total_cache_miss_rate.0/",sep='')
            print(paste("loading:",path))
            x <- ReadAllFilesInDir.AggregateWithRunIndex(dir.path=path,col=c(columns,'PAPI_TOT_INS','PAPI_L3_TCM'))
            x <- x[x$region=="kmeans_kernel",]
            l3misses <- SumMissRatePerRunReduction(x,'PAPI_L3_TCM')
            l3ins <- SumMissRatePerRunReduction(x,'PAPI_TOT_INS')
            rundata.cache <- rbind(rundata.cache,data.frame('application'='kmeans',
                                                            'device'=device,
                                                            'size'=size,
                                                            'cache_level'='L3',
                                                            'misses'=l3misses$count/l3ins$count,
                                                            'total_instructions'=l3ins$count,
                                                            'run'=l3misses$run))


    }
}

