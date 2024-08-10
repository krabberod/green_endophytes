# Script for reading and joining the OTU table, blast results, and sequence table
# The script also filters the OTU table based on the total size of the OTUs and the taxonomy
# The script also writes a fasta file with the sequences of the OTUs

# Install necessary libraries (skip if these are already installed)
install.packages("tidyverse") 

# Load package  

library(tidyverse)

# Read the OTU table from the file "otutab.txt"
# The table is read with headers and tab-separated values, then converted to a tibble for easier manipulation
otu <- read.table("otutab.txt", header=TRUE, sep="\t") %>% as_tibble()

# Add the total size for each OTU, based on the samplename (i.e start with "S0")
otu <- otu %>% mutate(total_size = rowSums(select(., starts_with("S0"))))
# move the "total_size" column to the second position, just for better readability
otu <- otu %>% select(OTU.ID, total_size, everything())

# Remove singletons (i.e. remove OTUS with total_size less than 2)
# Here it is possible to raise the threshold to remove more low abundant OTUs
otu <- otu %>% filter(total_size >= 2) 

# Read the BLAST results (vsearch results) from the file "centroids.tufDB.0.80.tab"
# The table is read without headers and tab-separated values, then converted to a tibble
blast <- read.table("centroids.tufDB.0.80.tab", header=FALSE, sep="\t") %>% as_tibble()

# Assign column names to the BLAST results table
colnames(blast) <- c("OTU.ID", "taxonomy", "identity", "alignment_length", "mismatches", "gap_opens", "qstart", "qend", "sstart", "send", "evalue", "bitscore")

# Read the sequence table from the file "centroids.uchime3_denovo.absekw.1.5.non-chim.out.tab"
# The table is read without headers and tab-separated values, then converted to a tibble
seq <- read.table("centroids.uchime3_denovo.absekw.1.5.non-chim.out.tab", header=FALSE, sep="\t") %>% as_tibble()

# Assign column names to the sequence table
colnames(seq) <- c("OTU.ID", "seq")

# join the tables and write the output
full_table <- inner_join(blast, seq) %>% inner_join(otu, by="OTU.ID") 
full_table <- full_table %>% select(OTU.ID, total_size, everything())

# Check length (i.e. how many rows) of the joined table
nrow(full_table)

# split the taxonomy into separate columns
full_table <-full_table %>% mutate(original_taxonomy = taxonomy) %>%
  separate(taxonomy, into = c("ID", "Domain", "Phylum", "Class", "Order", "Family", "Genus", "Species"), sep = ";|\\|", extra = "merge")

full_table %>% select(OTU.ID, total_size, original_taxonomy, everything())


# Find how manys sequences are in each sample
full_table %>% select(starts_with("S0")) %>% colSums()

# Filter columns with 0 or 1 sequences
cols_to_remove <- full_table %>% select(starts_with("S0")) %>% 
  colSums() %>% .[. <= 1] %>% names()

# Remove them 
full_table <- full_table %>% select(-all_of(cols_to_remove))

# Check the taxonomy
table(full_table$Domain)
table(full_table$Phylum)
table(full_table$Class)
table(full_table$Order)
# etc

# Remove bacteria: 
full_table <- full_table %>% filter(!grepl("Bacteria", Domain))

# Check the taxonomy
table(full_table$Domain)
table(full_table$Phylum)
table(full_table$Class)
# etc
table(full_table$Species)
# etc

# If you want to write a fasta file with the sequences of the OTUs
# write the sequences of the OTUs to a fasta file

# Find chlorophytes
full_table %>% filter(grepl("Chlorophyta", Phylum))

# Find the OTUs that are not chlorophytes
full_table %>% filter(!grepl("Chlorophyta", Phylum))

# Create a character vector for the FASTA file
Xfasta <- character(nrow(full_table) * 2)
Xfasta[c(TRUE, FALSE)] <- paste0(">", full_table$OTU.ID, ";size=", full_table$total_size)
Xfasta[c(FALSE, TRUE)] <- full_table$seq
Xfasta %>% as_tibble()
# Write the FASTA file
writeLines(Xfasta, "filtered_otus.fasta")

### Possible things for the next steps?:
# - Use the fasta file to create a phylogenetic tree for some of the groups
# - Split the dataframe according to geogoaphic location or other relevant metadata
# - Normalize the data (proportional abundance, rarefaction, etc.)
# - Use the taxonomy and reads to create a barplot of the OTUs in the samples
# - Use the taxonomy and reads to create a PCA or NMDS plot of the samples

# Example of PCA plot (the plot will probably not be very informative, but it is a start)
if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install("PCAtools")

library(PCAtools)

# Extract some data for PCA (here we use the columns containing "REV3"): 
df <- full_table %>% select(contains("REV3"))

# Assuming your OTU matrix is stored in a data frame called `otu_matrix`
# Rows are OTUs, columns are samples.
# Convert to proportional reads
otu_proportional <- sweep(df, 2, colSums(df), FUN = "/")

# View the resulting matrix
head(otu_proportional)
pca <- pca(otu_proportional)
biplot(pca)

# etc.. 

