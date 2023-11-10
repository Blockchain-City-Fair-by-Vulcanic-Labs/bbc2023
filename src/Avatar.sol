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
	// tokenId => attachments
	mapping(uint256 => uint256) public attachments;

	// Roles
	bytes32 public constant SUPPORT_ROLE = keccak256("SUPPORT_ROLE");

	// Modifiers
	modifier onlySupport {
		// either a DEFAULT_ADMIN or SUPPORT team member
		require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender) || hasRole(SUPPORT_ROLE, msg.sender), "Caller is not a privileged support member");
		_;
	}
	
	constructor(string memory _avatarBaseURI ) ERC721("Bicol Avatar", "BVTR") Ownable(address(msg.sender)) {
		avatarBaseURI = _avatarBaseURI;
		_grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
	}

	function claim(uint256 tokenId, uint256 bitwiseOrMask) public {
		// equip a certain attachment
		require(_ownerOf(tokenId) == msg.sender, "You're not the owner of this token");
		attachments[tokenId] = attachments[tokenId] | bitwiseOrMask;
	}

	function reconfigure(address user, uint256 tokenId, uint256 configOrMask) public onlySupport {
		require(_ownerOf(tokenId) == user, "User is not the owner of this token");
		attachments[tokenId] = 0 | configOrMask;
	}

	// function transferOwnership() public onlySupport {}

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
