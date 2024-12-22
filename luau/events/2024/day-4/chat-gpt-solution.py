# Reading the input file content
file_path = "./input.txt"
with open(file_path, "r") as file:
    content = file.read()

# Prepare the grid by splitting lines
grid = content.splitlines()


# Function to extract words in all directions
def find_all_words(grid, word):
    word_length = len(word)
    rows = len(grid)
    cols = len(grid[0]) if rows > 0 else 0
    count = 0

    # Check in all 8 possible directions
    directions = [
        (0, 1),  # Right
        (0, -1),  # Left
        (1, 0),  # Down
        (-1, 0),  # Up
        (1, 1),  # Down-Right
        (1, -1),  # Down-Left
        (-1, 1),  # Up-Right
        (-1, -1),  # Up-Left
    ]

    for r in range(rows):
        for c in range(cols):
            for dr, dc in directions:
                # Attempt to extract word in the given direction
                match = True
                for i in range(word_length):
                    nr, nc = r + dr * i, c + dc * i
                    if not (
                        0 <= nr < rows and 0 <= nc < cols and grid[nr][nc] == word[i]
                    ):
                        match = False
                        break
                if match:
                    count += 1

    return count


# Count occurrences of "XMAS"
word_to_find = "XMAS"
xmas_count = find_all_words(grid, word_to_find)

print(xmas_count)
