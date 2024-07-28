# tufA Gene Database

This repository contains a curated database of the tufA gene, focusing on entries from various sources, including Sauvage (2016), Marcelino (2017), and additional sequences identified through BLAST hits against Phaeoexplorer and GenBank.

## Contents

1. **Database Structure**
    - The data is provided in a FASTA file format, including gene sequences, accession numbers, and taxonomic lineage information.

2. **Data Cleaning**
    - Duplicate sequences have been removed.
    - Taxonomy has been updated using the `taxonomizr` package in R.

3. **Sources**
    - **Sauvage et al. (2016)**: "A metabarcoding framework for facilitated survey of endolithic phototrophs with tufA," *BMC Ecology*, 16:8, DOI: [10.1186/s12898-016-0068-x](https://doi.org/10.1186/s12898-016-0068-x).
      - Originally 4051 sequences (precleaining)
    - **Marcelino & Verbruggen (2017)**: "Reference datasets of tufA and UPA markers to identify algae in metabarcoding surveys," *Data in Brief*, 11:273-276, DOI: [10.1016/j.dib.2017.02.013](https://doi.org/10.1016/j.dib.2017.02.013).
      - Originally 863 sequences
    - **Phaeoexplorer**: BLAST hits against the Phaeoexplorer database ([Phaeoexplorer](http://phaeoexplorer.sb-roscoff.fr/home/)).
      - 
    - **GenBank**: BLASTed operational taxonomic units (OTUs) against GenBank for comprehensive coverage.
      - Additional 26 sequences from GenBank, 

## Usage

- **Accessing the Data**
    - The FASTA file containing the sequences, accession numbers, and taxonomic lineage is available as `tufA_DB.fasta`.
    - Search the database with `vsearch --usearch_global`, which provides a BLAST-like output. The identity threshold is set to 0.80 in this command. Can be adjusted as needed.
        ```bash
        vsearch --usearch_global query.fasta --db tufA_DB.fasta --id 0.80 --blast6out output.txt --thread <number of threads>
        ```
    - the output columns are:
        - Query sequence ID
        - Subject sequence ID
        - % identity
        - alignment length
        - number of mismatches
        - number of gap openings
        - start of alignment in query
        - end of alignment in query
        - start of alignment in subject
        - end of alignment in subject
        - e-value
        - bit score
- **R Scripts**
    - R scripts for data cleaning and taxonomy updates are available in `clean_db_add_tax.R`.