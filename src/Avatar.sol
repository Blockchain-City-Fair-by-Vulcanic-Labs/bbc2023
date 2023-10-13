// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Avatar is ERC721, Ownable {
	string private avatarBaseURI = "";
	
	constructor(string memory _avatarBaseURI ) ERC721("Avatar", "AVTR") Ownable(address(msg.sender)) {
		avatarBaseURI = _avatarBaseURI;
	}

	function mint(address to, uint256 tokenId) public onlyOwner {
		_safeMint(to, tokenId);
	}

	function setBaseURI(string memory _avatarBaseURI) public onlyOwner {
		avatarBaseURI = _avatarBaseURI;
	}

	function _baseURI() internal view override returns (string memory) {
		return avatarBaseURI;
	}
}
