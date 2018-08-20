
#to be run from the paper level of the project "finding-hidden-dwarfs-in-kernels/paper"
## @knitr load_data

sizes <- c('tiny','small','medium','large')

if (!exists("featdata.csr")){
    featdata.csr <- data.frame()
    for(size in sizes){
        path <- paste("../data/feat_data/csr_",size,"/",sep='')
        files <- list.files(path)
        files <- files[grep('*.csv',files)]
        for (file in files){
            file_path <- paste(path,file,sep='')
            kernel_name <- gsub('aiwc_(.*)_(.*).csv','\\1',file)
            invocation_count <-  gsub('aiwc_(.*)_(.*).csv','\\2',file)
            x <- read.csv(file_path)
            x$application <- "csr"
            x$kernel <- kernel_name
            x$invocation <- invocation_count
            x$size <- size
            featdata.csr <- rbind(featdata.csr,x)
            print(paste("loaded file:",file))
        }
    }
}

if (!exists("featdata.fft")){
    featdata.fft <- data.frame()
    for(size in sizes){
        path <- paste("../data/feat_data/fft_",size,"/",sep='')
        files <- list.files(path)
        files <- files[grep('*.csv',files)]
        for (file in files){
            file_path <- paste(path,file,sep='')
            kernel_name <- gsub('aiwc_(.*)_(.*).csv','\\1',file)
            invocation_count <-  gsub('aiwc_(.*)_(.*).csv','\\2',file)
            x <- read.csv(file_path)
            x$application <- "fft"
            x$kernel <- kernel_name
            x$invocation <- invocation_count
            x$size <- size
            featdata.fft <- rbind(featdata.fft,x)
            print(paste("loaded file:",file))
        }
    }
}

if (!exists("featdata.gem")){
    featdata.gem <- data.frame()
    for(size in sizes){
        path <- paste("../data/feat_data/gem_",size,"/",sep='')
        files <- list.files(path)
        files <- files[grep('*.csv',files)]
        for (file in files){
            file_path <- paste(path,file,sep='')
            kernel_name <- gsub('aiwc_(.*)_(.*).csv','\\1',file)
            invocation_count <-  gsub('aiwc_(.*)_(.*).csv','\\2',file)
            x <- read.csv(file_path)
            x$application <- "gem"
            x$kernel <- kernel_name
            x$invocation <- invocation_count
            x$size <- size
            featdata.gem <- rbind(featdata.gem,x)
            print(paste("loaded file:",file))
        }
    }
}

if (!exists("featdata.kmeans")){
    featdata.kmeans <- data.frame()
    for(size in sizes){
        path <- paste("../data/feat_data/kmeans_",size,"/",sep='')
        files <- list.files(path)
        files <- files[grep('*.csv',files)]
        for (file in files){
            file_path <- paste(path,file,sep='')
            kernel_name <- gsub('aiwc_(.*)_(.*).csv','\\1',file)
            invocation_count <-  gsub('aiwc_(.*)_(.*).csv','\\2',file)
            x <- read.csv(file_path)
            x$application <- "kmeans"
            x$kernel <- kernel_name
            x$invocation <- invocation_count
            x$size <- size
            featdata.kmeans <- rbind(featdata.kmeans,x)
            print(paste("loaded file:",file))
        }
    }
}

if (!exists("featdata.lud")){
    featdata.lud <- data.frame()
    for(size in sizes){
        path <- paste("../data/feat_data/lud_",size,"/",sep='')
        files <- list.files(path)
        files <- files[grep('*.csv',files)]
        for (file in files){
            file_path <- paste(path,file,sep='')
            kernel_name <- gsub('aiwc_(.*)_(.*).csv','\\1',file)
            invocation_count <-  gsub('aiwc_(.*)_(.*).csv','\\2',file)
            x <- read.csv(file_path)
            x$application <- "lud"
            x$kernel <- kernel_name
            x$invocation <- invocation_count
            x$size <- size
            featdata.lud <- rbind(featdata.lud,x)
            print(paste("loaded file:",file))
        }
    }
}

if (!exists("featdata.dwt")){
    featdata.dwt <- data.frame()
    for(size in sizes){
        path <- paste("../data/feat_data/dwt_",size,"/",sep='')
        files <- list.files(path)
        files <- files[grep('*.csv',files)]
        for (file in files){
            file_path <- paste(path,file,sep='')
            kernel_name <- gsub('aiwc_(.*)_(.*).csv','\\1',file)
            invocation_count <-  gsub('aiwc_(.*)_(.*).csv','\\2',file)
            x <- read.csv(file_path)
            x$application <- "dwt"
            x$kernel <- kernel_name
            x$invocation <- invocation_count
            x$size <- size
            featdata.dwt <- rbind(featdata.dwt,x)
            print(paste("loaded file:",file))
        }
    }
}

if (!exists("featdata.srad")){
    featdata.srad <- data.frame()
    for(size in sizes){
        path <- paste("../data/feat_data/srad_",size,"/",sep='')
        files <- list.files(path)
        files <- files[grep('*.csv',files)]
        for (file in files){
            file_path <- paste(path,file,sep='')
            kernel_name <- gsub('aiwc_(.*)_(.*).csv','\\1',file)
            invocation_count <-  gsub('aiwc_(.*)_(.*).csv','\\2',file)
            x <- read.csv(file_path)
            x$application <- "srad"
            x$kernel <- kernel_name
            x$invocation <- invocation_count
            x$size <- size
            featdata.srad <- rbind(featdata.srad,x)
            print(paste("loaded file:",file))
        }
    }
}

if (!exists("featdata.bfs")){
    featdata.bfs <- data.frame()
    for(size in sizes){
        path <- paste("../data/feat_data/bfs_",size,"/",sep='')
        files <- list.files(path)
        files <- files[grep('*.csv',files)]
        for (file in files){
            file_path <- paste(path,file,sep='')
            kernel_name <- gsub('aiwc_(.*)_(.*).csv','\\1',file)
            invocation_count <-  gsub('aiwc_(.*)_(.*).csv','\\2',file)
            x <- read.csv(file_path)
            x$application <- "bfs"
            x$kernel <- kernel_name
            x$invocation <- invocation_count
            x$size <- size
            featdata.bfs <- rbind(featdata.bfs,x)
            print(paste("loaded file:",file))
        }
    }
}

if (!exists("featdata.hmm")){
    featdata.hmm <- data.frame()
    for(size in sizes){
        path <- paste("../data/feat_data/bwa_hmm_",size,"/",sep='')
        files <- list.files(path)
        files <- files[grep('*.csv',files)]
        for (file in files){
            file_path <- paste(path,file,sep='')
            kernel_name <- gsub('aiwc_(.*)_(.*).csv','\\1',file)
            invocation_count <-  gsub('aiwc_(.*)_(.*).csv','\\2',file)
            x <- read.csv(file_path)
            x$application <- "hmm"
            x$kernel <- kernel_name
            x$invocation <- invocation_count
            x$size <- size
            featdata.hmm <- rbind(featdata.hmm,x)
            print(paste("loaded file:",file))
        }
    }
}

if (!exists("featdata.nw")){
    featdata.nw <- data.frame()
    for(size in sizes){
        path <- paste("../data/feat_data/needle_",size,"/",sep='')
        files <- list.files(path)
        files <- files[grep('*.csv',files)]
        for (file in files){
            file_path <- paste(path,file,sep='')
            kernel_name <- gsub('aiwc_(.*)_(.*).csv','\\1',file)
            invocation_count <-  gsub('aiwc_(.*)_(.*).csv','\\2',file)
            x <- read.csv(file_path)
            x$application <- "nw"
            x$kernel <- kernel_name
            x$invocation <- invocation_count
            x$size <- size
            featdata.nw <- rbind(featdata.nw,x)
            print(paste("loaded file:",file))
        }
    }
}

if (!exists("featdata.crc")){
    featdata.crc <- data.frame()
    for(size in sizes){
        path <- paste("../data/feat_data/crc_",size,"/",sep='')
        files <- list.files(path)
        files <- files[grep('*.csv',files)]
        for (file in files){
            file_path <- paste(path,file,sep='')
            kernel_name <- gsub('aiwc_(.*)_(.*).csv','\\1',file)
            invocation_count <-  gsub('aiwc_(.*)_(.*).csv','\\2',file)
            x <- read.csv(file_path)
            x$application <- "crc"
            x$kernel <- kernel_name
            x$invocation <- invocation_count
            x$size <- size
            featdata.crc <- rbind(featdata.crc,x)
            print(paste("loaded file:",file))
        }
    }
}

if (!exists("featdata.nqueens")){
    featdata.nqueens <- data.frame()
    for(size in sizes){
        path <- paste("../data/feat_data/nqueens_",size,"/",sep='')
        files <- list.files(path)
        files <- files[grep('*.csv',files)]
        for (file in files){
            file_path <- paste(path,file,sep='')
            kernel_name <- gsub('aiwc_(.*)_(.*).csv','\\1',file)
            invocation_count <-  gsub('aiwc_(.*)_(.*).csv','\\2',file)
            x <- read.csv(file_path)
            x$application <- "nqueens"
            x$kernel <- kernel_name
            x$invocation <- invocation_count
            x$size <- size
            featdata.nqueens <- rbind(featdata.nqueens,x)
            print(paste("loaded file:",file))
        }
    }
}

if (!exists("featdata.all")){
    featdata.all <- rbind(featdata.kmeans,featdata.lud)
    featdata.all <- rbind(featdata.all,featdata.csr)
    featdata.all <- rbind(featdata.all,featdata.fft)
    featdata.all <- rbind(featdata.all,featdata.gem)
    featdata.all <- rbind(featdata.all,featdata.dwt)
    featdata.all <- rbind(featdata.all,featdata.srad)
    featdata.all <- rbind(featdata.all,featdata.bfs)
    featdata.all <- rbind(featdata.all,featdata.hmm)
    featdata.all <- rbind(featdata.all,featdata.nw)
    featdata.all <- rbind(featdata.all,featdata.crc)
    featdata.all <- rbind(featdata.all,featdata.nqueens)
}

