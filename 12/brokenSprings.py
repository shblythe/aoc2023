#import pdb; pdb.set_trace()
from functools import reduce

can_be_dot = "?."
can_be_hash = "?#"

def group_fits_here(group, springs):
    if group > len(springs):
        return False
    for i in range(group):
        if springs[i] not in can_be_hash:
            return False
    return group == len(springs) or springs[group] in can_be_dot

def min_size_needed(groups):
    return sum(groups) + len(groups)-1

def min_groups(spring_text):
    groups=1
    spring_text = spring_text.strip('.')
    last_dot=False
    for c in spring_text:
        if c=='.':
            if not last_dot:
                groups+=1
                last_dot = True
        else:
            last_dot = False
    return groups

# Generate ways of arranging the groups in an empty space of this size
def num_valid_ways(groups, springs_text, start=0):
    size = len(springs_text)
    if len(groups) == 0:
        return 1
    # if there n . in the text, then we need n+1 groups, otherwise 0
    print(">>>",groups,springs_text[start:],len(groups),springs_text[start:].count('.')+1)
    if len(groups) < min_groups(springs_text[start:]):
        print(">>> passed")
        return 0
    if min_size_needed(groups) > size:
        return 0
    group = groups[0]
    total_ways = 0
    for i in range(start, size):
        # Group can only be here if the previous char can be a space
        #print(i, springs_text[i-1])
        if i>0 and springs_text[i-1] not in can_be_dot:
            continue
        #print(f"checking {group}, {springs_text[i:]}")
        # if we've only got one group, everything after it must be .
        if len(groups)==1 and '#' in springs_text[i+group:]:
            continue
        if group_fits_here(group, springs_text[i:]):
            #print("fits")
            ways = num_valid_ways(groups[1:], springs_text, i+group+1)
            total_ways += ways
    print(groups, springs_text[start:], total_ways)
    return total_ways

total = 0

with open("test.txt") as file:
    lines=file.read().splitlines()
    for line in lines:
        print("---------------------------------------------")
        [springs_text, groups_text] = line.split(" ")
        groups = [int(num) for num in groups_text.split(",")]
        print(groups)
        # Leading and trailing . make no difference
        springs_text = springs_text.strip('.')
        print(springs_text)
        ways = num_valid_ways(groups, springs_text)
        total += ways
        print(ways)

print("---------------------------------------------")
print(total)
