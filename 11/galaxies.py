with open("input.txt") as file:
    rows = file.read().splitlines()

emptyCols = []
emptyRows = []
galaxies = []

for x in range(len(rows[0])):
    emptyCols.append(True)

for y,row in enumerate(rows):
    empty = True
    for x,node in enumerate(row):
        if node == '#':
            empty = False
            emptyCols[x] = False
            galaxies.append((x,y))
    emptyRows.append(empty)

print(galaxies)
print(emptyRows)
print(emptyCols)

emptySize = 1000000

sum = 0
for g1, gal1 in enumerate(galaxies):
    for gal2 in galaxies[(g1+1):]:
        base_distance = abs(gal1[0] - gal2[0]) + abs(gal1[1] - gal2[1])
        minCol=min(gal1[0], gal2[0])
        maxCol=max(gal1[0], gal2[0])
        minRow=min(gal1[1], gal2[1])
        maxRow=max(gal1[1], gal2[1])
        emptyColsInRange = emptyCols[minCol:maxCol].count(True) * (emptySize-1)
        emptyRowsInRange = emptyRows[minRow:maxRow].count(True) * (emptySize-1)
        print(gal1,gal2,base_distance,emptyColsInRange,emptyRowsInRange)
        sum += base_distance + emptyColsInRange + emptyRowsInRange

print(sum)
