#!/bin/bash

# Step 1: Load the VSEARCH module
# This step loads the VSEARCH software module, preparing it for use. 
# This is specific to environments that use module management systems.
# Your cluster or system may require a different approach to load the software and version.
echo "Step 1: Loading VSEARCH module..."
ml VSEARCH/2.25.0-GCC-12.3.0

# Step 2: Add sample name to each sequence
# For each .gz compressed FASTA file starting with 'S', this step decompresses the file,
# adds the sample name to the start of each sequence identifier, and saves the modified sequences
# in a new file with a '.labeled.fasta' extension.
echo "Step 2: Adding sample name to keep track of sequences..."
for file in S*.gz;
do
    sample=$(basename $file .fasta.gz)
    echo "Processing file: $file"
    zcat $file | sed "s/^>/>$sample|/" > ${sample}.labeled.fasta
done

# Step 3: Concatenate all sequences
# This step concatenates all labeled FASTA files into a single file, 
# combining all sequences into one file for further processing. 
# The output file is named 'all_samples.fasta'.
echo "Step 3: Concatenating all sequences..."
cat *.labeled.fasta > all_samples.fasta

# Step 4: Dereplicate sequences
# Dereplicates sequences by collapsing identical sequences into a single sequence,
# keeping track of the number of occurrences (abundance) and assigning a unique identifier.
# The output file 'all_samples_derep.fasta' contains the dereplicated sequences.
echo "Step 4: Dereplicating sequences..."
vsearch --derep_fulllength all_samples.fasta --output all_samples_derep.fasta --sizeout --uc all_samples_derep.uc --relabel_sha1

# Sort sequences by size
# Sorts the dereplicated sequences by their abundance (size) in descending order.
# This step helps prioritize more abundant sequences for downstream analysis.
# The output file 'all_samples_sorted.fasta' contains the sorted sequences.
echo "Step 4.5: Sorting sequences by size..."
vsearch --sortbysize all_samples_derep.fasta --output all_samples_sorted.fasta

# Step 5: Cluster sequences
# Clusters sequences based on 97% similarity, creating groups (OTUs) and selecting a representative sequence (centroid) for each group.
# The output file 'centroids.fasta' contains the representative sequences (centroids) of the identified OTUs.
echo "Step 5: Clustering sequences..."
vsearch --cluster_size all_samples_sorted.fasta --id 0.97 --centroids temp_centroids.fasta --sizeout

# Sort centroids by abundance
# Sorts the representative sequences (centroids) by their abundance to prioritize more common sequences. 
echo "Step 5.5: Sorting centroids by abundance..."
vsearch --sortbysize temp_centroids.fasta --output sorted_centroids.fasta --sizein

# Format the OTU labels with 5 digits
# Renames the sorted centroids with a standardized OTU label, ensuring a consistent and readable format.
# The output file 'centroids.fasta' contains the final set of OTU centroids with standardized labels.
awk '/^>/{printf(">OTU_%05d\n", ++i); next}{print}' sorted_centroids.fasta > centroids.fasta
rm temp_centroids.fasta

# Step 6: Map sequences to centroids
# Maps the original sequences to the identified OTUs based on similarity, 
# creating a mapping file and an OTU table that summarizes the abundance of each OTU across the samples.
# The output files 'readmap.uc' and 'otutab.txt' contain the mapping information and OTU table, respectively.
# The mapping is performed at 97% similarity threshold, the same as the clustering step for the centroids.
echo "Step 6: Mapping sequences to centroids..."
vsearch --usearch_global all_samples.fasta --db centroids.fasta --id 0.97 --uc readmap.uc --otutabout otutab.txt

# Final step: Indicate that the script finished successfully
echo "Script finished successfully."