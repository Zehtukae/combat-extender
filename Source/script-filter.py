def extract_blocks(input_filename, output_filename):
    with open(input_filename, 'r') as infile, open(output_filename, 'w') as outfile:
        block = []
        write_block = False
        for line in infile:
            if line.startswith('new entry'):
                if write_block:
                    outfile.write('\n'.join(block) + '\n\n')
                block = [line.rstrip()]
                write_block = False
            elif line.startswith('type ') or line.startswith('using '):
                block.append(line.rstrip())
            elif line.startswith('data "Passives"'):
                passives = line.split('"')[3]
                if passives.startswith('TX_'):
                    write_block = True
                block.append(line.rstrip())
        if write_block:
            outfile.write('\n'.join(block) + '\n\n')

extract_blocks('Character-raw.txt', 'Character.txt')
