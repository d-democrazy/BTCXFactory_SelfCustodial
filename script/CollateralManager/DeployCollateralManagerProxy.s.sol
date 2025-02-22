// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {CollateralManagerProxy} from "../../src/Aggregators/CollateralManager/CollateralManagerProxy.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract DeployCollateralManagerProxy is Script {
    function run() external returns (address) {
        address proxy = deployCollateralManagerProxy();
        return proxy;
    }

    function deployCollateralManagerProxy() public returns (address) {
        vm.startBroadcast();
    }
}
