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
    // If caller != factory => revert
    function testFuzz_Mint(address caller, uint256 amount) public {
        if (caller != factory) {
            vm.startPrank(caller);

            vm.expectRevert(abi.encodeWithSelector(BTCX.BTCX_NotFactory.selector, caller));
            token.mint(address(user), amount);

            vm.stopPrank();
            return;
        }
    }

    /**
     * @dev Semi fuzz test to check `factory` behaviour.
     * @param amount The random minted amonut.
     */
    // If caller == factory => Check supply limit
    function testFuzz_FactoryChecksSupplyLimit(uint256 amount) public {
        uint256 currentSupply = token.totalSupply();
        vm.assume(amount <= type(uint256).max - currentSupply);

        vm.startPrank(factory);

        uint256 maxSupply = token.MAX_SUPPLY();

        if (currentSupply + amount > maxSupply) {
            vm.expectRevert(
                abi.encodeWithSelector(BTCX.BTCX_MintExceedsMaxSupply.selector, currentSupply + amount, maxSupply)
            );
            token.mint(address(user), amount);
        } else {
            bool success = token.mint(address(user), amount);
            assertTrue(success, "Mint should return true");
            assertEq(token.totalSupply(), currentSupply + amount, "Supply mismatch after fuzz mint");
        }

        vm.stopPrank();
    }

    /**
     * @dev Fuzz test for `burnFrom` with random allowance & burn amounts.
     * @notice `factory` is the only valid caller.
     * @param allowanceAmount The user's approval to the factory.
     * @param burnAmount The factory tries to burn.
     */
    function testFuzz_BurnFrom(uint256 allowanceAmount, uint256 burnAmount) public {
        vm.prank(user);
        token.approve(factory, allowanceAmount);

        vm.startPrank(factory);

        if (burnAmount > 2_000 ether) {
            burnAmount = burnAmount % 2_000 ether;
        }

        if (allowanceAmount < burnAmount) {
            vm.expectRevert(
                abi.encodeWithSelector(
                    BTCX.BTCX_BurnInsufficientAllowance.selector, user, factory, allowanceAmount, burnAmount
                )
            );
            token.burnFrom(user, burnAmount);
        } else {
            uint256 userBalance = token.balanceOf(user);

            if (burnAmount > userBalance) {
                vm.expectRevert();
                token.burnFrom(user, burnAmount);
            } else {
                bool success = token.burnFrom(user, burnAmount);
                assertTrue(success, "Fuzz burnFrom should succeed");
                assertEq(token.balanceOf(user), userBalance - burnAmount, "User balance mismatch");
            }
        }

        vm.stopPrank();
    }
}
