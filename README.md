# PROJECT OVERVIEW
BTCXFactory is self-custodial collateralization to mint stablecoin (BTCX) with 1:100 ratio.
Users register their smart contract wallet to wallet registry contract --> user's smart contract wallet locks collateral token whithin itself --> users call BTCXFactory mint function --> users receive stablecoin (BTCX) based on 1:100 ratio. To unlock, users call BTCXFactory burn function to send BTCX back to the vault --> users unlock their locked collateral.

# The project structure --> !important
```
src
│
├─ Aggregators
│  ├─ CollateralManagerProxy.sol
│  ├─ CollateralManagerImplementation.sol
│  └─ WalletRegistry.sol   // uses extcodehash
│
├─ Interfaces
│  ├─ ICollateralManager.sol
│  ├─ IWalletRegistry.sol
│  └─ IBTCX.sol
│
├─ BTCX.sol
└─ BTCXFactory.sol
```

# BTCX.sol --> Help me decide whether it is a library, interface , abstract or ordinary contract.
- It is a stablecoin token contract that only BTCXFactory.sol can mint and burn the token on behave user's smart contract wallet.
- It's total supply is 2,100,000,000.
- It's name is Bitcoin Extended.
- It's symbol is BTCX.
- It's decimals is 18.
- Inherit from OpenZeppelin's ERC20.

# CollateralManager.sol --> Help me decide whether it is a library, interface , abstract or ordinary contract.
- It is a proxy contract contains a list of allowed collateral contract addresses.
- It has implementation contract to modify the list of allowed collateral contract addresses.

# WalletRegistry.sol --> Help me decide whether it is a library, interface , abstract or ordinary contract.
- It is a registry contract to track smart contract wallet's states whether it has locked one or some of the allowed collateral addresses list whithin itself or has unlocked.
- It also tracks user's smart contract wallet collateral and stablecoin balance.
- WalletRegistry.sol utilizes extcodehash EVM opcode to require user's smart contract wallet has WalletRegistry included.

# BTCXFactory.sol --> Help me decide whether it is a library, interface , abstract or ordinary contract.
- It works together with BTCX.sol, CollateralManager.sol, and WalletRegistry.sol
- On behave user's smart contract wallet, it has capability to mint and burns stablecoin.
- It checks BTCX.sol token supply and circulations.
- It checks CollateralManager.sol to validate whether user's smart contract wallet is locking or unlocking one or some of the allowed collateral list.
- It checks WalletRegistry.sol to validate user's smart contract wallet states eligibility to mint and burn stablecoin.

# Conditions
- The ratio of collateral:stablecoin is 1:100. 1 collateral locked by user's smart contract wallet within itself is worth 100 BTCX.
- The BTCXFactory's mint function is active as long as it checks WalletRegistry.sol that the total collateral locked states by all accross user's smart contract wallet reaches 0.01, otherwise it will revert. Minimum total collateral locked by user's smart contract wallet is 0.01.
- For the 0.01 minimum total collateral locked. Basically, each user's smart contract wallet may lock any amounts of collateral even if < 0.01. Instead requiring user's smart contract wallet to lock minimum 0.01 allowed collaterals, the WalletRegistry.sol checks all accross user's smart contract wallet state to calculate total collateral locked.
- WalletRegistry.sol also ensures calculate maximum total collateral locked accross all user's smart contract wallets does not exceed 21,000,000.
- The BTCXFactory's mint function is active as long as it checks WalletRegistry.sol that the total collateral locked states by accross all user's smart contract wallet does not exceed 21,000,000, otherwise it will revert. Maximum total collateral locked by user's smart contract wallet is 21,000,000.
- BTCX stablecoin supply can not exceed 2,100,000,000.
- BTCXFactory.sol always checks BTCX.sol, CollateralManager.sol, WalletRegistry.sol before it executes its functions.

# Workflow
1. Locking
- User's smart contract wallet locks within itself one or some collaterals which is in the CollateralManager.sol's allowed collateral list.
- Once user's smart contract wallet locks one or some of the collaterals which is in the CollateralManager.sol's allowed collateral list, user's smart contract wallet automatically broadcasts its lock state to WalletRegistry.sol.
- Then WalletRegistry.sol, through extcodehash checks whether user's smart contract wallet includes WalletRegstry or not.

2. Minting
- User's smart contract wallet mints BTCX stablecoin through BTCXFactory.sol. It means everytime user's smart contract wallet triggers BTCXFactory mint function, BTCXFactory.sol checks BTCX.sol stablecoin total and circulating supply; BTCXFactory.sol checks CollateralManager.sol's allowed collateral list to validate whether user's smart contract wallet is locking the allowed collateral; BTCXFactory.sol checks WalletRegistry.sol to validate user's smart contract wallet lock state; BTCXFactory.sol checks WalletRegistry.sol the total collateral locked all accross user's smart contract wallet; BTCXFactory.sol checks WalletRegistry.sol the total BTCX stablecoin total and circulating supply.
- When conditions are matched BTCXFactory.sol sends BTCX stablecoin token to user's smart contarct wallet based on 1:100 collateral:stablecoin ratio.
- WalletRegistry.sol notes the user's smart contract wallet BTCX stablecoin holding balance.

3. Burn to unlock
- User's smart contract wallet unlocks their collateral by triggering burn function of BTCXFactory.sol. It means the smart contract wallet sends BTCX stablecoin holding balance back to BTCX.sol and broadcast its unlocked state and BTCX stablecoin holding balance state to WalletRegistry.sol.
- WalletRegistry will automatically update its database.
- Then, user's smart contract wallet unlocks the collateral.
- Therefore, the user's smart contract wallet locked collateral is then free.

# Notes
1. This project is non-custodian project. Means that BTCX.sol, BTCXFactory.sol, WalletRegistry.sol, CollateralManager.sol never holds user's collateral token.
2. All collaterals are locked and unlocked whithin user's smart contract wallet.
3. I use Foundry development tools
4. I have installed OpenZeppelin and Safe library.