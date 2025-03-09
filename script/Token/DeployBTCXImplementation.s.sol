// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import "forge-std/Script.sol";
import {BTCXImplementation} from "../../src/Token/BTCXImplementation.sol";

contract DeployBTCXImplementation is Script {
    function run() external {
        vm.startBroadcast();

        BTCXImplementation btcxImplementation = new BTCXImplementation();
        console.log("BTCXImplementation deployed at:", address(btcxImplementation));

        vm.stopBroadcast();
    }
}
