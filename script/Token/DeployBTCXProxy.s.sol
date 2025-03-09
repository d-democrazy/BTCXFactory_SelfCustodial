// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import {BTCXProxy} from "../../src/Token/BTCXProxy.sol";
import {BTCXImplementation} from "../../src/Token/BTCXImplementation.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {DevOpsTools} from "../../lib/foundry-devops/src/DevOpsTools.sol";

contract DeployBTCXProxy is Script {
    function run() external {
        vm.startBroadcast();

        // Passing factory address to minter and burner while msg.sender as pauser and upgrader.
        bytes memory initData = HelperConfig.encodeInitializeCall(msg.sender);
        console.logBytes("initData");

        // Retrive the implementation address via DevOpsTools.
        uint256 chainId = block.chainid;
        address implementationAddress = DevOpsTools.get_most_recent_deployment("BTCXImplementation", chainId);
        console.log("Using implementation at:", implementationAddress);

        // Deploy proxy
        BTCXProxy proxy = new BTCXProxy(implementationAddress, msg.sender, initData);
        console.log("BTCXProxy deployed at:", address(proxy));

        vm.stopBroadcast();
    }
}
