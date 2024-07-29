# Scripts 
This folder contains scripts used in the analysis.
- [sequence_processing_vsearch.sh](sequence_processing_vsearch.sh) - script for processing sequences using vsearch.
The script has 6 steps

**Step 1: Load the VSEARCH module**
This step loads the VSEARCH software module, preparing it for use. 
This is specific to environments that use module management systems.

**Step 2: Add sample name to each sequence**
For each .gz compressed FASTA file starting with 'S', this step decompresses the file, adds the sample name to the start of each sequence identifier, and saves the modified sequences in a new file with a '.labeled.fasta' extension.

**Step 3: Concatenate all sequences**
This step concatenates all labeled FASTA files into a single file for further processing. 

**Step 4: **Dereplicate sequences**  
Dereplicate sequences by collapsing identical sequences into a single sequence, keeping track of the number of occurrences (abundance/size) and assigning a unique identifier.

**Step 5: Cluster sequences**
Clusters sequences based on 97% similarity, creating groups (OTUs) and selecting a representative sequence (centroid) for each group. The percentage similarity can be adjusted as needed.

**Step 6: Map sequences to centroids**
Map the original sequences to the identified OTUs based on similarity, creating a mapping file and an OTU table that summarizes the abundance of each OTU across the samples.