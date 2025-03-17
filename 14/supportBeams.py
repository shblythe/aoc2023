import numpy as np

platform=[]

with open("input.txt") as file:
    lines = file.read().splitlines()
    for l,line in enumerate(lines):
        platform.append([])
        for c,col in enumerate(line):
            platform[l].append(col)

num_rows = len(platform)

# Convert into column lists, with North at the beginning of each
platform = np.array(platform).T.tolist()

total_force=0

for column in platform:
    print(column)
    sections=''.join(column).split('#')
    sorted_sections=[''.join(sorted(list(section),reverse=True)) for section in sections]
    sorted_column=list('#'.join(sorted_sections))
    print(sorted_column)
    for rnum,col in enumerate(sorted_column):
        if col=='O':
            total_force += num_rows-rnum

print(total_force)

