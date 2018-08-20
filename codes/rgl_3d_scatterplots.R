
source('../analysis_tools/studentise.R')

#library(rgl)
#
#plot3d(x=pca_dat$total_memory_footprint, y=pca_dat$branch_entropy_average_linear, z=pca_dat$local_memory_address_entropy_1, col=as.integer(pca_dat$size))

#do PCA
pca_in <- pca_dat[,1:19]
pca_in[is.na(pca_in)] <- 0 #replacing any NA encountered -- one of the entropy computations may do this!
prin_comp <- prcomp(pca_in,scale.=TRUE)

#plot3d(x=prin_comp$scores[,1:3], col=as.integer(pca_dat$size))

library(plotly)
p <- plot_ly(pca_dat,
             x = ~total_memory_footprint,
             y = ~branch_entropy_average_linear,
             z= ~local_memory_address_entropy_1,
             #marker = list(color = ~size, colorscale = c('#FFE1A1', '#683531'), showscale = TRUE)
             color = ~size,
             hoverinfo = 'text',
             text = ~paste("Kernel: ", kernel,"</br>",
                           "</br> Total Memory Footprint:",total_memory_footprint,
                           "</br> Branch Entropy (Average Linear):",branch_entropy_average_linear,
                           "</br> LMAE −− Skipped 1 LSBs:",local_memory_address_entropy_1),
             colors = c("#E55D59", "#6BA20D", "#4BB4B8", "#A956E7") ) %>%
     add_markers() %>%
     layout(scene = list(xaxis = list(title = 'Total Memory Footprint'),
                         yaxis = list(title = 'Branch Entropy (Average Linear)'),
                         zaxis = list(title = 'LMAE −− Skipped 1 LSBs')))#,

interactive_plot <- p

