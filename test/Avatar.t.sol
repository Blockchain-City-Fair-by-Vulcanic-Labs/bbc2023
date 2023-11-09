// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Avatar} from "../src/Avatar.sol";

contract AvatarTest is Test {
    Avatar public nft;
	address constant OWNER = address(1);
	address constant USER = address(2);
	address constant USER2 = address(3);
	address constant USER3 = address(4);

    function setUp() public {
		vm.prank(OWNER);
        nft = new Avatar("");
    }

	function test_OwnerIsDeployer() public {
		assertEq(nft.owner(), OWNER);
	}

	function test_Mint() public {
		vm.prank(OWNER);
		nft.mint(1);
		assertEq(nft.ownerOf(1), OWNER);
	}

	function testFail_MintNotOnwer() public {
		vm.prank(USER);
		nft.mint(1);
		assertEq(nft.ownerOf(1), OWNER);
	}

	function test_mintAndTransfer() public {
		vm.prank(OWNER);
		nft.mintAndTransfer(USER, 1);

		vm.prank(OWNER);
		nft.mintAndTransfer(USER2, 2);

		assertEq(nft.ownerOf(1), USER);
		assertEq(nft.ownerOf(2), USER2);
	}

	function testFail_mintAndTransferSameToken() public {
		vm.prank(OWNER);
		nft.mintAndTransfer(USER, 1);

		vm.prank(OWNER);
		nft.mintAndTransfer(USER2, 1);
	}

	function test_claim() public {
		vm.prank(OWNER);
		nft.mintAndTransfer(USER, 1);

		vm.prank(USER);
		nft.claim(1, 1);

		vm.prank(USER);
		nft.claim(1, 2);

		assertEq(nft.attachments(1), 3);
	}

	function testFail_claimNotOwner() public {
		vm.prank(OWNER);
		nft.mintAndTransfer(USER, 1);

		vm.prank(USER2);
		nft.claim(1, 1);
	}

	function test_grantRole() public {
		vm.startPrank(OWNER);

		nft.grantRole(nft.SUPPORT_ROLE(), USER2);

		assertTrue(nft.hasRole(nft.DEFAULT_ADMIN_ROLE(), OWNER));
		assertTrue(nft.hasRole(nft.SUPPORT_ROLE(), USER2));

		vm.stopPrank();
	}

	function test_reconfigure() public {
		vm.prank(OWNER);
		nft.mintAndTransfer(USER, 1);

		vm.prank(USER);
		nft.claim(1, 3);

		vm.startPrank(OWNER); // start prank
		nft.reconfigure(USER, 1, 4);
		vm.stopPrank(); // end prank

		assertEq(nft.attachments(1), 4);
	}

	function testFail_reconfigureNotSupportTeam() public {
		vm.startPrank(OWNER);
		nft.mintAndTransfer(USER, 1);
		vm.stopPrank();

		vm.prank(USER3);
		nft.reconfigure(USER, 1, 4);
		assertEq(nft.attachments(1), 4);
	}
}
