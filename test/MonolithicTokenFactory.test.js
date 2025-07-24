const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MonolithicTokenFactory", function (){
  beforeEach(async function(){
    [this.deployer, this.user1, this.user2] = await ethers.getSigners();
    const Factory = await ethers.getContractFactory("MonolithicTokenFactory");
    this.factory = await Factory.deploy("uri/");
    await this.factory.deployed();
  });

  it("mirrors ERC20 balances", async function(){
    const tx = await this.factory.deployERC20("Tok20", "TK20", 1000);
    const receipt = await tx.wait();
    const event = receipt.events.find(e => e.event === "ERC20Deployed");
    const id = event.args.id;
    const tokenAddress = event.args.token;
    const token = await ethers.getContractAt("ERC20Wrapper", tokenAddress);

    expect(await token.balanceOf(this.deployer.address)).to.equal(1000);
    expect(await this.factory.balanceOf(this.deployer.address, id)).to.equal(1000);

    await token.transfer(this.user1.address, 200);
    expect(await this.factory.balanceOf(this.deployer.address, id)).to.equal(800);
    expect(await this.factory.balanceOf(this.user1.address, id)).to.equal(200);
  });

  it("mirrors ERC721 balances", async function(){
    const tx = await this.factory.deployERC721("Tok721", "TK721");
    const receipt = await tx.wait();
    const event = receipt.events.find(e => e.event === "ERC721Deployed");
    const id = event.args.id;
    const tokenAddress = event.args.token;
    const token = await ethers.getContractAt("ERC721Wrapper", tokenAddress);
    const SHIFT = ethers.BigNumber.from(2).pow(128);

    const mintTx = await token.mint(this.deployer.address);
    const mintReceipt = await mintTx.wait();
    const tokenId = mintReceipt.events.find(e => e.event === "Transfer").args.tokenId;
    const id1155 = ethers.BigNumber.from(id).shl(128).or(tokenId);

    expect(await this.factory.balanceOf(this.deployer.address, id1155)).to.equal(1);

    await token["safeTransferFrom(address,address,uint256)"](this.deployer.address, this.user1.address, tokenId);
    expect(await this.factory.balanceOf(this.deployer.address, id1155)).to.equal(0);
    expect(await this.factory.balanceOf(this.user1.address, id1155)).to.equal(1);
  });

  it("mirrors ERC1155 balances", async function(){
    const tx = await this.factory.deployERC1155("uri/");
    const receipt = await tx.wait();
    const event = receipt.events.find(e => e.event === "ERC1155Deployed");
    const id = event.args.id;
    const tokenAddress = event.args.token;
    const token = await ethers.getContractAt("ERC1155Wrapper", tokenAddress);
    const tokenId = 1;
    const amount = 5;

    await token.mint(this.deployer.address, tokenId, amount);
    const id1155 = ethers.BigNumber.from(id).shl(128).or(tokenId);
    expect(await this.factory.balanceOf(this.deployer.address, id1155)).to.equal(amount);

    await token.safeTransferFrom(this.deployer.address, this.user1.address, tokenId, 2, "0x");
    expect(await this.factory.balanceOf(this.deployer.address, id1155)).to.equal(3);
    expect(await this.factory.balanceOf(this.user1.address, id1155)).to.equal(2);
  });
});
