// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Game {
    string private instructions = "This is a game, you are in a forest. Type 'right' to go deeper or 'left' to try to exit.";
    uint64 private count;
    uint64 private consecutiveRights;
    string private update;
    bool private gameActive;

    // Initialize the game
    constructor() {
        resetGame();
    }

    function resetGame() internal {
        count = 0; // Start with the player not deep in the forest
        consecutiveRights = 0; // Reset consecutive rights
        update = "You are at the entrance of the forest. Choose 'right' or 'left'.";
        gameActive = true; // Game starts active
    }

    function instruction() public view returns (string memory) {
        return instructions;
    }

    function game(string memory _direction) public {
        require(gameActive, "Game is over. Start a new game.");
        
        if (count == 0) {
            if (keccak256(abi.encodePacked(_direction)) == keccak256(abi.encodePacked('right'))) {
                update = "You are going deeper into the forest.";
                count += 1; // Increase count as you go deeper
                consecutiveRights += 1; // Count the consecutive rights
            } else if (keccak256(abi.encodePacked(_direction)) == keccak256(abi.encodePacked('left'))) {
                update = "You have exited the forest!";
                gameActive = false; // End the game
            }
        } else if (count > 0) {
            if (keccak256(abi.encodePacked(_direction)) == keccak256(abi.encodePacked('left'))) {
                update = "Keep going left. You are getting closer to exiting.";
                count -= 1; // Decrease count as you take the correct direction
                consecutiveRights = 0; // Reset consecutive rights
            } else if (keccak256(abi.encodePacked(_direction)) == keccak256(abi.encodePacked('right'))) {
                update = "You are still deep in the forest!";
                count += 1; // Going right takes you deeper
                consecutiveRights += 1; // Count the consecutive rights
                
                // Check for loss condition
                if (consecutiveRights >= 3) {
                    update = "You have gone too deep into the forest and lost the game. Start over!";
                    gameActive = false; // End the game
                }
            }

            // Check if you reached the exit
            if (count == 0) {
                update = "You are successfully out of the forest!";
                gameActive = false; // End the game
            }
        }
    }

    function currentStatus() public view returns (string memory) {
        return update;
    }

    function startNewGame() public {
        resetGame(); // Restart the game
    }
}
