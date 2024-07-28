# Load necessary libraries
library(taxonomizr)
library(tidyverse)

# Point to the SQL file containing the taxonomy database
# accessionTaxa.sql <- "/Users/anderkkr/Library/CloudStorage/OneDrive-UniversitetetiOslo/00_Master_projects_OD/01_Active_Projects_OD/99_div/accessionTaxa.sql"
# setwd("/Users/anderkkr/Library/CloudStorage/OneDrive-UniversitetetiOslo/00_Master_projects_OD/01_Active_Projects_OD/37_Piotr/01_github/green_endophytes/TufA_DB")

# Set the desired taxa levels
desTax <- c("superkingdom", "kingdom", "phylum", "class", "order", "family", "genus", "species")
  
# Read the csv with the accession numbers in column 1 followed by the sequence
db.tufa <- read.table("data/Acc_database.csv", header = TRUE, sep = "\t") %>% as_tibble()

# Find duplicates in the dataset db.tufa$Accession
duplicates <- db.tufa %>% group_by(Accession) %>% summarise(n = n()) %>% filter(n > 1)

# Remove duplicates from the dataset with the shortes string in the 'Sequence' column
db.tufa <- db.tufa %>% arrange(nchar(Sequence)) %>% distinct(Accession, .keep_all = TRUE)

# Convert the list of accession numbers to taxonomy IDs
taxaID <- accessionToTaxa(db.tufa$Accession, accessionTaxa.sql, version = "base")

# Retrieve the taxonomy information for the list of taxonomy IDs
taxa <- getTaxonomy(taxaID, accessionTaxa.sql, desiredTaxa = desTax) %>% as_tibble()

# Combine the original data with the retrieved taxonomy information
db.tufa.with.tax <- db.tufa %>% cbind(taxaID, taxa) %>% as_tibble()

# Find rows where the 'superkingdom' column is NA
na_superkingdom <- db.tufa.with.tax %>% filter(is.na(superkingdom))

# Find the missing TaxaID
missing_taxaID <- db.tufa.with.tax %>% filter(is.na(taxaID))

# Write the accession for the missing TaxaID to a file, sort alphabetically first   
missing_taxaID <- missing_taxaID %>% arrange(Accession)  
write.table(missing_taxaID$Accession, "data/missing_taxaID.tsv", row.names = FALSE, col.names = FALSE, quote = FALSE)

# Remove the  missing_taxaID from db.tufa.with.tax
db.tufa.with.tax <- db.tufa.with.tax %>% filter(!is.na(taxaID))

# The taxid for the missing TaxaID can be found by searching the NCBI database, manually.
# Read table with manually added TaxaID
taxaID_manual <- read.table("data/taxaID_manual.tsv", header = TRUE, sep = "\t")

# Remove the rows with "Record_suppressed" as taxid from the dataset, and convert the taxid column to numeric
taxaID_manual <- taxaID_manual %>% filter(taxid != "Record_suppressed") %>% mutate(taxid = as.numeric(taxid))

# Retrieve the taxonomy information for the list taxaID_manual
taxa_manual <- getTaxonomy(taxaID_manual$taxid, accessionTaxa.sql, desiredTaxa = desTax, version = "base") %>% as_tibble()

colnames(taxaID_manual) <- c("Accession", "taxaID")

# Combine taxaID_manual with taxa_manual
taxa_manual <- cbind(taxaID_manual, taxa_manual) %>% as_tibble()

# Get the sequence from db.tufa that matches the Accession in taxa_manual using left join
taxa_manual_seq <- left_join(taxa_manual, db.tufa, by = "Accession") %>% as_tibble()

# Rearrange the columns
taxa_manual_seq <- taxa_manual_seq %>% select(Accession, Sequence, taxaID, superkingdom, phylum, class, order, family, genus, species)
db.tufa.with.tax <- db.tufa.with.tax %>% select(Accession, Sequence, taxaID, superkingdom, phylum, class, order, family, genus, species)

# merge the two datasets
db.tufa.with.tax <- rbind(db.tufa.with.tax, taxa_manual_seq) %>% as_tibble()

# Repeat the process for the Phaeoexplore database
db.phaeo <- read.table("data/Acc_database_Phaeo.tsv", header = TRUE, sep = "\t") %>% as_tibble()

# Get the taxonomy based on the taxid
taxa_phaeo <- getTaxonomy(db.phaeo$taxaID, accessionTaxa.sql, desiredTaxa = desTax, version = "base") %>% as_tibble()

# Combine the original data with the retrieved taxonomy information
db.phaeo.with.tax <- db.phaeo %>% cbind(taxa_phaeo) %>% as_tibble()

# Rearrange the columns
db.phaeo.with.tax <- db.phaeo.with.tax %>% select(Accession, Sequence, taxaID, superkingdom, phylum, class, order, family, genus, species)

# combine with the tufA database
db.tufa.with.tax <- rbind(db.tufa.with.tax, db.phaeo.with.tax) %>% as_tibble()

# Funtion to clean the column names
clean_character_columns <- function(df) {
  df %>%
    mutate(across(where(is.character), ~ str_replace_all(.x, "[[:punct:]]", "") %>% 
                                       str_replace_all(" ", "_")))
}

db_clean <- clean_character_columns(db.tufa.with.tax)

# Create a variable called lineage with the lineage of the sequence
db_clean <- db_clean %>%
  unite(lineage, superkingdom:species, sep = ";", remove = FALSE)
db_clean$lineage

# Function to replace NA with incremental suffix
replace_na_with_suffix <- function(x) {
  parts <- unlist(strsplit(x, ";"))
  previous_value <- parts[1] # Start with the first element
  suffix_count <- 0 # Counter for the number of "NA" encountered
  
  for (i in 2:length(parts)) {
    if (parts[i] == "NA") {
      suffix_count <- suffix_count + 1 # Increment the suffix counter
      parts[i] <- paste0(previous_value, "_", strrep("X", suffix_count))
    } else {
      previous_value <- parts[i] # Update previous_value with the last non-NA part
      suffix_count <- 0 # Reset suffix counter for the next non-NA part
    }
  }
  
  return(paste(parts, collapse = ";"))
}
  
# Example usage

taxonomy <- "Bacteria;hello;NA;NA;uncultured_bacterium_Ak203"
result <- replace_na_with_suffix(taxonomy)
print(result)


# Example usage
taxonomy <- "Bacteria;NA;NA;NA;NA;NA;uncultured_bacterium_Ak203"
result <- replace_na_with_suffix(taxonomy)
print(result)

# Apply the function to the lineage column
db_clean$lineage <- sapply(db_clean$lineage, replace_na_with_suffix)
# Remove the names of the vector
names(db_clean$lineage) <- NULL
str(db_clean$lineage)
db_clean$lineage[2]

# Write a fasta with the accession and lineage in the header, followed by the sequence  

sequences <- db_clean$Sequence
header <- paste(db_clean$Accession, db_clean$lineage, sep = "|")
Xfasta <- character(nrow(db_clean) * 2)
Xfasta[c(TRUE, FALSE)] <- paste0(">", header)
Xfasta[c(FALSE, TRUE)] <- db_clean$Sequence
writeLines(Xfasta, "tufA_DB.fasta")

