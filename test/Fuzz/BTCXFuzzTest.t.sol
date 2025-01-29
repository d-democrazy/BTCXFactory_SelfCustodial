// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../../src/BTCX.sol";

contract BTCXFuzzTest is Test {
    /**
     * ------------------------
     * State variable (Mocks)
     * ------------------------
     */
    BTCX public token;
    address factory = address(0xF0);
    address user = address(0xABCD);

    /**
     * ---------------------
     * Setup
     * ---------------------
     */
    function setUp() public {
        token = new BTCX(factory);

        // Give user some tokens by minting (impersonate factory)
        vm.prank(factory);
        token.mint(user, 1000 ether);
    }

    /**
     * @dev Fuzz test for `mint`.
     * @param caller The address calling `mint`.
     * @param amount The ramdom minted amount.
     */
    // 1. If caller != factory => revert
    function testFuzz_Mint(address caller, uint256 amount) public {
        if (caller != factory) {
            vm.startPrank(caller);

            vm.expectRevert(abi.encodeWithSelector(BTCX.BTCX_NotFactory.selector, caller));
            token.mint(address(0xABCDE), amount);

            vm.stopPrank();
            return;
        }
    }

    /**
     * @dev Semi fuzz test to check `factory` behaviour.
     * @param amount The random minted amonut.
     */
    // 2. If caller == factory => Check supply limit
    function testFuzz_FactoryChecksSupplyLimit(uint256 amount) public {
        uint256 currentSupply = token.totalSupply();
        vm.assume(amount <= type(uint256).max - currentSupply);

        vm.startPrank(factory);

        uint256 maxSupply = token.MAX_SUPPLY();

        if (currentSupply + amount > maxSupply) {
            vm.expectRevert(
                abi.encodeWithSelector(BTCX.BTCX_MintExceedsMaxSupply.selector, currentSupply + amount, maxSupply)
            );
            token.mint(address(0xABCDE), amount);
        } else {
            bool success = token.mint(address(0xABCDE), amount);
            assertTrue(success, "Mint should return true");
            assertEq(token.totalSupply(), currentSupply + amount, "Supply mismatch after fuzz mint");
        }

        vm.stopPrank();
    }
}
