const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ERC1155WithERC20", function () {
  beforeEach(async function () {
    [
      this.deployer,
      this.brand,
      this.minter,
      this.addr1,
      this.addr2,
      this.addr3,
    ] = await ethers.getSigners();
    const Token = await ethers.getContractFactory("ERC1155WithERC20");
    this.token = await Token.deploy("Token", "TKN", "uri/");
    await this.token.deployed();

    await this.token.createBrand(this.brand.address, this.brand.address);
    await this.token.assignTokenToBrand(0, this.brand.address);
    await this.token.assignTokenToBrand(1, this.brand.address);
    await this.token
      .connect(this.brand)
      .grantBrandRole(
        this.brand.address,
        await this.token.BRAND_MINTER_ROLE(),
        this.minter.address
      );
  });

  it("requires brand minter role to mint", async function () {
    expect(await this.token.brandOf(0)).to.equal(this.brand.address);

    await expect(
      this.token.mint(this.addr1.address, 0, 1, "0x")
    ).to.be.revertedWith("ERC1155WithERC20: missing brand minter role");

    await this.token
      .connect(this.minter)
      .mint(this.addr1.address, 0, 1, "0x");
    expect(
      await this.token["balanceOf(address)"](this.addr1.address)
    ).to.equal(1);
  });

  it("mints id 0 as ERC20 and tracks supply", async function () {
    await this.token
      .connect(this.minter)
      .mint(this.addr1.address, 0, 100, "0x");
    expect(await this.token["totalSupply()"]()).to.equal(100);
    expect(await this.token["totalSupply(uint256)"](0)).to.equal(100);
    expect(await this.token["balanceOf(address)"](this.addr1.address)).to.equal(100);
    expect(await this.token["balanceOf(address,uint256)"](this.addr1.address, 0)).to.equal(100);
  });

  it("handles ERC20 transfers and allowances for id 0", async function () {
    await this.token
      .connect(this.minter)
      .mint(this.addr1.address, 0, 100, "0x");

    await this.token.connect(this.addr1).transfer(this.addr2.address, 40);
    expect(await this.token["balanceOf(address)"](this.addr1.address)).to.equal(60);
    expect(await this.token["balanceOf(address)"](this.addr2.address)).to.equal(40);

    await this.token.connect(this.addr1).approve(this.addr2.address, 50);
    expect(await this.token.allowance(this.addr1.address, this.addr2.address)).to.equal(50);

    await this.token.connect(this.addr2).transferFrom(this.addr1.address, this.addr3.address, 30);
    expect(await this.token["balanceOf(address)"](this.addr1.address)).to.equal(30);
    expect(await this.token["balanceOf(address)"](this.addr3.address)).to.equal(30);
    expect(await this.token.allowance(this.addr1.address, this.addr2.address)).to.equal(20);
  });

  it("burns id 0 and updates ERC20 supply", async function () {
    await this.token
      .connect(this.minter)
      .mint(this.addr1.address, 0, 50, "0x");
    await this.token.connect(this.addr1).burn(this.addr1.address, 0, 20);
    expect(await this.token["totalSupply()"]()).to.equal(30);
    expect(await this.token["totalSupply(uint256)"](0)).to.equal(30);
    expect(await this.token["balanceOf(address)"](this.addr1.address)).to.equal(30);
  });

  it("processes non-zero ids as ERC1155 tokens", async function () {
    await this.token
      .connect(this.minter)
      .mint(this.addr1.address, 1, 10, "0x");
    expect(await this.token["totalSupply()"]()).to.equal(0);
    expect(await this.token["totalSupply(uint256)"](1)).to.equal(10);
    expect(await this.token["balanceOf(address,uint256)"](this.addr1.address, 1)).to.equal(10);

    await this.token.connect(this.addr1).safeTransferFrom(this.addr1.address, this.addr2.address, 1, 3, "0x");
    expect(await this.token["balanceOf(address,uint256)"](this.addr1.address, 1)).to.equal(7);
    expect(await this.token["balanceOf(address,uint256)"](this.addr2.address, 1)).to.equal(3);

    await this.token.connect(this.addr1).burn(this.addr1.address, 1, 2);
    expect(await this.token["balanceOf(address,uint256)"](this.addr1.address, 1)).to.equal(5);
    expect(await this.token["totalSupply(uint256)"](1)).to.equal(8);
    expect(await this.token["totalSupply()"]()).to.equal(0);
  });
});

