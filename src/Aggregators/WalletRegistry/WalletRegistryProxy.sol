// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract WalletRegistryProxy is ERC1967Proxy {
    /**
     * @notice Constructor for the proxy contract.
     * @param _logic The address of the WalletRegistryImplementation contract.
     * @param _data The encoded initialization data.
     */
    constructor(address _logic, bytes memory _data) ERC1967Proxy(_logic, _data) {}
}
