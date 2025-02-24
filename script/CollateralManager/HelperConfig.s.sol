// SPDX-License-Identifier: MIT

/**
 * 1. Deploy collateral testenet adresses when on Core testnet.
 * 2. Deploy collateral mainnet addresses when on Core mainnet.
 */
pragma solidity ^0.8.18;

import {Vm} from "forge-std/Vm.sol";

library HelperConfig {
    Vm public constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    struct NetworkConfig {
        address[] collateralAddress;
    }

    function getCoreTestnetConfig() internal view returns (NetworkConfig memory) {
        address[] memory collateralAddress = new address[](2);
        collateralAddress[0] = vm.envAddress("WCORE");
        collateralAddress[1] = vm.envAddress("stCORE");

        return NetworkConfig(collateralAddress);
    }

    function getCoreMainnetConfig() internal view returns (NetworkConfig memory) {
        address[] memory collateralAddress = new address[](6);
        collateralAddress[0] = vm.envAddress("solvBTCb");
        collateralAddress[1] = vm.envAddress("solvBTCm");
        collateralAddress[2] = vm.envAddress("oBTC");
        collateralAddress[3] = vm.envAddress("aBTC");
        collateralAddress[4] = vm.envAddress("suBTC");
        collateralAddress[5] = vm.envAddress("stBTC");

        return NetworkConfig(collateralAddress);
    }

    function getAllowedCollaterals(uint256 chainId) internal view returns (address[] memory) {
        if (chainId == vm.envUint("CORE_TESTNET_CHAINID")) {
            return getCoreTestnetConfig().collateralAddress;
        } else if (chainId == vm.envUint("CORE_MAINNET_CHAINID")) {
            return getCoreMainnetConfig().collateralAddress;
        } else {
            revert("Unsupported chain");
        }
    }
}
