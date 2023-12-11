import re
from math import lcm

with open("input.txt") as file:
    lines=file.read().splitlines()
    lr_instructions = lines[0]
    map_entries = lines[2:]

re_entry = re.compile(r'(.*) = \((.*), (.*)\)')

map_nodes = {}

for entry in map_entries:
    m = re_entry.match(entry)
    map_nodes[m.group(1)] = (m.group(2), m.group(3))

lr_len = len(lr_instructions)

steps_array = []

for startNode in map_nodes.keys():
    if startNode[2] != 'A':
        continue
    node = startNode
    steps = 0
    while node[2] != 'Z':
        i = lr_instructions[steps % lr_len]
        if i=='L':
            node = map_nodes[node][0]
        else:
            node = map_nodes[node][1]
        steps += 1

    print("Steps: ", steps)
    steps_array.append(steps)

steps_lcm = 1

for s in steps_array:
    steps_lcm = lcm(steps_lcm, s)

print(steps_lcm)
