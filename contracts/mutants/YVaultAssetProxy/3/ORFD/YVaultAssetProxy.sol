// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "./interfaces/IERC20.sol";
import "./interfaces/IYearnVaultV2.sol";
import "./WrappedPosition.sol";

/// @author Element Finance
/// @title Yearn Vault v1 Asset Proxy
contract YVaultAssetProxy is WrappedPosition {
    IYearnVault public immutable vault;
    uint8 public immutable vaultDecimals;

    // This contract allows deposits to a reserve which can
    // be used to short circuit the deposit process and save gas

    // The following mapping tracks those non-transferable deposits
    mapping(address => uint256) public reserveBalances;
    // These variables store the token balances of this contract and
    // should be packed by solidity into a single slot.
    uint128 public reserveUnderlying;
    uint128 public reserveShares;
    // This is the total amount of reserve deposits
    uint256 public reserveSupply;

    /// @notice Constructs this contract and stores needed data
    /// @param vault_ The yearn v2 vault
    /// @param _token The underlying token.
    ///               This token should revert in the event of a transfer failure.
    /// @param _name The name of the token created
    /// @param _symbol The symbol of the token created
    constructor(
        address vault_,
        IERC20 _token,
        string memory _name,
        string memory _symbol
    ) WrappedPosition(_token, _name, _symbol) {
        vault = IYearnVault(vault_);
        _token.approve(vault_, type(uint256).max);
        vaultDecimals = IERC20(vault_).decimals();
    }

    /// @notice This function allows a user to deposit to the reserve
    ///      Note - there's no incentive to do so. You could earn some
    ///      interest but less interest than yearn. All deposits use
    ///      the underlying token.
    /// @param _amount The amount of underlying to deposit
    // SWC-107-Reentrancy: L49 - L80
    function reserveDeposit(uint256 _amount) external {
        // Transfer from user, note variable 'token' is the immutable
        // inherited from the abstract WrappedPosition contract.
        token.transferFrom(msg.sender, address(this), _amount);
        // Load the reserves
        (uint256 localUnderlying, uint256 localShares) = _getReserves();
        // Calculate the total reserve value
        uint256 totalValue = localUnderlying;
        totalValue += _underlying(localShares);
        // If this is the first deposit we need different logic
        uint256 localReserveSupply = reserveSupply;
        uint256 mintAmount;
        if (localReserveSupply == 0) {
            // If this is the first mint the tokens are exactly the supplied underlying
            mintAmount = _amount;
        } else {
            // Otherwise we mint the proportion that this increases the value held by this contract
            mintAmount = (localReserveSupply * _amount) / totalValue;
        }

        // This hack means that the contract will never have zero balance of underlying
        // which levels the gas expenditure of the transfer to this contract. Permanently locks
        // the smallest possible unit of the underlying.
        if (localUnderlying == 0 && localShares == 0) {
            _amount -= 1;
        }
        // Set the reserves that this contract has more underlying
        _setReserves(localUnderlying + _amount, localShares);
        // Note that the sender has deposited and increase reserveSupply
        reserveBalances[msg.sender] += mintAmount;
        reserveSupply = localReserveSupply + mintAmount;
    }

    /// @notice This function allows a holder of reserve balance to withdraw their share
    /// @param _amount The number of reserve shares to withdraw
    function reserveWithdraw(uint256 _amount) external {
        // Remove 'amount' from the balances of the sender. Because this is 8.0 it will revert on underflow
        reserveBalances[msg.sender] -= _amount;
        // We load the reserves
        (uint256 localUnderlying, uint256 localShares) = _getReserves();
        uint256 localReserveSupply = reserveSupply;
        // Then we calculate the proportion of the shares to redeem
        uint256 userShares = (localShares * _amount) / localReserveSupply;
        // First we withdraw the proportion of shares tokens belonging to the caller
        uint256 freedUnderlying = vault.withdraw(userShares, address(this), 0);
        // We calculate the amount of underlying to send
        uint256 userUnderlying = (localUnderlying * _amount) /
            localReserveSupply;

        // We then store the updated reserve amounts
        _setReserves(
            localUnderlying - userUnderlying,
            localShares - userShares
        );
        // We note a reduction in local supply
        reserveSupply = localReserveSupply - _amount;

        // We send the redemption underlying to the caller
        // Note 'token' is an immutable from shares
        token.transfer(msg.sender, freedUnderlying + userUnderlying);
    }

    /// @notice Makes the actual deposit into the yearn vault
    ///         Tries to use the local balances before depositing
    /// @return Tuple (the shares minted, amount underlying used)
    

    /// @notice Withdraw the number of shares and will short circuit if it can
    /// @param _shares The number of shares to withdraw
    /// @param _destination The address to send the output funds
    /// @param _underlyingPerShare The possibly precomputed underlying per share
    

    /// @notice Get the underlying amount of tokens per shares given
    /// @param _amount The amount of shares you want to know the value of
    /// @return Value of shares in underlying token
    

    /// @notice Get the price per share in the vault
    /// @return The price per share in units of underlying;
    function _pricePerShare() internal view returns (uint256) {
        return vault.pricePerShare();
    }

    /// @notice Function to reset approvals for the proxy
    function approve() external {
        token.approve(address(vault), 0);
        token.approve(address(vault), type(uint256).max);
    }

    /// @notice Helper to get the reserves with one sload
    /// @return Tuple (reserve underlying, reserve shares)
    function _getReserves() internal view returns (uint256, uint256) {
        return (uint256(reserveUnderlying), uint256(reserveShares));
    }

    /// @notice Helper to set reserves using one sstore
    /// @param _newReserveUnderlying The new reserve of underlying
    /// @param _newReserveShares The new reserve of wrapped position shares
    function _setReserves(
        uint256 _newReserveUnderlying,
        uint256 _newReserveShares
    ) internal {
        reserveUnderlying = uint128(_newReserveUnderlying);
        reserveShares = uint128(_newReserveShares);
    }
}
