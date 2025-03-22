//SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

interface IFactory {
    function burn(address wallet, uint256 amount) external;
}
