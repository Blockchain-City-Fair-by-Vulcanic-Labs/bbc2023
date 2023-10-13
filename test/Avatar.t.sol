// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Avatar} from "../src/Avatar.sol";

contract AvatarTest is Test {
    Avatar public nft;
	address constant USER = address(1);

    function setUp() public {
        nft = new Avatar("");
    }

	function test_Mint() public {
		nft.mint(USER, 1);
		assertEq(nft.ownerOf(1), USER);
	}
}
