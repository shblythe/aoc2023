import re

with open("input.txt") as file:
    lines=file.read().splitlines()
    lr_instructions = lines[0]
    map_entries = lines[2:]

re_entry = re.compile(r'(.*) = \((.*), (.*)\)')

map_nodes = {}

for entry in map_entries:
    m = re_entry.match(entry)
    map_nodes[m.group(1)] = (m.group(2), m.group(3))

node = 'AAA'
steps = 0

lr_len = len(lr_instructions)

while node != 'ZZZ':
    i = lr_instructions[steps % lr_len]
    if steps<lr_len:
        print(i, end='')
    if steps==lr_len:
        print()
    if i=='L':
        node = map_nodes[node][0]
    else:
        node = map_nodes[node][1]
    steps += 1

print("Steps: ", steps)

