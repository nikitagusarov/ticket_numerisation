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
library(magick)
library(foreach)

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

images = foreach (i = 1:length(files)) %do% {
    cat(i, "\n")
    magick::image_read(files[i]) %>% 
    image_rotate(90)
}


# PART 2: Images adaptation

# Load functional packages
library(magick)

# aux
latency = FALSE
gc(full = TRUE)

# PART 3: Text extraction 

# Loading Tesseract
library(tesseract)

# Start tesseract and parametrise it 
tesseract(language = "fra")

# Main pype transfomation flow
transformed_images = lapply(
# text = lapply(
    # images,
    files, 
    function(x) {
        read = x %>% 
        image_read() %>% 
        image_rotate(90) %>%
        image_resize(
            "1000x"#, 
            # filter = "Gaussian"
        ) %>%
        image_threshold(
            type = c("black", "white"),
            threshold = "50%",
            channel = NULL
        ) %>% 
        image_convert(
            type = "Grayscale"
        ) %>% { 
            if (latency)
                image_lat(
                    geometry = "5x5+1%"
                ) 
            else .
        } %>% 
        image_write(
            format = "png", 
            density = "1000x1000"
        ) %>% 
        ocr()
        
        # Clean space
        gc(full=TRUE) 

        # Write
        read
    }
)

gc(full = TRUE) 

# Text extraction
text = lapply(
    transformed_images,
    function(x) {
        x  %>% 
        ocr()
    }
)



# PART 4: Text mining
text = transformed_images

# aux
lapply(text, cat)

strsplit(text[[1]], "\n")

# Parallelisation
library(foreach)

# Text treatment
tab = foreach (i = 1:length(text), .combine = rbind) %do% {

    # Unlist 
    ticket = text[[i]] %>% 
        strsplit("\n") %>% 
        unlist()
        
    # Remove blank lines
    ticket = ticket[which(ticket != "")]

    if (any(ticket == "DEBIT")) {
        # CLASS 1: Credit card payment ticket

        # Find "DEBIT"
        data.frame(
            Type = "Debit",
            Total = ticket[which(ticket == "DEBIT") - 1], 
            Date = ticket[6],
            Agent = ticket[7],
            Category = NA,
            Product = NA
        )
    } else if (any (ticket == "Casino")) {
        # CLASS 2: Geant full ticket

        # Catch product groups
        categories = grep("^>>*|^\\\\\\\\*", ticket)

        # List everything
        foreach (i = 1:(length(categories)-1), .combine = rbind) %do% {
            
            n = categories[i+1] - categories[i] - 1

            data.frame(
                Type = rep("Detail", n),
                Total = rep(NA, n),
                Date = rep(ticket[grep("^Date*", ticket)], n),
                Agent = rep(ticket[1], n),
                Category = rep(ticket[categories[i]], n),
                Product = ticket[(categories[i]+1):(categories[i+1]-1)]
            ) 
        }
    } else {}
}

# Organise 
tab =  tab %>% 
    mutate_all(as.character)
tab[is.na(tab)] = ""
tab %>% mutate(
    Total = as.numeric(str_extract(str_replace(tab$Total, ",", "."), "\\(?[0-9.]+\\)?"))
)

tab %>% mutate(
    Total = Total %>% 
        str_replace(",", ".") %>%   
        str_extract("\\(?[0-9.]+\\)?") %>% 
        as.numeric(),
    Time = Date %>% 
        str_replace("Date : ", "") %>% 
        str_extract("\\(?[0-9/:]+$\\)?"),
    Date = Date %>% 
        str_replace("Date : ", "") %>% 
        str_extract("\\(?[0-9/:]+\\)?"),
    Category = Category %>% 
        str_replace(">> ", ""),
    Price = Product %>% 
        str_replace(",", ".") %>%   
        str_extract("\\(?[0-9.]+\\)?") %>% 
        as.numeric()
)

# Preview 
tab

# Treatment of the text data