import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";

import { expect } from "chai";
import { ethers } from "hardhat";

describe("ERC6551 Test", function () {
	async function deployFixture() {

		const [owner, otherAccount] = await ethers.getSigners();

		const NewContract = await ethers.getContractFactory("SimpleNFT");
		const nftContract = await NewContract.deploy();
		const NFTB = await ethers.getContractFactory("SimpleNFT");
		const nftB = await NFTB.deploy();
		const Erc6551Contract = await ethers.getContractFactory("ERC6551Registry");
		const erc6551 = await Erc6551Contract.deploy();

		return { nftContract, nftB, erc6551, owner, otherAccount };
	}
	describe("Basic Info", function() {
		it("Should return NFT Info", async function() {
			const { nftContract, owner } = await loadFixture(deployFixture);
		
				expect(await nftContract.symbol()).to.equal("SNFT");
				expect(await nftContract.name()).to.equal("SimpleNFT");

				await nftContract.mint(owner.address);
		});

		it("Shuld return", async function() {
			const { nftContract, nftB, erc6551, owner, otherAccount } = await loadFixture(deployFixture);

			await nftContract.mint(owner.address);
			await nftB.mint(owner.address);
			const nftAddress = await nftContract.getAddress();

			const implementation = "0x55266d75D1a14E4572138116aF39863Ed6596E7F";
			const salt = "0x0000000000000000000000000000000000000000000000000000000000000000";
			const createTBA = await erc6551.createAccount(implementation, salt, 5,  nftAddress, 0);
			const returnTBA = await erc6551.account(implementation, salt, 5,  nftAddress, 0);
			// createTBAにはtxが帰る
			// expect(createTBA).to.equal(returnTBA);
			// console.log(returnTBA);

			// safeTransferFrom(address from, address to, uint256 tokenId);
			// nftBのtokenId0をTBAに送信
			await nftB.transferFrom(owner.address, await erc6551.account(implementation, salt, 5,  nftAddress, 0), 0);
			expect(await nftB.ownerOf(0)).to.equal(returnTBA);

		});
	});
});
