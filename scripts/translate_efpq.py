import sys

# Ensure that the script is executed with two arguments
if len(sys.argv) != 3:
    print("Usage: python process_fasta.py input_file output_file")
    sys.exit(1)

input_file = sys.argv[1]
output_file = sys.argv[2]

with open(input_file) as infile:
    with open(output_file, 'w') as o:
        for line in infile:
            if line.startswith(">"):
                # If the line is a header, write it as is
                o.write(line)
            else:
                # If the line is a sequence, replace specific nucleotides
                seq = line.replace("E", "A").replace("F", "G").replace("Q", "C").replace("P", "T")
                o.write(seq)
