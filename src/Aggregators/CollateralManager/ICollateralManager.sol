// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

interface ICollateralManager {
    /**
     * @notice Adds an address to the allowed collateral list.
     * @param collateral The address of the collateral token to add.
     */
    function addAllowedCollateral(address collateral) external;

    /**
     * @notice Removes an address from the allowed collateral list.
     * @param collateral The address of the collateral token to remove.
     */
    function removeAllowedCollateral(address collateral) external;

    /**
     * @notice Checks if a given collateral address is allowed.
     * @param collateral The address to check.
     * @return True if the collateral is allowed, otherwise false.
     */
    function isAllowedCollateral(address collateral) external view returns (bool);

    /**
     * @notice Retrives allowed collateral.
     * @param index Index number corresponding to collateral address.
     * @return address The address of the collateral.
     */
    function getAllowedCollateral(uint256 index) external view returns (address);

    /**
     * @notice Retrives total number of allowed collateral.
     */
    function getAllowedCollateralCount() external view returns (uint256);
}
