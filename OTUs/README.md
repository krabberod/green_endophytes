# OTU matrix

The raw reads from the sequencing run were demultiplexed with ONTBarcoder (https://github.com/asrivathsan/ONTbarcoder) resulting in 311,384 demultiplexed reads. Out of these reads, 287,766 contained the tufA gene. These reads were then clustered at 97% similarity and further processed using the sequence_processing_fasta_v2.sh script to generate the OTU matrix.

### FILES:
**centroids.fasta**: Original fasta file of sequence centroids, clustered at 97% similarity, before chimera checking.  
**centroids.tufDB.0.80.tab**: Tab-delimited file of sequence centroids clustered at 80% similarity against the tufA_DB gene database.  
**centroids.uchime3_denovo.absekw.1.5.chim.out**: UCHIME output of *chimeric* sequences detected de novo.   
**centroids.uchime3_denovo.absekw.1.5.non-chim.out**: UCHIME output of *non-chimeric sequences* detected de novo. This file is used for downstream analysis.  
**centroids.uchime3_denovo.absekw.1.5.non-chim.out.tab**: Tab-delimited version of non-chimeric sequences. (Same as above, but in tab-delimited format).  
**centroids.uchime_denovo.absekw.1.5.log.out**: Log file of UCHIME run details.  
**otutab.txt**: OTU table in tab-delimited format.  
**otutab.xlsx**: OTU table in Excel format.  
**sequence_processing_fasta_v2.sh**: Updated script script for processing fasta sequences.  
**R_code_for_OTU_table.R**: R script for OTU table analysis.  

The OTU matrix (otutab.txt) is a table that contains the number of reads for each OTU in each sample. The rows are the OTUs and the columns are the samples. 
