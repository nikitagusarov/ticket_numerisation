# PART 0: Variables setup

# Define variables
path = "data/photo/vert"
rotate = 90
convert_type = "Grayscale"
resize = "1000x"
resize_filter = "Gaussian"
threshold_type = c("black", "white")
threshold = "50%"
threshold_channel = NULL
latency = FALSE
lat_geometry = "2x2+0%"
write_format = "png"
write_density = "1000x1000"



# PART 1: Loading images

# Load packages
library(tidyverse)

# Read files 
files = list.files(
    "data/photo/vert", 
    full = TRUE
)

# Read images 
images = lapply(
    files, 
    function(x) {
        magick::image_read(x) %>% 
        image_rotate(90)
    }
)



# PART 2: Images adaptation

# Load functional packages
library(magick)

# Main pype transfomation flow
transformed_images = lapply(
    images, 
    function(x) {
        x %>%
        image_threshold(
            type = c("black", "white"),
            threshold = "50%",
            channel = NULL
        ) %>% 
        image_convert(
            type = "Grayscale"
        ) %>% 
        image_resize(
            "1000x", 
            filter = "Gaussian"
        ) %>%{ 
            if (latency)
                image_lat(
                    geometry = "5x5+1%"
                ) 
            else .
        } %>% 
        image_write(
            format = "png", 
            density = "1000x1000"
        )
    }
)



# PART 3: Text extraction 

# Loading Tesseract
library(tesseract)

# Start tesseract and parametrise it 
tesseract(language = "fra")

# Text extraction
text = lapply(
    transformed_images,
    function(x) {
        x  %>% 
        ocr()
    }
)



# PART 4: Text mining

# Output 
cat(text[[1]])

text = text %>% 
    lapply(
        function(x) 
        strsplit(x, "\n")
    )

# Treatment of the text data