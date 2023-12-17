def extract_blocks(input_filename, output_filename):
    with open(input_filename, 'r') as infile, open(output_filename, 'w') as outfile:
        block = []
        new_entry_value = None
        write_block = False
        for line in infile:
            if line.startswith('new entry'):
                if write_block:
                    outfile.write('\n'.join(block) + '\n\n')
                new_entry_value = line.split('"')[1]
                block = [line.rstrip()]
                write_block = False
            elif line.startswith('type '):
                block.append(line.rstrip())
            elif line.startswith('using '):
                block.append('using "{}"'.format(new_entry_value))
            elif line.startswith('data "Passives"'):
                passives = line.split('"')[3]
                if passives.startswith('CX_'):
                    write_block = True
                block.append(line.rstrip())
        if write_block:
            outfile.write('\n'.join(block) + '\n\n')

extract_blocks('Character-raw.txt', 'Character.txt')
