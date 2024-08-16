#!/bin/sh
module purge

set -o errexit
set -o nounset

START=$(date +%s)
echo "###################################################"
echo "# Started: "
echo "#     $(date)" 
echo "###################################################"
echo ""

# HMMER, Easel library, and SeqKit is needed to runs this script



# HMM=/cluster/work/users/anderkkr/135_piotr/09_hmm/tufA_DB_alignment.hmm
HMM=/cluster/projects/nn9725k/Programmer/databases/tufA_db/tufA_DB_alignment.hmm
REF=$1

echo "###############"
echo "Processing $REF "

STR=$(echo $REF | sed 's/.fasta//')
echo "# Predicting gene"

nhmmer --cpu $SLURM_CPUS_PER_TASK -A "$STR".tufA_out.sto $HMM $REF
esl-reformat -d fasta "$STR".tufA_out.sto > "$STR".tufA_out.fasta
rm "$STR".tufA_out.sto;
/cluster/projects/nn9725k/Programmer/seqkit seq -m 300 "$STR".tufA_out.fasta > "$STR".tufA_out_300.fasta;

# Computing runtime
secs=$(($(date +%s)-$START))
echo ""
echo "######################"
echo "Script finished: "
echo "    $(date)"
echo "Running time:"
printf '%dd:%dh:%02dm:%02ds\n' $(($secs/86400)) $(($secs%86400/3600)) $(($secs%3600/60)) $(($secs%60)) 
echo "######################"

