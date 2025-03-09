// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import {CollateralManagerProxy} from "../../src/Aggregators/CollateralManager/CollateralManagerProxy.sol";
import {CollateralManagerImplementation} from
    "../../src/Aggregators/CollateralManager/CollateralManagerImplementation.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {DevOpsTools} from "../../lib/foundry-devops/src/DevOpsTools.sol";

contract DeployCollateralManagerProxy is Script {
    function run() external {
        vm.startBroadcast();

        // Log allowed collateral addresses
        address[] memory allowedCollaterals = HelperConfig.getAllowedCollaterals(block.chainid);
        console.log("Deploying on network with collateral addresses:");
        for (uint256 i = 0; i < allowedCollaterals.length; i++) {
            console.log("Collateral", i, ":", allowedCollaterals[i]);
        }

        // Retrieve the implementation address via DevOpsTools.
        uint256 chainId = block.chainid;
        address implementationAddress =
            DevOpsTools.get_most_recent_deployment("CollateralManagerImplementation", chainId);
        console.log("Using implementation at:", implementationAddress);

        // Encode initialization data by passing allowedCollaterals to initialize.
        bytes memory initData = HelperConfig.encodeInitializeCall(block.chainid);
        console2.logBytes(initData);

        // Deploy Proxy
        CollateralManagerProxy proxy = new CollateralManagerProxy(implementationAddress, msg.sender, initData);
        console.log("CollateralManagerProxy deployed at:", address(proxy));

        vm.stopBroadcast();
    }
}
