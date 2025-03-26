// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import "forge-std/Script.sol";
import {WalletRegistryImplementation} from "../../src/Aggregators/WalletRegistry/WalletRegistryImplementation.sol";

contract DeployWalletRegistryImplementation is Script {
    function run() external {
        vm.startBroadcast();

        WalletRegistryImplementation walletRegistryImplementation = new WalletRegistryImplementation();
        console.log("WalletRegistryImplementation is deployed at:", address(walletRegistryImplementation));

        vm.stopBroadcast();
    }
}
