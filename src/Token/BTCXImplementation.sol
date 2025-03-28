// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {ERC20BurnableUpgradeable} from
    "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import {ERC20PausableUpgradeable} from
    "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract BTCXImplementation is
    Initializable,
    ERC20Upgradeable,
    ERC20BurnableUpgradeable,
    ERC20PausableUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    bytes32 public constant FACTORY_ROLE = keccak256("FACTORY_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    uint256 public constant MAX_SUPPLY = 2100000000 ether;

    error ExceedsMaxSupply(uint256 amount, uint256 maxSupply);
    error NotAllowed(uint256 value, string message);

    constructor() {
        _disableInitializers();
    }

    function initialize(address pauser, address minter, address burner, address upgrader) public initializer {
        __ERC20_init("Bitcoin Extended", "BTCX");
        __ERC20Burnable_init();
        __ERC20Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(ADMIN_ROLE, pauser);
        _grantRole(FACTORY_ROLE, minter);
        _grantRole(FACTORY_ROLE, burner);
        _grantRole(ADMIN_ROLE, upgrader);
    }

    function pause() public onlyRole(ADMIN_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(ADMIN_ROLE) {
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyRole(FACTORY_ROLE) {
        if (totalSupply() + amount > MAX_SUPPLY) {
            revert ExceedsMaxSupply(totalSupply() + amount, MAX_SUPPLY);
        }
        _mint(to, amount);
    }

    function burnFrom(address account, uint256 value)
        public
        override(ERC20BurnableUpgradeable)
        onlyRole(FACTORY_ROLE)
    {
        _spendAllowance(account, _msgSender(), value);
        _burn(account, value);
    }

    function burn(uint256 value) public pure override {
        revert NotAllowed(value, "Direct burn not allowed!");
    }

    function balanceOf(address account) public view override(ERC20Upgradeable) returns (uint256) {
        return ERC20Upgradeable.balanceOf(account);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyRole(ADMIN_ROLE) {}

    function _update(address from, address to, uint256 value)
        internal
        override(ERC20Upgradeable, ERC20PausableUpgradeable)
    {
        if (from != address(0) && to != address(0)) {
            require(!paused(), "BTCX token can only be locked as collateral!");
        }
        ERC20Upgradeable._update(from, to, value);
    }
}
