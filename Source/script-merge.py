def read_blocks(file):
 block = []
 for line in file:
  if line.startswith('new entry'):
      if block:
          yield block[0], block
      block = [line]
  else:
      block.append(line)
 if block:
  yield block[0], block

with open("P6-Gustav-Character.txt", "r") as file1, open("P6-GustavDev-Character.txt", "r") as file2, open("P6-Shared-Character.txt", "r") as file3, open("P6-SharedDev-Character.txt", "r") as file4:
 file1_dict = dict(read_blocks(file1))
 file2_dict = dict(read_blocks(file2))
 file3_dict = dict(read_blocks(file3))
 file4_dict = dict(read_blocks(file4))

merged_dict = {**file1_dict, **file2_dict, **file3_dict, **file4_dict}
sorted_entries = sorted(merged_dict.keys())

with open("merged_file_p6.txt", "w") as merged_file:
 for entry in sorted_entries:
    merged_file.write(''.join(merged_dict[entry]))

