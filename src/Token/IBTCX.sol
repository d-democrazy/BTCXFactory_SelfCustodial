// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

interface IBTCX {
    function mint(address to, uint256 amount) external;
    function burnFrom(address account, uint256 value) external;
    function balanceOf(address account) external view returns (uint256);
}
