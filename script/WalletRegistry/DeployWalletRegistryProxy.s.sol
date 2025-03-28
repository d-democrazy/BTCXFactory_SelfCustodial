// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import {WalletRegistryProxy} from "../../src/Aggregators/WalletRegistry/WalletRegistryProxy.sol";
import {WalletRegistryImplementation} from "../../src/Aggregators/WalletRegistry/WalletRegistryImplementation.sol";
import {DevOpsTools} from "../../lib/foundry-devops/src/DevOpsTools.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployWalletRegistryProxy is Script {
    function run() external {
        vm.startBroadcast();

        bytes memory initData = HelperConfig.encodeInitializeCall(msg.sender);
        console.logBytes("initData");

        uint256 chainId = block.chainid;
        address implementationAddress = DevOpsTools.get_most_recent_deployment("WalletRegistryImplementation", chainId);
        console.log("Using implementation at:", implementationAddress);

        WalletRegistryProxy proxy = new WalletRegistryProxy(implementationAddress, initData);
        console.log("WalletRegistryProxy deployed at:", address(proxy));

        vm.stopBroadcast();
    }
}
