// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/Math.sol";

contract TreasureHunt {
    uint256 public constant gridSize = 10;
    uint public constant overallSize = 100;
    uint256 public treasurePosition; // only for testing made public
    mapping(address => uint256) public playerPositions;
    mapping(address => bool) public players;
    uint256 public contractBalance;
    uint256 public currentGameRound;
    uint256 public lastGameRound;


    uint256 public constant MOVE_FEE = 0.01 ether;
    uint256 public constant WINNER_REWARD_PERCENTAGE = 9000;

    event PlayerJoined(address indexed player);
    event PlayerMoved(address indexed player, uint256 newPosition);
    event TreasureMoved(uint256 newPosition);
    event Winner(address indexed winner, uint256 reward);

    constructor() {
        treasurePosition = uint256(keccak256(abi.encodePacked(block.number))) % (overallSize);
        currentGameRound = 0;
        lastGameRound = 0;
    }

    function joinAndMove(uint256 direction) public payable {
        require(msg.value == MOVE_FEE, "Invalid move fee");

        if (!players[msg.sender]) {
            players[msg.sender] = true;
            playerPositions[msg.sender] = 0; 
            emit PlayerJoined(msg.sender);
        }

        uint256 currentPosition = playerPositions[msg.sender];
        uint256 newPosition = currentPosition;

       if (direction == 0) { 
            if(currentPosition<gridSize){
                revert("Invalid Move");
            }
            newPosition -= gridSize;
        } else if (direction == 1) { 
            if(currentPosition>=(overallSize-gridSize)){
                revert("Invalid Move");
            }
            newPosition += gridSize;
        } else if (direction == 2) { 
            if(currentPosition==0){
                revert("Invalid Move");
            }
            newPosition -= 1;
        } else if (direction == 3) { 
            if(currentPosition==99){
                revert("Invalid Move");
            }
            newPosition += 1;
        }

        require(newPosition >= 0 && newPosition < overallSize, "Invalid move");

        playerPositions[msg.sender] = newPosition;
        contractBalance = address(this).balance;

        if (newPosition == treasurePosition) {
            uint256 reward = (contractBalance * WINNER_REWARD_PERCENTAGE) / 10000;
            payable(msg.sender).transfer(reward);
            emit Winner(msg.sender, reward);

            treasurePosition = uint256(keccak256(abi.encodePacked(block.number))) % (overallSize);
            currentGameRound++;
            playerPositions[msg.sender] = 0;
        }else{
            moveTreasure(newPosition);
            emit PlayerMoved(msg.sender, newPosition);
        }
    }

     function moveTreasure(uint256 playerPosition) internal {
        if (playerPosition % 5 == 0) {
            uint256[] memory adjacentPositions = getAdjacentPositions(treasurePosition);
            treasurePosition = adjacentPositions[uint256(keccak256(abi.encodePacked(block.number))) % adjacentPositions.length];
        } else if (isPrime(playerPosition)) {
            treasurePosition = uint256(keccak256(abi.encodePacked(block.number))) % (overallSize);
        }
        emit TreasureMoved(treasurePosition);
    }

    function getAdjacentPositions(uint256 position) internal view returns (uint256[] memory) {
        if(treasurePosition==0){
                uint256[] memory adjacentPositions = new uint256[](2); 
                adjacentPositions[0] = position + gridSize; 
                adjacentPositions[1] = position + 1;
                return adjacentPositions;
        }
        if(treasurePosition==99){
                uint256[] memory adjacentPositions = new uint256[](2);
                adjacentPositions[0] = position - gridSize; 
                adjacentPositions[1] = position - 1; 
                return adjacentPositions;
        }
        if(treasurePosition<gridSize && treasurePosition>0){
                uint256[] memory adjacentPositions = new uint256[](3);
                adjacentPositions[0] = position + gridSize; 
                adjacentPositions[1] = position - 1; 
                adjacentPositions[2] = position + 1;
                return adjacentPositions;
        }
        if(treasurePosition>=(overallSize-gridSize)){
                uint256[] memory adjacentPositions = new uint256[](3);
                adjacentPositions[0] = position - gridSize; 
                adjacentPositions[1] = position - 1; 
                adjacentPositions[2] = position + 1;
                return adjacentPositions;
        }
       else{
                uint256[] memory adjacentPositions = new uint256[](4);
                adjacentPositions[0] = position - gridSize; 
                adjacentPositions[1] = position + gridSize; 
                adjacentPositions[2] = position - 1; 
                adjacentPositions[3] = position + 1;
                return adjacentPositions;
        }
    }

    function isPrime(uint256 number) internal pure returns (bool) {
        if (number <= 1) {
            return false;
        }
        for (uint256 i = 2; i < sqrt(number); i++) {
            if (number % i == 0) {
                return false;
            }
        }
        return true;
    }

    function sqrt(uint256 x) public pure returns (uint256) {
        return Math.sqrt(x);
    }
    receive() external payable { }
    fallback() external payable { }
}