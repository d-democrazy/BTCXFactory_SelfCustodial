// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import {BTCX} from "../../src/BTCX.sol";

contract BTCXTest is Test {
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
     * -----------------------------------------------------------------
     * State variables test (Confirms MAX_SUPPLY and factory contract)
     * -----------------------------------------------------------------
     */
    function testMaxSupplyAndFactory() public view {
        uint256 expectedMax = 2_100_000_000 * 10 ** 18;
        assertEq(token.MAX_SUPPLY(), expectedMax, "MAX_SUPPLY mismatch");
        assertEq(token.factory(), factory, "Factory address mismatch");
    }

    /**
     * ------------------------------------
     * Constructor test during deployment
     * ------------------------------------
     */
    // 1. Zero factory contract test
    function testConstructor_revertsIfNoFactoryContract() public {
        vm.expectRevert(abi.encodeWithSelector(BTCX.BTCX_NotFactory.selector, address(0)));
        new BTCX(address(0));
    }

    // 2. Confirm token identity
    function testTokenIdentity() public view {
        assertEq(token.name(), "Bitcoin Extended", "Token name mismatch");
        assertEq(token.symbol(), "BTCX", "Token symbol mismatch");
        assertEq(uint256(token.decimals()), 18, "Token decimals mismatch");
    }

    /**
     * -----------------------
     * Modifier test
     * -----------------------
     */
    function testModifier() public {
        address nonFactory = address(0x999);
        vm.startPrank(nonFactory);

        // Attempt to mint
        vm.expectRevert(abi.encodeWithSelector(BTCX.BTCX_NotFactory.selector, nonFactory));
        token.mint(user, 100 ether);

        // Attemp to burn
        vm.expectRevert(abi.encodeWithSelector(BTCX.BTCX_NotFactory.selector, nonFactory));
        token.burnFrom(user, 50 ether);

        vm.stopPrank();
    }

    /**
     * -----------------------
     * Mint test
     * -----------------------
     */
    function testFactoryMintsForUser() public {
        vm.startPrank(factory);

        bool success = token.mint(address(user), 500 ether);
        assertTrue(success, "Mint should return true");
        uint256 userBalance = token.balanceOf(user);
        assertEq(userBalance, 1500 ether, "User did not receive minted token");

        vm.stopPrank();
    }

    function testMintSuccess() public {
        vm.startPrank(factory);

        uint256 currentSupply = token.totalSupply();
        bool success = token.mint(address(user), 500 ether);
        assertTrue(success, "Mint success");
        assertEq(token.totalSupply(), currentSupply + 500 ether, "Total circulating supply did not increase properly");
        assertEq(token.balanceOf(address(user)), 1500 ether, "Minted balance mismatch");

        vm.stopPrank();
    }

    function testMintExceedsSupply() public {
        vm.startPrank(factory);

        // Pre-measure how many mintable token leftover
        uint256 maxRemaining = token.MAX_SUPPLY() - token.totalSupply();

        // Attemp to mint more than remaining token
        vm.expectRevert();
        token.mint(address(user), maxRemaining + 1);

        vm.stopPrank();
    }

    /**
     * ------------------------------
     * Approval test
     * ------------------------------
     */
    function testApproval() public {
        vm.prank(user);

        token.approve(factory, 1000 ether);
        assertEq(token.allowance(user, factory), 1000 ether, "Allowance mismatch");

        vm.stopPrank();
    }

    /**
     * ------------------------------
     * Burn test
     * ------------------------------
     */
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
        // User approves factory to burn tokens on their behalf (arbitrary approve 21,000,000 token)
        vm.prank(user);
        token.approve(factory, 21000000 ether);

        // Now factory can burn
        vm.prank(factory);
        bool success = token.burnFrom(user, 500 ether);
        assertTrue(success);
        assertEq(token.balanceOf(user), 500 ether, "Balance is not decreased");
    }

    /**
     * -------------------------
     * Edge case test
     * -------------------------
     */
    function testBurnMoreThanBalance() public {
        vm.prank(user);
        token.approve(factory, 2000 ether);

        vm.startPrank(factory);

        vm.expectRevert();
        token.burnFrom(user, 1500 ether);

        vm.stopPrank();
    }
}
