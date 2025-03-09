// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import {BTCXImplementation} from "../../src/Token/BTCXImplementation.sol";
import {Vm} from "forge-std/Vm.sol";
import "forge-std/Script.sol";
import "forge-std/console2.sol";

library HelperConfig {
    Vm public constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    struct NetworkConfig {
        address minter;
        address burner;
    }

    function getAddress(string memory factoryAddress) internal view returns (address) {
        return vm.envAddress(factoryAddress);
    }

    function getTestnet2FactoryConfig() public view returns (NetworkConfig memory) {
        // Factory address for Core testnet2
        return NetworkConfig({minter: getAddress("test2Factory"), burner: getAddress("test2Factory")});
    }

    function getTestnetFactoryConfig() public view returns (NetworkConfig memory) {
        // Factory address for Core testnet
        return NetworkConfig({minter: getAddress("testFactory"), burner: getAddress("testFactory")});
    }

    function getMainnetFactoryConfig() public view returns (NetworkConfig memory) {
        // Factory address for Core mainnet
        return NetworkConfig({minter: getAddress("Factory"), burner: getAddress("Factory")});
    }

    function getFactoryAddressConfig() public view returns (NetworkConfig memory) {
        uint256 coreTestnet2ChainId = vm.envUint("CORE_TESTNET2_CHAINID");
        uint256 coreTestnetChainId = vm.envUint("CORE_TESTNET_CHAINID");
        uint256 coreMainnetChainId = vm.envUint("CORE_MAINNET_CHAINID");

        if (block.chainid == coreTestnet2ChainId) {
            return getTestnet2FactoryConfig();
        } else if (block.chainid == coreTestnetChainId) {
            return getTestnetFactoryConfig();
        } else if (block.chainid == coreMainnetChainId) {
            return getMainnetFactoryConfig();
        } else {
            revert("Unsupported chain");
        }
    }

    function encodeInitializeCall(address admin) external view returns (bytes memory) {
        NetworkConfig memory config = getFactoryAddressConfig();
        return
            abi.encodeWithSelector(BTCXImplementation.initialize.selector, admin, config.minter, config.burner, admin);
    }
}
