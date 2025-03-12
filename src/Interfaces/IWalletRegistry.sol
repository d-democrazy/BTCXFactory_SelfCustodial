// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

interface IWalletRegistry {
    /**
     * @notice Emitted when a wallet's overall state (locked status and BTCX balance) is updated.
     */
    event WalletStateUpdated(address indexed wallet, bool locked, uint256 BTCXBalance);

    /**
     * @notice Emitted when collateral is locked in a wallet.
     */
    event CollateralLocked(address indexed wallet, address collateral, uint256 amount);

    /**
     * @notice Emitted when collateral is unlocked from a wallet.
     */
    event CollateralUnlocked(address indexed walled, address collateral, uint256 amount);

    /**
     * @notice Updates the overall states of a wallet.
     * @param wallet The address of the wallet.
     * @param locked A flag indicating if the wallet has collateral locked.
     * @param btcxBalance The BTCX token balance of the wallet.
     */
    function updateWalletState(address wallet, bool locked, uint256 btcxBalance) external;

    /**
     * @notice Records a collateral lock event for a wallet.
     * @param wallet The address of the wallet.
     * @param collateral The address of the collateral token.
     * @param amount The amount of collateral locked.
     */
    function lockCollateral(address wallet, address collateral, uint256 amount) external;

    /**
     * @notice Records a collateral unlock event for a wallet.
     * @param wallet The address of the wallet.
     * @param collateral The address of the collateral token.
     * @param amount The amount of collateral unlocked.
     */
    function unlockCollateral(address wallet, address collateral, uint256 amount) external;

    /**
     * @notice Retrives the complete state of a wallet.
     * @param wallet The addres of the wallet.
     * @return locked True if the wallet has collateral locked.
     * @return btcxBalance The BTCX balance recorded for the wallet.
     * @return collateralTokens An array of collateral token addresses locked by the wallet.
     * @return collateralAmounts An array of amounts corresponding to each collateral token.
     */
    function getWalletState(address wallet)
        external
        view
        returns (
            bool locked,
            uint256 btcxBalance,
            address[] memory collateralTokens,
            uint256[] memory collateralAmounts
        );

    /**
     * @notice Verifies via `extcodehash` that the wallet has correctly broadcast its state, ensuring it contains the required WalletRegistry functions.
     * @param wallet The address of the wallet to verify.
     * @return valid True if the wallet is verified.
     */
    function verifyWallet(address wallet) external view returns (bool valid);
}
