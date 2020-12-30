library("tabulizer")

# Getting the PDF link
pdf_link <- "https://germanwatch.org/sites/germanwatch.org/files/20-2-01e%20Global%20Climate%20Risk%20Index%202020_14.pdf"

# Preparing the column names
column_names <- c("CRI_Rank", "Country", "CRI_score", "FatalitiesTotal_Rank", "FatalitiesPer100000_Rank", 
                  "LossesTotal_Rank", "LossesPerGDP_Rank")

# Scraping p41
pdf_data_p41 <- as.data.frame(extract_tables(pdf_link, pages = 41, method = "decide"))

pdf_data_p41 <- as.data.frame(pdf_data_p41[2:nrow(pdf_data_p41), ])

colnames(pdf_data_p41) <- column_names

# Scraping p42
pdf_data_p42 <- as.data.frame(extract_tables(pdf_link, pages = 42, method = "decide"))

pdf_data_p42 <- as.data.frame(pdf_data_p42[2:nrow(pdf_data_p42), ])

colnames(pdf_data_p42) <- column_names

# Scraping p43
pdf_data_p43 <- as.data.frame(extract_tables(pdf_link, pages = 43, method = "decide"))

pdf_data_p43 <- as.data.frame(pdf_data_p43[2:nrow(pdf_data_p43), ])

colnames(pdf_data_p43) <- column_names

# Scraping p40
pdf_data_p40 <- as.data.frame(extract_areas(pdf_link, pages = 40, method = "stream"))

colnames(pdf_data_p40) <- column_names

# Joining the three datasets
RiskIndex_data <- rbind(pdf_data_p40, pdf_data_p41, pdf_data_p42, pdf_data_p43)
