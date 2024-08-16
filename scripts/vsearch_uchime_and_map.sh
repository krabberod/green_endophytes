#!/bin/sh

# Set the cluster identity
CLUSTER=$1

# Purge loaded modules and load the required VSEARCH module
module purge
module load VSEARCH/2.25.0-GCC-12.3.0

# Record start time
START=$(date +%s)

# Print report of input parameters
echo "######################"
echo "VSEARCH Clustering Report"
echo "Cluster identity threshold: $CLUSTER"
echo "######################"


vsearch --uchime_denovo all_samples_sorted.cluster_$CLUSTER.fasta --nonchimeras all_samples_sorted.cluster_$CLUSTER.non-chim.fasta --sizein --sizeout --alignwidth 0
vsearch --usearch_global all_samples.fasta --db all_samples_sorted.cluster_$CLUSTER.non-chim.fasta --id $CLUSTER --otutabout otutab.$CLUSTER.tsv


# Compute and display runtime
secs=$(($(date +%s) - $START))
echo ""
echo "######################"
echo "Script finished: "
echo "    $(date)"
echo "Running time:"
printf '%dd:%dh:%02dm:%02ds\n' $(($secs/86400)) $(($secs%86400/3600)) $(($secs%3600/60)) $(($secs%60))
echo "######################"
