###############
# Read inputs #
###############

# Here default values are adapted for the project layout

# Read different types of inputs requiring different rotation types
read_images = function(
    path = "data/photo/vert",
    rotate = 0
) {
    # Load packages
    library(tidyverse)

    # Read files 
    files_vert = list.files(
        path_vertical, 
        full = TRUE
    )

    # Read images 
    images = lapply(
        files_vert, 
        function(x) {
            magick::image_read(x) %>% 
            image_rotate(rotate)
        }
    )
    
    # Output
    return(images)
}
