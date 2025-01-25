// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

interface IBTCX {
    // Custom functions (mint and burnFrom)
    function mint(address to, uint256 amount) external returns (bool);
    function burnFrom(address from, uint256 amount) external returns (bool);
}
