// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IWalletRegistry} from "./IWalletRegistry.sol";
import {ICollateralManager} from "../CollateralManager/ICollateralManager.sol";
import {IFactory} from "../../Factory/IFactory.sol";
import {CodeHashOperator} from "./CodeHashOperator.sol";

contract WalletRegistryImplementation is Initializable, AccessControlUpgradeable, UUPSUpgradeable, IWalletRegistry {
    using CodeHashOperator for bytes32[];

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant FACTORY_ROLE = keccak256("FACTORY_ROLE");
    bytes32 public constant VERIFIED_WALLET_ROLE = keccak256("VERIFIED_WALLET_ROLE");

    constructor() {
        _disableInitializers();
    }

    struct WalletState {
        bool locked;
        uint256 BTCXBalance;
        address[] collateralTokens;
        mapping(address => uint256) collateralAmounts;
    }

    mapping(address => WalletState) private walletState;
    bytes32[] public expectedWalletCodeHashes;
    address CollateralManagerProxyAddress;
    address BTCXFactoryProxyAddress;
    address BTCXProxyAddress;
    address FactoryProxyAddress;

    function initialize(
        address upgrader,
        address updater,
        address verifiedWallet,
        address admin,
        bytes32[] memory _expectedWalletCodeHashes
    ) public initializer {
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(ADMIN_ROLE, admin);
        _grantRole(UPGRADER_ROLE, upgrader);
        _grantRole(FACTORY_ROLE, updater);
        _grantRole(VERIFIED_WALLET_ROLE, verifiedWallet);
        expectedWalletCodeHashes = _expectedWalletCodeHashes;
    }

    function addExpectedWalletCodeHash(bytes32 newHash) external onlyRole(ADMIN_ROLE) {
        expectedWalletCodeHashes.addExpectedWalletCodeHash(newHash);
    }

    function removeExpectedWalletCodeHash(uint256 index) external onlyRole(ADMIN_ROLE) {
        expectedWalletCodeHashes.removeExpectedWalletCodeHash(index);
    }

    function getExpectedWalletCodeHash(uint256 index) external view returns (bytes32) {
        return expectedWalletCodeHashes.getExpectedWalletCodeHash(index);
    }

    function getExpectedWalletCodeHashes() external view returns (bytes32[] memory) {
        return expectedWalletCodeHashes.getExpectedWalletCodeHashes();
    }

    function verifyWallet(address wallet) external view returns (bool valid) {
        return _verifyWallet(wallet);
    }

    function _verifyWallet(address wallet) internal view returns (bool valid) {
        bytes32 walletCodeHash = wallet.codehash;
        for (uint256 i = 0; i < expectedWalletCodeHashes.length; i++) {
            if (walletCodeHash == expectedWalletCodeHashes[i]) {
                return true;
            }
        }
        return false;
    }

    function updateWalletState(address wallet, bool locked, uint256 BTCXBalance)
        external
        override
        onlyRole(FACTORY_ROLE)
    {
        _updateWalletState(wallet, locked, BTCXBalance);
    }

    function _updateWalletState(address wallet, bool locked, uint256 BTCXBalance) internal {
        WalletState storage state = walletState[wallet];
        state.locked = locked;
        state.BTCXBalance = BTCXBalance;

        emit WalletStateUpdated(wallet, locked, BTCXBalance);
    }

    function lockCollateral(address wallet, address collateral, uint256 amount)
        external
        override
        onlyRole(VERIFIED_WALLET_ROLE)
    {
        if (!_verifyWallet(wallet)) {
            revert NotVerified(wallet, expectedWalletCodeHashes[0], "Wallet not verified");
        }

        if (msg.sender != wallet) {
            revert NotOwner(wallet, "Not wallet owner");
        }

        if (!ICollateralManager(CollateralManagerProxyAddress).isAllowedCollateral(collateral)) {
            uint256 count = ICollateralManager(CollateralManagerProxyAddress).getAllowedCollateralCount();
            address[] memory allowedCollaterals = new address[](count);
            for (uint256 i = 0; i < count; i++) {
                allowedCollaterals[i] = ICollateralManager(CollateralManagerProxyAddress).getAllowedCollateral(i);
            }
            revert IllegalLock(allowedCollaterals, "Collateral not allowed");
        }

        if (amount <= 0) {
            revert IllegalCollateralAmount(amount, "Amount must be greater than 0");
        }

        WalletState storage state = walletState[wallet];
        uint256 currentLocked = state.collateralAmounts[collateral];
        bool newLockState;

        // Add the collateral token to the array if it doesn't already exist.
        bool exist = false;
        for (uint256 i = 0; i < state.collateralTokens.length; i++) {
            if (state.collateralTokens[i] == collateral) {
                exist = true;
                break;
            }
        }
        if (!exist) {
            state.collateralTokens.push(collateral);
        }
        // Lock operation: add new amount to existing locked amount.
        state.collateralAmounts[collateral] = currentLocked + amount;
        newLockState = true;

        _updateWalletState(wallet, newLockState, IERC20(BTCXProxyAddress).balanceOf(wallet));

        emit CollateralLocked(wallet, collateral, amount, newLockState);
    }

    function getWalletState(address wallet)
        external
        view
        override
        returns (
            bool locked,
            uint256 BTCXBalance,
            address[] memory collateralTokens,
            uint256[] memory collateralAmounts
        )
    {
        WalletState storage state = walletState[wallet];

        locked = state.locked;
        BTCXBalance = state.BTCXBalance;
        collateralTokens = state.collateralTokens;
        collateralAmounts = new uint256[](collateralTokens.length);
        for (uint256 i = 0; i < collateralTokens.length; i++) {
            collateralAmounts[i] = state.collateralAmounts[collateralTokens[i]];
        }
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyRole(UPGRADER_ROLE) {}
}
