// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import {WalletRegistryImplementation} from "../../src/Aggregators/WalletRegistry/WalletRegistryImplementation.sol";
import {Vm} from "forge-std/Vm.sol";
import "forge-std/Script.sol";
import "forge-std/console2.sol";

library HelperConfig {
    Vm public constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    struct NetworkConfig {
        address factory;
        address collateralManager;
        address token;
    }

    function getAddress(string memory addressConfig) internal view returns (address) {
        return vm.envAddress(addressConfig);
    }

    function getMainnetAddressConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({
            factory: getAddress("FactoryProxy"),
            collateralManager: getAddress("CollateralManagerProxy"),
            token: getAddress("BTCXProxy")
        });
    }

    function getTestnetAddressConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({
            factory: getAddress("testFactoryProxy"),
            collateralManager: getAddress("testCollateralManagerProxy"),
            token: getAddress("testBTCXProxy")
        });
    }

    function getTestnet2AddressConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({
            factory: getAddress("test2FactoryProxy"),
            collateralManager: getAddress("test2CollateralManagerProxy"),
            token: getAddress("test2BTCXProxy")
        });
    }

    function setChainIdConfig() public view returns (NetworkConfig memory) {
        uint256 coreMainnetChainId = vm.envUint("CORE_MAINNET_CHAINID");
        uint256 coreTestnetChainId = vm.envUint("CORE_TESTNET_CHAINID");
        uint256 coreTestnet2ChainId = vm.envUint("CORE_TESTNET2_CHAINID");

        if (block.chainid == coreMainnetChainId) {
            return getMainnetAddressConfig();
        } else if (block.chainid == coreTestnetChainId) {
            return getTestnetAddressConfig();
        } else if (block.chainid == coreTestnet2ChainId) {
            return getTestnet2AddressConfig();
        } else {
            revert("Unsupported chain");
        }
    }

    function encodeInitializeCall(address deployer) external view returns (bytes memory) {
        address verifiedWallet;
        bytes32[] memory expectedHashes = new bytes32[](1);
        NetworkConfig memory config = setChainIdConfig();

        return abi.encodeWithSelector(
            WalletRegistryImplementation.initialize.selector,
            deployer,
            config.factory,
            verifiedWallet,
            deployer,
            expectedHashes,
            config.collateralManager,
            config.token
        );
    }
}
