# Treasure Hunt Contract (Task)

This project includes a Hardhat project with smart contracts and test cases on a game treasure hunt. The treasure is hidden in a 10x10 grid and the player needs to move UP,DOWN,LEFT,RIGHT to get the treasure. Player needs to send 0.01 ETH when sending his position movement. The collected amount is added to the treasury balance and the winner takes 90% of the contract balance.

### To run test case:

```shell
npx hardhat test
```

### Design and Architecture:
- In this project, I have used keccak256 to encode the block.number and converted to uint256 and doing a mod gives me a random number between 0,99
- I have design a board where the user starts from top at position 0 and can travel to bottom right to position 99.
- Added corner conditions to prevent overflow and underflow of position
- If the user's grid position is between 0 and 9 then the user cannot move UP
- If the user's grid position is between 90 and 99 then the user cannot move DOWN
- If the user's grid position is between 0 then the user cannot move LEFT
- If the user's grid position is between 99 then the user cannot move RIGHT
- Similarly with the position of treasure. With the given conditions the treasure can move. 
- Added corner conditions for the treasure to move only in valid positions and not cross the defined space.

### Improvements:
- We can use either Chainlink VRF or Band Protocol to generate true random number which can remove a vulnerability in the contract. This vulnerability is due to generating random number using blockHash, which can be reproduced to find and calculate treasure position.
