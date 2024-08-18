# Demlutiplexing using only the REV primers+barcodes

This pipeline follows the same steps as the original pipeline (see [here](scripts/README.md)), but it uses only the REV primers and barcodes to demultiplex the samples since the combined demultiplexing did not work as expected. The new pipeline is as follows:

### Methods Summary

This pipeline demultiplexes samples using only the REV primers and barcodes, diverging slightly from the original pipeline due to issues with combined demultiplexing.

1. **Quality Trimming**  
   Performed with `cutadapt`, trimming the ends of reads below a quality score of 20.
2. **Demultiplexing**  
   Conducted with `cutadapt`, using REV primers and barcodes.
3. **Gene Prediction**  
   Utilized HMMER with the `tufA_DB_alignment.hmm` model to predict the tufA gene, filtering sequences to a minimum length of 600 bp.
4. **Relabeling and Merging**  
   Relabeled samples using `sed` and merged them into a single FASTA file.
5. **Dereplication**  
   Executed with `vsearch` to remove duplicate reads.
6. **Sorting**  
   Sorted reads by size using `vsearch`.
7. **Clustering**  
   Conducted clustering with `vsearch` at varying identity thresholds (0.99 to 0.91).
8. **Chimera Detection & OTU Table Construction**  
   Identified chimeras and generated the OTU table using a custom script (`vsearch_uchime_and_map.sh`).
9. **Reference Matching**  
   Performed with `vsearch` using the tufA_DB_v2.fasta database to find best matches at 80% identity.


References:
- [cutadapt](https://cutadapt.readthedocs.io/en/stable/), Martin M. Cutadapt removes adapter sequences from high-throughput sequencing reads. EMBnet.journal 17:10-12 (2011)
- [HMMER](http://hmmer.org/), Eddy SR. Accelerated profile HMM searches. PLoS Comput Biol. 7:e1002195 (2011)
- [SeqKit](https://bioinf.shenwei.me/seqkit/), Shen W, et al. SeqKit: A Cross-Platform and Ultrafast Toolkit for FASTA/Q File Manipulation. PLoS ONE 11:e0163962 (2016)
- [vsearch](https://github.com/torognes/vsearch), Rognes T, et al. VSEARCH: a versatile open source tool for metagenomics. PeerJ 4:e2584 (2016)


### Quality trimming of the raw reads
To remove low-quality reads, we use the `cutadapt` tool. The following command removes reads with a quality score lower than 20 on both ends of the reads:
```bash
cutadapt -q 20,20 -o output.fastq input.fastq
```
Raw reads in: 
After quality trimming:

### Demultiplexing
The demultiplexing is done using the `cutadapt` tool. The following command demultiplexes the samples using the REV primers and barcodes:
```bash
cutadapt -g file:REV.barcodes.fasta -o output.fasta <trimmed.reads.input>
```

### Gene prediction
Use hmm to find the tufA gene, and set the minimum length to 600bp.  
HMMER, and SeqKit are needed to run this script.
And you need the tufA_DB_alignment.hmm model based on the tufA gene (in the script folder).
```bash
HMM=tufA_DB_alignment.hmm
REF=$1 # input file
STR=$(echo $REF | sed 's/.fasta//')
echo "# Predicting gene"

# Run nhmmer to search the reference sequence file using the HMM model
# - --cpu $SLURM_CPUS_PER_TASK: Use the specified number of CPU cores
# - -A "$STR".tufA_out.sto: Output the alignment in Stockholm format
# - $HMM: The HMM model file
# - $REF: The reference sequence file (input file)
nhmmer --cpu $SLURM_CPUS_PER_TASK -A "$STR".tufA_out.sto $HMM $REF

# Convert the Stockholm format output to FASTA format
# - -d fasta: Specify the output format as FASTA
# - "$STR".tufA_out.sto: The input Stockholm format file
# - > "$STR".tufA_out.fasta: Redirect the output to a new FASTA file
esl-reformat -d fasta "$STR".tufA_out.sto > "$STR".tufA_out.fasta

# Remove the intermediate Stockholm format file to save space
rm "$STR".tufA_out.sto

# Filter the FASTA file to retain sequences that are at least 600 base pairs long
# - -m 600: Minimum sequence length of 600 base pairs
# - "$STR".tufA_out.fasta: The input FASTA file
# - > "$STR".tufA_out_600.fasta: Redirect the output to a new FASTA file
seqkit seq -m 600 "$STR".tufA_out.fasta > "$STR".tufA_out_600.fasta
```

### Relabeling the samples, and merging the reads
```bash
for file in REV*.fasta; 
do
    sample=$(basename $file .fasta)
    echo "Processing file: $file"
    sed "s/^>/>$sample|/" $file > ${sample}.labeled.fasta
done
cat *.labeled.fasta > all_samples.fasta
```


### Dereplicating the reads
```bash
vsearch --derep_fulllength all_samples.fasta --output all_samples_derep.fasta --sizeout --relabel_sha1
``` 

### Sorting the reads
```bash
vsearch --sortbysize all_samples_derep.fasta --output all_samples_sorted.fasta
``` 

### Clustering the reads
See the script called [vsearch_cluster.sh](scripts/vsearch_cluster.sh) for the commands used to cluster the reads. The script is run as follows:
```bash
for i in 0.99 0.98 0.97 0.96 0.95 0.94 0.93 0.92 0.91;
./vsearch_cluster.sh all_samples_sorted.fasta $i
done
```

### Chimera detection,and making the OTU table
See the script called [vsearch_uchime_and_map.sh](scripts/vsearch_uchime_and_map.sh) for the commands used to detect chimeras and make the OTU table. The script can be run as follows:
```bash
for i in 0.99 0.98 0.97 0.96 0.95 0.94 0.93 0.92 0.91; do
sbatch vsearch_uchime_and_map.slurm $i;
done
``` 
### use vsearch-global to find the best match in the reference database
```bash
REF=all_samples_sorted.cluster_0.95.non-chim.fasta
DB=tufA_DB_v2.fasta
vsearch --usearch_global $REF --db $DB --blast6out $REF.tufDB_v2.0.80.tab --thread $SLURM_CPUS_PER_TASK --id 0.8
```


### Clustering and chimera detection reports

The clustering resulted in 30122 clusters with an average size of 23.6 reads per cluster. The clustering also identified 15742 chimeric OTUS (52.3%) and 13823 non-chimeric OTUS (45.9%). These OTUs represent 2.9% and 97.0% of the total reads, respectively. 

```bash
######################
VSEARCH Clustering Report
Reference file: all_samples_sorted.fasta
Cluster identity threshold: 0.95
Output project name: cluster_0.95
######################
vsearch v2.25.0_linux_x86_64, 188.0GB RAM, 80 cores
https://github.com/torognes/vsearch

Reading file all_samples_sorted.fasta 100%
615936173 nt in 710595 seqs, min 600, max 967, avg 867
Masking 100%
Sorting by abundance 100%
Counting k-mers 100%
Clustering 100%
Sorting clusters 100%
Writing clusters 100%
Clusters: 30122 Size min 1, max 621339, avg 23.6
Singletons: 26928, 3.8% of seqs, 89.4% of clusters
```


```bash
######################
VSEARCH Chimera Report
Cluster identity threshold: 0.95
######################
vsearch v2.25.0_linux_x86_64, 188.0GB RAM, 80 cores
https://github.com/torognes/vsearch

Reading file all_samples_sorted.cluster_0.95.fasta 100%
25369088 nt in 30122 seqs, min 600, max 967, avg 842
Masking 100%
Sorting by abundance 100%
Counting k-mers 100%
Detecting chimeras 100%
Found 15742 (52.3%) chimeras, 13823 (45.9%) non-chimeras,
and 557 (1.8%) borderline sequences in 30122 unique sequences.
Taking abundance information into account, this corresponds to
23520 (2.9%) chimeras, 793192 (97.0%) non-chimeras,
and 970 (0.1%) borderline sequences in 817682 total sequences.
vsearch v2.25.0_linux_x86_64, 188.0GB RAM, 80 cores
https://github.com/torognes/vsearch
```

