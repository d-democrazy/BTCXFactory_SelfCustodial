// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";
import {ICollateralManager} from "../../Interfaces/ICollateralManager.sol";

error CollateralManager_InvalidCollateralAddress(address collateral);
error CollateralManager_CollateralAlreadyAllowed(address collateral);
error CollateralManager_CollateralNotAllowed(address collateral);

contract CollateralManagerImplementation is ICollateralManager, Ownable {
    constructor() Ownable(msg.sender) {}

    mapping(address => bool) private _allowedCollateral;

    event AllowedCollateralAdded(address indexed collateral);
    event AllowedCollateralRemoved(address indexed collateral);

    /**
     * @notice Adds an address to the allowed collateral list.
     * @dev Only the contract onwer can call this function.
     * @param collateral The address of the collateral token to add.
     */
    function addAllowedCollateral(address collateral) external onlyOwner {
        if (collateral == address(0)) {
            revert CollateralManager_InvalidCollateralAddress(collateral);
        }

        if (_allowedCollateral[collateral]) {
            revert CollateralManager_CollateralAlreadyAllowed(collateral);
        }

        _allowedCollateral[collateral] = true;
        emit AllowedCollateralAdded(collateral);
    }

    /**
     * @notice Removes an address from the allowed collateral list.
     * @dev Only the contract owner can call this function.
     * @param collateral The address of the collateral token to remove.
     */
    function removeAllowedCollateral(address collateral) external onlyOwner {
        if (!_allowedCollateral[collateral]) {
            revert CollateralManager_CollateralNotAllowed(collateral);
        }

        _allowedCollateral[collateral] = false;
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
}
