from math import comb

def calc_sequence_starts(sequence):
    starts = []
    lastDiagonal = []
    currentDiagonal = []
    lastDiff = 1
    # First case
    starts.append(sequence[0])
    lastDiagonal.append(sequence[0])
    for num in sequence[1:]:
        currentDiagonal.append(num)
        for diagIndex in range(len(lastDiagonal)):
            diff = currentDiagonal[diagIndex] - lastDiagonal[diagIndex]
            currentDiagonal.append(diff)
        # print(currentDiagonal)
        starts.append(diff)
        lastDiagonal = currentDiagonal
        currentDiagonal = []
        if diff == 0 and lastDiff == 0:
            break
        lastDiff = diff
    starts = starts[:-2]
    # print(starts)
    return starts

def extrapolate_backwards(starts):
    lastEntry=0
    for entry in reversed(starts):
        entry = entry - lastEntry
        lastEntry = entry
    return entry

def calc_nth_term(starts, n):
    sum = 0
    for i in range(len(starts)):
        sum += comb(n, i) * starts[i]
    return sum

sequences=[]

with open("input.txt") as file:
    lines=file.read().splitlines()
    sequences=[[int(num) for num in line.split(" ")] for line in lines]

total = 0
backwards_total = 0
for sequence in sequences:
    starts = calc_sequence_starts(sequence)
    term=calc_nth_term(starts,len(sequence))
    print(term)
    total += term
    backwards_total += extrapolate_backwards(starts)
print("Total: ", total)
print("Total extrapolated backwards: ", backwards_total)
