#!/bin/sh
# Load input reference file and cluster identity
REF=$1
CLUSTER=$2

# Purge loaded modules and load the required VSEARCH module
module purge
module load VSEARCH/2.25.0-GCC-12.3.0

# Set the number of threads to use
THREADS=$SLURM_CPUS_PER_TASK

# Derive output file name base
STR=$(echo $REF | sed 's/.fasta//')

# Set project name based on cluster identity
PROJ="cluster_${CLUSTER}"

# Print report of input parameters
echo "######################"
echo "VSEARCH Clustering Report"
echo "Reference file: $REF"
echo "Cluster identity threshold: $CLUSTER"
echo "Output project name: $PROJ"
echo "######################"

# Run VSEARCH clustering
vsearch --cluster_size $REF \
    --threads $THREADS \
    --id $CLUSTER \
    --sizeout \
    --sizein \
    --fasta_width 0 \
    --centroids ${STR}.${PROJ}.fasta
