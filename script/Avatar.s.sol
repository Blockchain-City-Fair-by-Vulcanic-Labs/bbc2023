// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import "../src/Avatar.sol";

contract AvatarScript is Script {
    function setUp() public {}

    function run() public {
		uint256 deployerPrivateKey = vm.envUint("ANVIL_PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);
		Avatar nft = new Avatar("");
        vm.stopBroadcast();
    }
}
