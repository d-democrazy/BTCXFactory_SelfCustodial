// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {CollateralManagerLibrary} from "./CollateralManagerLibrary.sol";
import {ICollateralManager} from "../../Interfaces/ICollateralManager.sol";

error CollateralManager_InvalidCollateralAddress(address collateral);
error CollateralManager_CollateralAlreadyAllowed(address collateral);
error CollateralManager_CollateralNotAllowed(address collateral);

contract CollateralManagerImplementation is Initializable, OwnableUpgradeable, UUPSUpgradeable, ICollateralManager {
    using EnumerableSet for EnumerableSet.AddressSet;
    using CollateralManagerLibrary for mapping(address => bool);
    using CollateralManagerLibrary for EnumerableSet.AddressSet;

    // Storage: allowed collateral set and mapping
    EnumerableSet.AddressSet private _allowedCollateralSet;
    mapping(address => bool) public _allowedCollateral;

    event AllowedCollateralAdded(address indexed collateral);
    event AllowedCollateralRemoved(address indexed collateral);

    function initialize(address[] memory initialCollateral) public initializer {
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
        for (uint256 i = 0; i < initialCollateral.length; i++) {
            CollateralManagerLibrary.addCollateral(_allowedCollateral, _allowedCollateralSet, initialCollateral[i]);
            emit AllowedCollateralAdded(initialCollateral[i]);
        }
    }

    /**
     * @notice Adds an address to the allowed collateral list.
     * @dev Only the owner can call this function.
     * @param collateral The address of the collateral token to add.
     */
    function addAllowedCollateral(address collateral) external onlyOwner {
        CollateralManagerLibrary.addCollateral(_allowedCollateral, _allowedCollateralSet, collateral);
        emit AllowedCollateralAdded(collateral);
    }

    /**
     * @notice Removes an address from the allowed collateral list.
     * @dev Only the owner can call this function.
     * @param collateral The address of the collateral token to remove.
     */
    function removeAllowedCollateral(address collateral) external onlyOwner {
        CollateralManagerLibrary.removeCollateral(_allowedCollateral, _allowedCollateralSet, collateral);
        emit AllowedCollateralRemoved(collateral);
    }

    /**
     * @notice Checks if a given collateral address is allowed.
     * @param collateral The address to check.
     * @return True if the collateral is allowed, otherwise false.
     */
    function isAllowedCollateral(address collateral) external view returns (bool) {
        return _allowedCollateral[collateral];
    }

    function getAllowedCollateral(uint256 index) external view returns (address) {
        return _allowedCollateralSet.at(index);
    }

    function getAllowedCollateralCount() external view returns (uint256) {
        return _allowedCollateralSet.length();
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
