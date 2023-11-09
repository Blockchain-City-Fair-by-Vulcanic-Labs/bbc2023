// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
//        AVATAR CONTRACT
//    (c) Vulcanic Labs 2023
//
// ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡠⠀⡄⢠⠀⢄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
// ⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⣶⠟⢠⣾⡇⢸⣷⡄⠻⣶⣤⡀⠀⠀⠀⠀⠀⠀⠀⠀
// ⠀⠀⠀⠀⠀⠀⠀⠚⠛⠛⠃⠐⠛⠛⠃⠘⠛⠛⠂⠘⠛⠛⠓⠀⠀⠀⠀⠀⠀⠀
// ⠀⠀⠀⢻⠏⢠⣿⣷⡄⠹⣿⠋⣠⣶⣿⣿⣶⣄⠙⣿⠏⢠⣾⣿⡄⠹⡟⠀⠀⠀
// ⠀⠀⠀⠀⠀⠙⠛⣛⠋⠀⠋⠀⠛⠛⠛⠛⠛⠛⠀⠙⠀⠙⣛⠛⠋⠀⠀⠀⠀⠀
// ⠀⠀⠀⠀⠀⠀⠀⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠀⠀⠀⠀⠀⠀⠀
// ⠀⠀⠀⠀⠀⠀⠀⣿⠀⠀⢠⣾⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠀⠀⢠⣾⣦⠀⠀
// ⠀⠀⠀⠀⢀⣀⣀⣉⣀⣴⣿⠋⠙⠃⠀⠀⠀⠀⠀⢀⣀⣀⣉⣀⣴⣿⠋⠙⠃⠀
// ⠀⢰⡟⢠⣿⣿⣿⣿⣿⢿⣿⠀⠀⠀⠀⠀⢠⡟⢠⣿⣿⣿⣿⣿⢿⣿⠀⠀⠀⠀
// ⠀⠘⠃⢸⡿⠀⠀⣀⠀⠀⠹⡇⠀⠀⠀⠀⠘⠃⢸⡿⠀⠀⣀⠀⠀⠹⡇⠀⠀⠀
// ⠀⠀⠀⠘⠃⠀⠀⣿⠀⠀⠀⠑⠀⠀⠀⠀⠀⠀⠘⠃⠀⠀⣿⠀⠀⠀⠙⠀⠀⠀
// ⠀⠀⠀⠀⢤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⡤⠀⠀⠀⠀
// ⠀⠀⢰⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⡆⠀⠀
// ⠀⠀⠈⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠁⠀⠀
//		Blockchain City Fair
// Bicol Blockchain Conference 2023
//

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/*
* @dev attachments for each minted avatar is tracked
* via binary-toggling (0 = unequipped, 1 = equipped)
* 
* Avatar Attachments: MSB 000 LSB
* 001 Fez
* 010 Tattoo
* 100 Wings
*
* Example:
* 101 Fez + Wings, but no Tattoo
*/
contract Avatar is ERC721, AccessControl, Ownable {
	string private avatarBaseURI = "";
	mapping(address => uint256) attachments;

	// Roles
	bytes32 public constant SUPPORT_ROLE = keccak256("SUPPORT_ROLE");

	// Modifiers
	modifier forSupport {
		require(hasRole(SUPPORT_ROLE, msg.sender), "Caller is not a privileged support member");
		_;
	}
	
	constructor(string memory _avatarBaseURI ) ERC721("Bicol Avatar", "BVTR") Ownable(address(msg.sender)) {
		avatarBaseURI = _avatarBaseURI;
	}

	function _getMessageHash(string memory message) internal pure returns (bytes32) {
		return keccak256(abi.encodePacked(message));
	}

	function _getEthSignedMessageHash(bytes32 messageHash) pure internal returns (bytes32) {
		return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
	}

	function _split(bytes memory signature) internal pure returns (bytes32 r, bytes32 s, uint8 v) {
		require(signature.length == 65, "Invalid signature length");

		assembly {
			r := mload(add(signature, 32))
			s := mload(add(signature, 64))
			v := byte(0, mload(add(signature, 96)))
		}
	}

	function _recover(bytes32 ethSignedMessageHash, bytes memory signature) pure internal returns (address) {
		(bytes32 r, bytes32 s, uint8 v) = _split(signature);
		return ecrecover(ethSignedMessageHash, v, r, s);
	}



	function _verifySignature(address signer, string memory message, bytes memory signature) internal pure returns (bool) {
		bytes32 messageHash = _getMessageHash(message);
		bytes32 ethSignedMessageHash = _getEthSignedMessageHash(messageHash);

		return _recover(ethSignedMessageHash, signature) == signer;
	}

	function claim(uint256 tokenId, uint256 bitwiseOrMask, address signer, string memory message, bytes memory signature) public {
		// make sure it's verified by the booth with a signed message
		require(_verifySignature(signer, message, signature), "Claim not verified by booth");
		// equip a certain attachment
		require(_ownerOf(tokenId) == msg.sender, "You're not the owner of this token");
		attachments[msg.sender] = attachments[msg.sender] | bitwiseOrMask;
	}

	function reconfigure(address to, uint256 tokenId, uint256 configuration) public forSupport {
		require(_ownerOf(tokenId) == to, "User is not the owner of this token");
		attachments[to] = configuration;
	}

	// function transferOwnership() public forSupport {}

	/*
	* @dev only Owner can mint more Avatars into existence
	*/
	function mint(uint256 tokenId) public onlyOwner {
		_safeMint(msg.sender, tokenId);
	}

	function mintAndTransfer(address to, uint256 tokenId) public onlyOwner {
		_safeMint(to, tokenId);
	}

	function _baseURI() internal view override returns (string memory) {
		return avatarBaseURI;
	}

	function setBaseURI(string memory _avatarBaseURI) public onlyOwner {
		avatarBaseURI = _avatarBaseURI;
	}

	/*
	* @dev there is only 1 base image
	*/
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
		return _baseURI();
    }

	/*
	* @dev overrides both from ERC721 and AccessControl
	*/
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
