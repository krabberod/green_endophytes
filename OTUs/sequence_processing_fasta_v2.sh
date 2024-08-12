# NEW version of the sequence processing script
# Added a step to scan for tufA signal
# Added a step to check for chimeric sequences

# Scan for a signal of tufA:
HMM=/cluster/projects/nn9725k/Programmer/databases/tufA_db/tufA_DB_alignment.hmm
for REF in S*.fasta;
do
	echo "Scanning $REF" 
    ~/Programs/scripts/hmm_tufA.slurm $REF

   STR=$(basename $file .fasta)
   nhmmer --cpu $SLURM_CPUS_PER_TASK -A "$STR".tufA_out.sto $HMM $REF
   esl-reformat -d fasta "$STR".tufA_out.sto > "$STR".tufA_out.fasta
   rm "$STR".tufA_out.sto;
   /cluster/projects/nn9725k/Programmer/seqkit seq -m 300 "$STR".tufA_out.fasta > "$STR".tufA_out_300.fasta;
 done

# Step 2: Add sample name to each sequence
# For each FASTA file starting with 'S', this step adds the sample name to the start of each sequence identifier,
for file in S*tufA_out_300.fasta; 
do
   sample=$(basename $file .fasta)
   echo "Processing file: $file"
   sed "s/^>/>$sample|/" $file > ${sample}.labeled.fasta
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

module purge
ml VSEARCH/2.25.0-GCC-12.3.0
echo "Step 4: Dereplicating sequences..."
vsearch --derep_fulllength all_samples.fasta --output all_samples_derep.fasta --sizeout --uc all_samples_derep.uc --relabel_sha1

echo "Step 4.5: Sorting sequences by size..."
vsearch --sortbysize all_samples_derep.fasta --output all_samples_sorted.fasta

# Step 5: Cluster sequences
# Clusters sequences based on 97% similarity, creating groups (OTUs) and selecting a representative sequence (centroid) for each group.
echo "Step 5: Clustering sequences..."
vsearch --cluster_size all_samples_sorted.fasta --id 0.97 --centroids temp_centroids.fasta --sizeout --sizein

# Sort centroids by abundance
# Sorts the representative sequences (centroids) by their abundance to prioritize more common sequences. 
echo "Step 5.5: Sorting centroids by abundance..."
vsearch --sortbysize temp_centroids.fasta --output sorted_centroids.fasta --sizein

# Format the OTU labels with 5 digits
# Renames the sorted centroids with a standardized OTU label, ensuring a consistent and readable format.
awk '/^>/{match($0, /size=[0-9]+/); printf(">OTU_%05d;%s\n", ++i, substr($0, RSTART, RLENGTH)); next}{print}' sorted_centroids.fasta > centroids.fasta
sbatch ~/Programs/scripts/vsearch_global_search.tufA_DB.slurm centroids.fasta

# Step: Chimera checker
echo "Check for chimeric sequences" 
~/Programs/scripts/vsearch_uchime3_denovo.slurm centroids.fasta

# Step 6: Map sequences to chimera-free centroids
# Maps the original sequences to the identified OTUs based on similarity, 
# creating a mapping file and an OTU table that summarizes the abundance of each OTU across the samples.
# The output files 'readmap.uc' and 'otutab.txt' contain the mapping information and OTU table, respectively.
# The mapping is performed at 97% similarity threshold, the same as the clustering step for the centroids.
# echo "Step 6: Mapping sequences to centroids..."
vsearch --usearch_global all_samples.fasta --db centroids.uchime3_denovo.absekw.1.5.non-chim.out --id 0.97 --uc readmap.uc --otutabout otutab.txt

# Final step: Indicate that the script finished successfully
echo "Script finished successfully."
