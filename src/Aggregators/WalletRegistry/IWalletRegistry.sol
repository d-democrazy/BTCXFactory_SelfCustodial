// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

interface IWalletRegistry {
    /**
     * @notice Revert when wallet's codahash isn't valid.
     * @param wallet The wallet address.
     * @param expectedWalletCodeHash The expected wallet codehash.
     * @param message The error message.
     */
    error NotVerified(address wallet, bytes32 expectedWalletCodeHash, string message);

    /**
     * @notice Revert if not wallet owner.
     * @param wallet The wallet address.
     * @param message The error message.
     */
    error NotOwner(address wallet, string message);

    /**
     * @notice Revert if lock wrong collateral.
     * @param collateral The array of allowed collateral.
     * @param message The error message.
     */
    error IllegalLock(address[] collateral, string message);

    /**
     * @notice Revert if lock zero collateral amount.
     * @param amount The amount of collateral to lock.
     * @param message The error message.
     */
    error IllegalCollateralAmount(uint256 amount, string message);

    /**
     * @notice Emitted when a wallet's overall state (locked status and BTCX balance) is updated.
     */
    event WalletStateUpdated(address indexed wallet, bool locked, uint256 BTCXBalance);

    /**
     * @notice Emitted when a collateral lock state is toggled.
     * @param wallet The wallet address.
     * @param collateral The collateral address.
     * @param amount The amount that was affected.
     * @param locked The new state: true if collateral is now locked, false if unlocked.
     */
    event CollateralLocked(address indexed wallet, address indexed collateral, uint256 amount, bool locked);

    /**
     * @notice Updates the overall state of a wallet.
     * @param wallet The address og the wallet.
     * @param locked A flag indicating if the wallet has the collateral locked.
     * @param BTCXBalance The BTCX token balance of the wallet.
     */
    function updateWalletState(address wallet, bool locked, uint256 BTCXBalance) external;

    /**
     * @notice Toggles the collateral lock state for the wallet.
     * @dev Implementation should check the current state for the given collateral
     *      and then either lock it or unlock it by the specific amount.
     *      It must enforce that only verified smart contract wallet (per codehash) can call this function.
     * @param wallet The address of the wallet.
     * @param collateral The collateral token address.
     * @param amount The amount to toggle.
     */
    function lockCollateral(address wallet, address collateral, uint256 amount) external;

    /**
     * @notice Retrives the complete state of a wallet.
     * @param wallet The addres of the wallet.
     * @return locked True if the wallet has collateral locked.
     * @return BTCXBalance The BTCX balance recorded for the wallet.
     * @return collateralTokens An array of collateral token addresses locked by the wallet.
     * @return collateralAmounts An array of amounts corresponding to each collateral token.
     */
    function getWalletState(address wallet)
        external
        view
        returns (
            bool locked,
            uint256 BTCXBalance,
            address[] memory collateralTokens,
            uint256[] memory collateralAmounts
        );

    /**
     * @notice Verifies via `codehash` that the wallet has correctly broadcast its state,
     *         ensuring it contains the required WalletRegistry functions.
     * @param wallet The address of the wallet to verify.
     * @return valid True if the wallet is verified.
     */
    function verifyWallet(address wallet) external returns (bool valid);
}
