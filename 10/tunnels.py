from enum import Enum

class Direction(Enum):
    NORTH = 0
    EAST = 1
    SOUTH = 2
    WEST = 3

    def print(self):
        print(self)

    def next_clockwise(self):
        cls = self.__class__
        members = list(cls)
        index = members.index(self) + 1
        if index >= len(members):
            index = 0
        return members[index]

    def valid_exits(self):
        match self:
            case Direction.NORTH:
                return "|7F"
            case Direction.EAST:
                return "-J7"
            case Direction.SOUTH:
                return "|JL"
            case Direction.WEST:
                return "-FL"

    def exit_direction(self, node):
        match self:
            case Direction.NORTH:
                match node:
                    case "|":
                        return Direction.NORTH
                    case "7":
                        return Direction.WEST
                    case "F":
                        return Direction.EAST
            case Direction.EAST:
                match node:
                    case "-":
                        return Direction.EAST
                    case "J":
                        return Direction.NORTH
                    case "7":
                        return Direction.SOUTH
            case Direction.SOUTH:
                match node:
                    case "|":
                        return Direction.SOUTH
                    case "L":
                        return Direction.EAST
                    case "J":
                        return Direction.WEST
            case Direction.WEST:
                match node:
                    case "-":
                        return Direction.WEST
                    case "L":
                        return Direction.NORTH
                    case "F":
                        return Direction.SOUTH
        return None

def next_coordinate(xy, direction):
    x,y = xy
    if direction == Direction.NORTH and y>0:
        y = y - 1
        return x,y
    if direction == Direction.EAST and x<len(sketch[0]):
        x = x + 1
        return x,y
    if direction == Direction.SOUTH and y<len(sketch):
        y = y + 1
        return x,y
    if direction == Direction.WEST and x>0:
        x = x - 1
        return x,y
    return None

sketch=[]

def get_node(xy):
    x,y = xy
    return sketch[y][x]

def find_exit(xy, start_dir=Direction.NORTH):
    direction = start_dir
    while True:
        nextxy = next_coordinate(xy, direction)
        print(direction, nextxy)
        if nextxy:
            exits = direction.valid_exits()
            if exits.find(get_node(nextxy)) >= 0:
                return nextxy,direction
        direction = direction.next_clockwise()
        if direction == start_dir:
            return None

def next_on_path(xy, entry_direction):
    node = get_node(xy)
    direction = entry_direction.exit_direction(node)
    nextxy = next_coordinate(xy, direction)
    return nextxy,direction

with open("input.txt") as file:
    sketch = file.read().splitlines()

print(sketch)

# Find start position
for y in range(len(sketch)):
    x=sketch[y].find("S")
    if x>=0:
        break

start = x,y
print(start)

path,direction = find_exit(start)
print(path, direction)
distance = 1
while path != start:
    print(path,direction,distance)
    distance += 1
    path,direction = next_on_path(path, direction)
print("Max distance: ",distance//2)


