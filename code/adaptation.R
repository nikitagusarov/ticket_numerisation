#################################
# Adaptation of the input image #
#################################

# # On linux should install dependecies first 
# sudo apt install libmagick++-dev
# sudo apt install tesseract-ocr tesseract-ocr-fra libtesseract-dev libleptonica-dev

adaptation = function(
    images, 
    convert_type = "Grayscale",
    resize = "1000x",
    resize_filter = "Gaussian",
    threshold_type = c("black", "white"),
    threshold = "50%",
    threshold_channel = NULL,
    latency = FALSE,
    lat_geometry = "2x2+0%",
    write_format = "png",
    write_density = "1000x1000"
) {
    # Load packages 
    library(tidyverse)
    library(magick)
    library(tesseract)

    # Start tesseract 
    tesseract(language = "fra")

    # Main pype transfomation flow
    transformed_images = lapply(
        images, 
        function(x) {
            x %>%
            image_convert(
                type = convert_type
            ) %>% 
            image_resize(
                resize, 
                filter = resize_filter
            ) %>%
            image_threshold(
                type = threshold_type,
                threshold = threshold,
                channel = threshold_channel
            ) %>% { 
                if (latency)
                    image_lat(
                        geometry = lat_geometry
                    ) 
                else .
            } %>% 
            image_write(
                format = write_format, 
                density = write_density
            ) %>% 
            ocr()
        }
    )
    
    # Output
    return(transformed_images)
}