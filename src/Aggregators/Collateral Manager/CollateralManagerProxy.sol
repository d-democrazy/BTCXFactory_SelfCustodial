// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

error CollateralManagerProxy_InvalidImplementation(address implementation);
error CollateralManagerProxy_NotAdmin(address caller);

contract CollateralManagerProxy {
    address public implementation;
    address public admin;

    event Upgraded(address indexed newImplementation);

    /**
     * @notice Constructor sets the initial implementation and admin.
     * @param _implementation The address of the initial implementation contract.
     */
    constructor(address _implementation) {
        if (_implementation == address(0)) {
            revert CollateralManagerProxy_InvalidImplementation(_implementation);
        }
        implementation = _implementation;
        admin = msg.sender;
    }

    /**
     * @notice Modifier to restrict function calls to the admin.
     */
    modifier onlyAdmin() {
        if (msg.sender != admin) {
            revert CollateralManagerProxy_NotAdmin(msg.sender);
        }
        _;
    }

    /**
     * @notice Upgrades the implementation address.
     * @param newImplementation The address of the new implementation contract.
     */
    function updgradeTo(address newImplementation) external onlyAdmin {
        if (newImplementation == address(0)) {
            revert CollateralManagerProxy_InvalidImplementation(newImplementation);
        }
        implementation = newImplementation;
        emit Upgraded(newImplementation);
    }

    /**
     * @notice Fallback function to delegate calls to the implementation.
     */
    fallback() external payable {
        _delegate(implementation);
    }

    /**
     * @notice Receive function to delegate plain ether transfers.
     */
    receive() external payable {
        _delegate(implementation);
    }

    /**
     * @dev Delegate the current call to the implementation contract.
     * Uses inline assembly for delegatecall.
     */
    function _delegate(address _impl) internal {
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), _impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
}
