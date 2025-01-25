// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../src/BTCX.sol";

contract BTCXTest is Test {
    BTCX public token;
    address factory = address(0xF0);
    address user = address(0xABCD);

    function setUp() public {
        token = new BTCX(factory);

        // Give user some tokens by minting (impersonate factory)
        vm.prank(factory);
        token.mint(user, 1000 ether);
    }

    function testBurnRequiresApproval() public {
        // Try to burn from user before user approves
        vm.startPrank(factory);
        vm.expectRevert(
            abi.encodeWithSelector(BTCX.BTCX_BurnInsufficientAllowance.selector, user, factory, 0, 100 ether)
        );
        token.burnFrom(user, 100 ether);
        vm.stopPrank();
    }

    function testBurnAfterApproval() public {
        // User approves factory to burn tokens on their behalf
        vm.prank(user);
        token.approve(factory, 1000 ether);

        // Now factory can burn
        vm.prank(factory);
        bool success = token.burnFrom(user, 500 ether);
        assertTrue(success);

        // User balance should be 500 ether now
        assertEq(token.balanceOf(user), 500 ether);
    }
}
