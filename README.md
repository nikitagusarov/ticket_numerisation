# Automatic numerisation of payment tickets

This project appeared as a solution for handling the expenses details. 

## Sources

In the process of developpment several ressources were used: 

- [Main framework inspiration (Python code here)](https://nanonets.com/blog/receipt-ocr/)
- [R Tesseract guide](https://cran.r-project.org/web/packages/tesseract/vignettes/intro.html)
- [Linux (Ubuntu) Tesseract binding](https://doc.ubuntu-fr.org/tesseract-ocr)
- [Tesseract project GitHub homepage](https://github.com/tesseract-ocr/tesseract)
- [Tesseract documentation](https://tesseract-ocr.github.io/tessdoc)

## Organisation 

The payment ticket numerisation may be roughtly divided into several steps: 

1. Digitalisation payment ticket (ex: taking a photo of the actual payment ticket)
2. Adaptation of the resulting image
3. Reading the text from the cleared image with *Tesseract*
4. Database organisation

Some additional steps may be required: 

- Preliminary classification of the payment tickets by type to simplify the treatment
- ...

The logical block are separated into individual **.R** source files, which are then used by an execution file, which automates the whole process.