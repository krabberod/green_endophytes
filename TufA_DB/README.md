# tufA Gene Database

This repository contains a curated database of the tufA gene, focusing on entries from various sources, including Sauvage (2016), Marcelino (2017), and additional sequences identified through BLAST hits against Phaeoexplorer and GenBank.

## Contents

1. **Database Structure**
    - The data is provided in a FASTA file format, including gene sequences, accession numbers, and taxonomic lineage information.

2. **Data Cleaning**
    - Duplicate sequences have been removed.
    - Taxonomy has been updated using the `taxonomizr` package in R.

3. **Sources**
    - **Sauvage et al. (2016)**: "A metabarcoding framework for a facilitated survey of endolithic phototrophs with tufA," *BMC Ecology*, 16:8, DOI: [10.1186/s12898-016-0068-x](https://doi.org/10.1186/s12898-016-0068-x).
      - Originally 4051 sequences (precleaning)
    - **Marcelino & Verbruggen (2017)**: "Reference datasets of tufA and UPA markers to identify algae in metabarcoding surveys," *Data in Brief*, 11:273-276, DOI: [10.1016/j.dib.2017.02.013](https://doi.org/10.1016/j.dib.2017.02.013).
      - Originally 863 sequences
    - **Phaeoexplorer**: BLAST hits against the Phaeoexplorer database ([Phaeoexplorer](http://phaeoexplorer.sb-roscoff.fr/home/)).
      - Additional 51 sequences from Phaeoexplorer (brown algae genomes).
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
### R Scripts
  - R scripts for data cleaning and taxonomy updates are available in `clean_db_add_tax.R`.

## Species list
A list of the taxonomy and the number of species for each is added to the repository as `species_list.tsv`.

I searched for some of the groups we talked about in the meeting 6 August 2024: 
- The genus *Kappaphycus* is only represented by one entry in the database.
``` 
MN240358|Eukaryota;Rhodophyta;Florideophyceae;Gigartinales;Solieriaceae;Kappaphycus;Kappaphycus_striatus
```
- *Phaeophila* is better represented: 
```
KU362151|Eukaryota;Chlorophyta;Chlorophyceae;Phaeophilales;Phaeophilaceae;Phaeophilaceae_X;uncultured_Phaeophilaceae
KU362152|Eukaryota;Chlorophyta;Chlorophyceae;Phaeophilales;Phaeophilaceae;Phaeophilaceae_X;uncultured_Phaeophilaceae
KU362153|Eukaryota;Chlorophyta;Chlorophyceae;Phaeophilales;Phaeophilaceae;Phaeophilaceae_X;uncultured_Phaeophilaceae
KU362154|Eukaryota;Chlorophyta;Chlorophyceae;Phaeophilales;Phaeophilaceae;Phaeophilaceae_X;uncultured_Phaeophilaceae
KU362155|Eukaryota;Chlorophyta;Chlorophyceae;Phaeophilales;Phaeophilaceae;Phaeophilaceae_X;uncultured_Phaeophilaceae
KU362156|Eukaryota;Chlorophyta;Chlorophyceae;Phaeophilales;Phaeophilaceae;Phaeophilaceae_X;uncultured_Phaeophilaceae
KU362157|Eukaryota;Chlorophyta;Chlorophyceae;Phaeophilales;Phaeophilaceae;Phaeophilaceae_X;uncultured_Phaeophilaceae
KU362158|Eukaryota;Chlorophyta;Chlorophyceae;Phaeophilales;Phaeophilaceae;Phaeophilaceae_X;uncultured_Phaeophilaceae
KU362159|Eukaryota;Chlorophyta;Chlorophyceae;Phaeophilales;Phaeophilaceae;Phaeophilaceae_X;uncultured_Phaeophilaceae
KU362160|Eukaryota;Chlorophyta;Chlorophyceae;Phaeophilales;Phaeophilaceae;Phaeophilaceae_X;uncultured_Phaeophilaceae
AY454414|Eukaryota;Chlorophyta;Chlorophyceae;Phaeophilales;Phaeophilaceae;Phaeophila;Phaeophila_dendroides
AY454415|Eukaryota;Chlorophyta;Chlorophyceae;Phaeophilales;Phaeophilaceae;Phaeophila;Phaeophila_dendroides
KU362062|Eukaryota;Chlorophyta;Chlorophyceae;Phaeophilales;Phaeophilaceae;Phaeophila;Phaeophila_sp_TS1583
KJ411922|Eukaryota;Chlorophyta;Chlorophyceae;Phaeophilales;Phaeophilaceae;Phaeophila;Phaeophila_dendroides
AY454416|Eukaryota;Chlorophyta;Chlorophyceae;Phaeophilales;Phaeophilaceae;Phaeophila;Phaeophila_dendroides
AY454413|Eukaryota;Chlorophyta;Chlorophyceae;Phaeophilales;Phaeophilaceae;Phaeophila;Phaeophila_dendroides
MF574043|Eukaryota;Chlorophyta;Chlorophyceae;Phaeophilales;Phaeophilaceae;Phaeophila;Phaeophila_dendroides
```
- The genus *Acrosiphonia*
```
HQ610211|Eukaryota;Chlorophyta;Ulvophyceae;Ulotrichales;Ulotrichaceae;Acrosiphonia;Acrosiphonia_arcta
MW921442|Eukaryota;Chlorophyta;Ulvophyceae;Ulotrichales;Ulotrichaceae;Acrosiphonia;Acrosiphonia_arcta
HQ610218|Eukaryota;Chlorophyta;Ulvophyceae;Ulotrichales;Ulotrichaceae;Acrosiphonia;Acrosiphonia_coalita
HQ610224|Eukaryota;Chlorophyta;Ulvophyceae;Ulotrichales;Ulotrichaceae;Acrosiphonia;Acrosiphonia_sonderi
HQ610236|Eukaryota;Chlorophyta;Ulvophyceae;Ulotrichales;Ulotrichaceae;Acrosiphonia;Acrosiphonia_sp_1GWS
JX572166|Eukaryota;Chlorophyta;Ulvophyceae;Ulotrichales;Ulotrichaceae;Acrosiphonia;Acrosiphonia_sp_6GWS
HQ610221|Eukaryota;Chlorophyta;Ulvophyceae;Ulotrichales;Ulotrichaceae;Acrosiphonia;Acrosiphonia_sonderi
HQ610232|Eukaryota;Chlorophyta;Ulvophyceae;Ulotrichales;Ulotrichaceae;Acrosiphonia;Acrosiphonia_sp_1GWS
JX572165|Eukaryota;Chlorophyta;Ulvophyceae;Ulotrichales;Ulotrichaceae;Acrosiphonia;Acrosiphonia_sp_3GWS
KM255012|Eukaryota;Chlorophyta;Ulvophyceae;Ulotrichales;Ulotrichaceae;Acrosiphonia;Acrosiphonia_cf_coalita_GWS2014
```

