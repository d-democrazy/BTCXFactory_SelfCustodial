// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract BTCXProxy is ERC1967Proxy {
    /**
     * @notice Constructor deploys the proxy.
     * @param _logic The address of the implementation contract.
     * @param admin_ The proxy admin address.
     * @param _data Initialization data.
     */
    constructor(address _logic, address admin_, bytes memory _data) ERC1967Proxy(_logic, _data) {}
}
