// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import "forge-std/Script.sol";
import {CollateralManagerImplementation} from
    "../../src/Aggregators/CollateralManager/CollateralManagerImplementation.sol";

contract DeployCollateralManagerImplementation is Script {
    function run() external {
        vm.startBroadcast();

        CollateralManagerImplementation collateralManagerImplementation = new CollateralManagerImplementation();
        console.log("CollateralManagerImplementation deployed at:", address(collateralManagerImplementation));

        vm.stopBroadcast();
    }
}
