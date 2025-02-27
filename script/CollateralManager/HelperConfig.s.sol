// SPDX-License-Identifier: MIT

/**
 * 1. Deploy collateral testenet adresses when on Core testnet.
 * 2. Deploy collateral mainnet addresses when on Core mainnet.
 */
pragma solidity ^0.8.18;

import {CollateralManagerImplementation} from
    "../../src/Aggregators/CollateralManager/CollateralManagerImplementation.sol";
import {Vm} from "forge-std/Vm.sol";
import "forge-std/Script.sol";
import "forge-std/console2.sol";

library HelperConfig {
    Vm public constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    function getCoreTestnetConfig() internal view returns (address[] memory) {
        string[] memory collateral = new string[](4);
        collateral[0] = "CoreBTC";
        collateral[1] = "SolvBTC";
        collateral[2] = "StBTC";
        collateral[3] = "WBTC";

        return getAddresses(collateral);
    }

    function getCoreTestnet2Config() internal view returns (address[] memory) {
        string[] memory collateral = new string[](2);
        collateral[0] = "WCORE";
        collateral[1] = "stCORE";

        return getAddresses(collateral);
    }

    function getCoreMainnetConfig() internal view returns (address[] memory) {
        string[] memory collateral = new string[](6);
        collateral[0] = "solvBTCb";
        collateral[1] = "solvBTCm";
        collateral[2] = "oBTC";
        collateral[4] = "aBTC";
        collateral[5] = "stBTC";

        return getAddresses(collateral);
    }

    function getAddresses(string[] memory collateral) internal view returns (address[] memory addrs) {
        addrs = new address[](collateral.length);
        for (uint256 i = 0; i < collateral.length; i++) {
            addrs[i] = vm.envAddress(collateral[i]);
        }
    }

    function getAllowedCollaterals(uint256 chainId) internal view returns (address[] memory) {
        uint256 coreTestnet2ChainId = vm.envUint("CORE_TESTNET2_CHAINID");
        uint256 coreTestnetChainId = vm.envUint("CORE_TESTNET_CHAINID");
        uint256 coreMainnetChainId = vm.envUint("CORE_MAINNET_CHAINID");

        if (chainId == coreTestnet2ChainId) {
            return getCoreTestnet2Config();
        } else if (chainId == coreMainnetChainId) {
            return getCoreMainnetConfig();
        } else if (chainId == coreTestnetChainId) {
            return getCoreTestnetConfig();
        } else {
            revert("Unsupported chain");
        }
    }

    function encodeInitializeCall(uint256 chainId) internal view returns (bytes memory) {
        address[] memory allowed = getAllowedCollaterals(chainId);
        return abi.encodeWithSelector(CollateralManagerImplementation.initialize.selector, allowed);
    }
}

// Encoder tool
contract EncodeCollateralData is Script {
    function run() external view {
        address[] memory collaterals = HelperConfig.getAllowedCollaterals(block.chainid);

        // Encode the function call using abi.encodeWithSignature.
        bytes memory collateralData = abi.encodeWithSignature("initialize(address[])", collaterals);

        // Log the encoded data.
        console2.logBytes(collateralData);
    }
}
