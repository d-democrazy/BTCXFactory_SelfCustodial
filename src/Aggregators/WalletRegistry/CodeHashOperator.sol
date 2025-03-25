// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

library CodeHashOperator {
    /**
     * @notice Add a new code hash to the array.
     * @param self The storage array of allowed code hashes.
     * @param newHash The new code hash to add.
     */
    function addExpectedWalletCodeHash(bytes32[] storage self, bytes32 newHash) internal {
        for (uint256 i = 0; i < self.length; i++) {
            if (self[i] == newHash) {
                revert("Hash already exists");
            }
        }
        self.push(newHash);
    }

    /**
     * @notice Removes a code hash from the array at a given index.
     * @param self The storage array of allowed code hashes.
     * @param index The index to remove.
     */
    function removeExpectedWalletCodeHash(bytes32[] storage self, uint256 index) internal {
        require(index < self.length, "Index out of bounds");
        self[index] = self[self.length - 1];
        self.pop();
    }

    /**
     * @notice Returns the code hash at a specified index.
     * @param self The storage array of allowed code hash.
     * @param index The index of the code hash.
     * @return codehash The code hash at that index.
     */
    function getExpectedWalletCodeHash(bytes32[] storage self, uint256 index) internal view returns (bytes32) {
        require(index < self.length, "Index out of bounds");
        return self[index];
    }

    /**
     * @notice Returns the entire array of allowed code hashes.
     * @param self The storage array of allowed code hashes.
     * @return self The full array of allowed code hashes.
     */
    function getExpectedWalletCodeHashes(bytes32[] storage self) internal pure returns (bytes32[] memory) {
        return self;
    }
}
