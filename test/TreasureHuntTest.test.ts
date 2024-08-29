import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import {ethers} from "hardhat";

describe("Treasure Hunt Test Cases", function () {
  let treasureHunt:any;
  let owner:any;

  describe("Deployment of Contract", function () {
    before(async () =>{
        [owner] = await ethers.getSigners();
        const TreasureHunt = await ethers.getContractFactory("TreasureHunt");
        treasureHunt = await TreasureHunt.deploy();
        await treasureHunt.waitForDeployment();
    });

    describe("Testcases: ", function (){
      it("Should set initial treasure position", async function () {
        const treasurePosition = await treasureHunt.treasurePosition();
        expect(treasurePosition).to.be.within(0, 99);
      });
      it("Should allow player to join and move", async function () {
        await treasureHunt.joinAndMove(1,{value:"10000000000000000"});//position 10
        const playerPosition = await treasureHunt.playerPositions(owner.address);
        expect(playerPosition).to.equal(10);
      });
    
      it("Should move treasure when player moves and lands on a multiple of 5", async function () {
        const initialTreasurePosition = await treasureHunt.treasurePosition();
        await treasureHunt.joinAndMove(1,{value:"10000000000000000"}); //position 20
        const newTreasurePosition = await treasureHunt.treasurePosition();
        expect(newTreasurePosition).to.not.equal(initialTreasurePosition);
        expect(newTreasurePosition).to.be.oneOf([initialTreasurePosition-1n,initialTreasurePosition+1n,initialTreasurePosition-10n,initialTreasurePosition+10n])
      });
    
      it("Should move treasure when player moves and lands on a prime number", async function () {
        await treasureHunt.joinAndMove(1,{value:"10000000000000000"}); //position 30
        const initialTreasurePosition = await treasureHunt.treasurePosition();
        await treasureHunt.joinAndMove(2,{value:"10000000000000000"}); // position 29
        const newTreasurePosition = await treasureHunt.treasurePosition();
        expect(newTreasurePosition).to.not.equal(initialTreasurePosition);
      });
    
      it("Should allow player to win", async function () {
        let balBeforeUser = await ethers.provider.getBalance(owner.address);

        await treasureHunt.joinAndMove(1,{value:"10000000000000000"}); // position 39
        await treasureHunt.joinAndMove(1,{value:"10000000000000000"}) // position 49
        await treasureHunt.joinAndMove(1,{value:"10000000000000000"}) // position 59
        await treasureHunt.joinAndMove(1,{value:"10000000000000000"}) // position 69
        await treasureHunt.joinAndMove(2,{value:"10000000000000000"}) // position 68
        await treasureHunt.joinAndMove(2,{value:"10000000000000000"}) // position 67
        let balAfterUser = await ethers.provider.getBalance(owner.address);
        expect(ethers.toBigInt(balBeforeUser)).to.lessThan(ethers.toBigInt(balAfterUser));
      });
    });
  });
});
