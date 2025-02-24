// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IBTCX} from "./Interfaces/IBTCX.sol";

contract BTCX is ERC20, IBTCX, Ownable {
    /**
     * --------------------------
     * Errors
     * --------------------------
     */
    error BTCX_NotFactory(address caller);
    error BTCX_MintExceedsMaxSupply(uint256 requested, uint256 maxAllowed);
    error BTCX_BurnInsufficientAllowance(address from, address operator, uint256 allowance, uint256 burnAmount);
    error BTCX_TransfersPaused(address from, address to, string message);

    /**
     * --------------------------
     * State Variables
     * --------------------------
     */
    uint256 public constant MAX_SUPPLY = 2_100_000_000 * 10 ** 18;
    address public factory;
    bool private transfersPaused;

    /**
     * --------------------------
     * Constructor
     * --------------------------
     */
    constructor(address _factory) ERC20("Bitcoin Extended", "BTCX") Ownable(msg.sender) {
        if (_factory == address(0)) {
            revert BTCX_NotFactory(_factory);
        }
        factory = _factory;
    }

    /**
     * --------------------------
     * Modifier
     * --------------------------
     */
    modifier onlyFactory() {
        if (msg.sender != factory) {
            revert BTCX_NotFactory(msg.sender);
        }
        _;
    }

    /**
     * ------------------------------
     * External mint function
     * ------------------------------
     */
    function mint(address to, uint256 amount) external onlyFactory returns (bool) {
        uint256 newSupply = totalSupply() + amount;
        if (newSupply > MAX_SUPPLY) {
            revert BTCX_MintExceedsMaxSupply(newSupply, MAX_SUPPLY);
        }
        _mint(to, amount);
        return true;
    }

    /**
     * ------------------------------
     * External burn function
     * ------------------------------
     */
    function burnFrom(address from, uint256 amount) external onlyFactory returns (bool) {
        // Check allowance
        uint256 currentAllowance = allowance(from, msg.sender);
        if (currentAllowance < amount) {
            revert BTCX_BurnInsufficientAllowance(from, msg.sender, currentAllowance, amount);
        }

        // Reduce allowance
        _approve(from, msg.sender, currentAllowance - amount);

        // Burn the tokens
        _burn(from, amount);
        return true;
    }

    /**
     * --------------------------------
     * Deactivate arbitrary transfers
     * --------------------------------
     */
    function toggleTransfers() external onlyOwner {
        transfersPaused = !transfersPaused;
    }

    function _update(address from, address to, uint256 value) internal override {
        if (from != address(0) && to != address(0)) {
            revert BTCX_TransfersPaused(msg.sender, to, "Arbitrary transfers are deactivated!");
        }
        super._update(from, to, value);
    }
}
