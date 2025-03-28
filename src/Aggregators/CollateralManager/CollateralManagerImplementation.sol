// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {CollateralOperator} from "./CollateralOperator.sol";
import {ICollateralManager} from "./ICollateralManager.sol";

contract CollateralManagerImplementation is Initializable, OwnableUpgradeable, UUPSUpgradeable, ICollateralManager {
    using EnumerableSet for EnumerableSet.AddressSet;
    using CollateralOperator for mapping(address => bool);
    using CollateralOperator for EnumerableSet.AddressSet;

    // Storage: allowed collateral set and mapping
    EnumerableSet.AddressSet private _allowedCollateralSet;
    mapping(address => bool) public _allowedCollateral;

    event AllowedCollateralAdded(address indexed collateral);
    event AllowedCollateralRemoved(address indexed collateral);

    constructor() {
        _disableInitializers();
    }

    function initialize(address[] memory initialCollateral) public initializer {
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
        for (uint256 i = 0; i < initialCollateral.length; i++) {
            CollateralOperator.addCollateral(_allowedCollateral, _allowedCollateralSet, initialCollateral[i]);
            emit AllowedCollateralAdded(initialCollateral[i]);
        }
    }

    function addAllowedCollateral(address collateral) external onlyOwner {
        CollateralOperator.addCollateral(_allowedCollateral, _allowedCollateralSet, collateral);
        emit AllowedCollateralAdded(collateral);
    }

    function removeAllowedCollateral(address collateral) external onlyOwner {
        CollateralOperator.removeCollateral(_allowedCollateral, _allowedCollateralSet, collateral);
        emit AllowedCollateralRemoved(collateral);
    }

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
