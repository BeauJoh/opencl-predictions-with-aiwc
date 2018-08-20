
normalise <- function(x){
    return((x-min(x))/(max(x)-min(x)))
}

construct_inefficiency_matrix <- function(data){
    x <- data
    m <- length(unique(x$application))
    n <- length(unique(x$device))
    y <- matrix(nrow=m,ncol=n,dimnames = list(unique(x$application),unique(x$device)))

    m_c <- 1
    for (i in unique(x$application)){
        n_c <- 1
        for (j in unique(x$device)){
            y[m_c,n_c] <- median(subset(x,application==i&device==j)$time)
            n_c <- n_c + 1
        }
        m_c <- m_c + 1
    }
    return (y)
}

