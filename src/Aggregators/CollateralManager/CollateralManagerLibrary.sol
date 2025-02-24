// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

error CollateralManager_InvalidCollateralAddress(address collateral);
error CollateralManager_CollateralAlreadyAllowed(address collateral);
error CollateralManager_CollateralNotAllowed(address collateral);

library CollateralManagerLibrary {
    using EnumerableSet for EnumerableSet.AddressSet;

    /**
     * @notice Adds a collatera address to storage.
     * @dev Reverts if the collateral address is already added or invalid address.
     * @param allowed A mapping tracking if an address is allowed.
     * @param set The enumerable set storing collateral addresses.
     * @param collateral The address of the collateral token to add.
     */
    function addCollateral(
        mapping(address => bool) storage allowed,
        EnumerableSet.AddressSet storage set,
        address collateral
    ) internal {
        if (collateral == address(0)) {
            revert CollateralManager_InvalidCollateralAddress(collateral);
        }
        if (allowed[collateral]) {
            revert CollateralManager_CollateralAlreadyAllowed(collateral);
        }
        allowed[collateral] = true;
        set.add(collateral);
    }

    /**
     * @notice Removes a collateral address from storage.
     * @dev Reverts if the collateral address is not allowed.
     * @param allowed A mapping tracking if an address is allowed.
     * @param set The enumerable set storing collateral address.
     * @param collateral The address of the collateral token to remove.
     */
    function removeCollateral(
        mapping(address => bool) storage allowed,
        EnumerableSet.AddressSet storage set,
        address collateral
    ) internal {
        if (!allowed[collateral]) {
            revert CollateralManager_CollateralNotAllowed(collateral);
        }
        allowed[collateral] = false;
        set.remove(collateral);
    }
}
