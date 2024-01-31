#!/bin/bash

# Set the size of the board (width and height)
WIDTH=32
HEIGHT=32

# Initialize an empty board with zeros
board=()
for ((row = 0; row < $HEIGHT; row++)); do
    line=$(printf '0%.0s' $(seq $WIDTH))
    board+=("$line")
done

# Function to print the current state of the board
function print_board
 {
    echo -e "\nCurrent State:\n"
    for ((row = 0; row < $HEIGHT; row++)); do
        line=${board[$row]}
        for ((col = 0; col < $WIDTH; col++)); do
            if [ "${line:$col:1}" == "1" ]; then
                printf "\xE2\x96\x8B" # Print a filled square character
            else
                printf " "
            fi
        done
        echo ""
    done
}

# Function to update the board based on Conway's rules
function update_board {

    new_board=()
    for ((row = 0; row < $HEIGHT; row++)); do
        line=${board[$row]}
        new_line=""
        for ((col = 0; col < $WIDTH; col++)); do
            live_neighbors=$(count_live_neighbors $row $col)
            
            # Check if the cell is alive or dead in the current state
            if [ "${line:$col:1}" == "1" ]; then
                alive=true
            else
		alive=false
            fi
        
            # Apply Conway's rules to determine the new state of the cell
            if $alive && (($live_neighbors == 2)) || (($live_neighbors == 3)); then
                new_line+="1"
            elif $alive && (($live_neighbors == 3)); then
                new_line+="1"
            else
                new_line+="0"
            fi
        done
        
        # Update the board with the new line for this row
        new_board+=("$new_line")
    done
    
    # Replace the old board with the updated board
    board=("${new_board[@]}")
}

# Function to count the number of live neighbors around a cell
function count_live_neighbors {
    local row=$1 col=$2
    ((row == 0)) && ((top = $HEIGHT - 1)) || ((top = row - 1))
    ((row == $HEIGHT - 1)) && ((bottom = 0)) || ((bottom = row + 1))
    ((col == 0)) && ((left = $WIDTH - 1)) || ((left = col - 1))
    ((col == $WIDTH - 1)) && ((right = 0)) || ((right = col + 1))
    
    line_top=${board[$top]}
    line_middle=${board[$row]}
    line_bottom=${board[$bottom]}
    
    # Count the number of live neighbors around the cell
    alive=0
    for i in {0..8}; do
        case $i in
            0) neighbor="${line_top:$left:1}";;   # Top left
            1) neighbor="${line_top:$col:1}";;    # Top
            2) neighbor="${line_top:$right:1}";;  # Top right
            3) neighbor="${line_middle:$left:1}";; # Left
            4) continue;;                          # Middle (skip the cell itself)
            5) neighbor="${line_middle:$right:1}";; # Right
            6) neighbor="${line_bottom:$left:1}";; # Bottom left
            7) neighbor="${line_bottom:$col:1}";;  # Bottom
            8) neighbor="${line_bottom:$right:1}" # Bottom right
        esac
        
        if [ "$neighbor" == "1" ]; then
            ((alive++))
        fi
    done
    
    echo $alive
}

# Function to seed the board with random initial state
function seed_board {
    for ((row = 0; row < $HEIGHT; row++)); do
        line=${board[$row]}
        new_line=""
        
        for ((col = 0; col < $WIDTH; col++)); do
            # Generate a random number between 0 and 1, then convert it to a 0 or 1 with some probability
            rand=$((RANDOM % 2))
            if (($rand == 0 && RANDOM)); then
                new_line+="1"
            else
                new_line+="0"
            fi
        done
        
        # Update the board with the new line for this row
        board[$row]=$new_line
    done
}

# Seed the board with an initial state
seed_board

print_board
echo -e "\nPress Enter to start the simulation..."
read

while true; do
    sleep 0.1
    
    update_board
    clear # Clear the screen
    print_board
done

