// SPDX-License-Identifier: BSL-1.1
// Gearbox. Generalized leverage protocol that allows to take leverage and then use it across other DeFi protocols and platforms in a composable way.
// (c) Gearbox.fi, 2021
pragma solidity ^0.7.4;
pragma abicoder v2;

import {SafeMath} from "@openzeppelin/contracts/math/SafeMath.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/EnumerableSet.sol";
import {PercentageMath} from "../libraries/math/PercentageMath.sol";

import {ICreditManager} from "../interfaces/ICreditManager.sol";
import {ICreditAccount} from "../interfaces/ICreditAccount.sol";
import {IPriceOracle} from "../interfaces/IPriceOracle.sol";
import {ICreditFilter} from "../interfaces/ICreditFilter.sol";
import {IPoolService} from "../interfaces/IPoolService.sol";

import {AddressProvider} from "../core/AddressProvider.sol";
import {ACLTrait} from "../core/ACLTrait.sol";
import {Constants} from "../libraries/helpers/Constants.sol";
import {Errors} from "../libraries/helpers/Errors.sol";

import "hardhat/console.sol";
import "../core/ContractsRegister.sol";

/// @title CreditFilter
/// @notice Implements filter logic for allowed tokens & contract-adapters
///   - Sets/Gets tokens for allowed tokens list
///   - Sets/Gets adapters & allowed contracts
///   - Calculates total value for credit account
///   - Calculates threshold weighted value for credit account
///   - Keeps enabled tokens for credit accounts
///
/// More: https://dev.gearbox.fi/developers/credit/credit-filter
contract CreditFilter is ICreditFilter, ACLTrait {
    using PercentageMath for uint256;
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    // Address of credit Manager
    address public creditManager;

    // Allowed tokens list
    mapping(address => bool) public _allowedTokensMap;

    // Allowed tokens array
    address[] public override allowedTokens;

    // Allowed contracts list
    mapping(address => uint256) public override liquidationThresholds;

    // map token address to its mask
    mapping(address => uint256) public tokenMasksMap;

    // credit account token enables mask. each bit (in order as tokens stored in allowedTokens array) set 1 if token was enable
    mapping(address => uint256) public override enabledTokens;

    // keeps last block we use fast check. Fast check is not allowed to use more than one time in block
    mapping(address => uint256) public fastCheckCounter;

    // Allowed contracts array
    EnumerableSet.AddressSet private allowedContractsSet;

    // Allowed adapters list
    mapping(address => bool) public allowedAdapters;

    // Mapping from allowed contract to allowed adapters
    // If contract is not allowed, contractToAdapter[contract] == address(0)
    mapping(address => address) public override contractToAdapter;

    // Price oracle - uses in evaluation credit account
    address public override priceOracle;

    // Underlying token address
    address public override underlyingToken;

    // Pooll Service address
    address public poolService;

    // Address of WETH token
    address public wethAddress;

    // Minimum chi threshold for fast check
    uint256 public chiThreshold;

    // Maxmimum allowed fast check operations between full health factor checks
    uint256 public hfCheckInterval;

    /// Checks that sender is connected credit manager
    modifier creditManagerOnly {
        require(msg.sender == creditManager, Errors.CF_CREDIT_MANAGERS_ONLY); // T:[CF-20]
        _;
    }

    /// Checks that sender is adapter
    modifier adapterOnly {
        require(allowedAdapters[msg.sender], Errors.CF_ADAPTERS_ONLY); // T:[CF-20]
        _;
    }

    /// Restring any operations after setup is finalised
    modifier duringConfigOnly() {
        require(
            creditManager == address(0),
            Errors.IMMUTABLE_CONFIG_CHANGES_FORBIDDEN
        ); // T:[CF-9,13]
        _;
    }

    constructor(address _addressProvider, address _underlyingToken)
        ACLTrait(_addressProvider)
    {
        priceOracle = AddressProvider(_addressProvider).getPriceOracle(); // T:[CF-21]

        wethAddress = AddressProvider(_addressProvider).getWethToken(); // T:[CF-21]

        underlyingToken = _underlyingToken; // T:[CF-21]

        liquidationThresholds[underlyingToken] = Constants
        .UNDERLYING_TOKEN_LIQUIDATION_THRESHOLD; // T:[CF-21]

        allowToken(
            underlyingToken,
            Constants.UNDERLYING_TOKEN_LIQUIDATION_THRESHOLD
        ); // T:[CF-8, 21]

        setFastCheckParameters(
            Constants.CHI_THRESHOLD,
            Constants.HF_CHECK_INTERVAL_DEFAULT
        ); // T:[CF-21]
    }

    //
    // STATE-CHANGING FUNCTIONS
    //

    /// @dev Adds token to the list of allowed tokens
    /// @param token Address of allowed token
    /// @param liquidationThreshold The credit Manager constant showing the maximum allowable ratio of Loan-To-Value for the i-th asset.
    

    /// @dev Adds contract and adapter to the list of allowed contracts
    /// if contract exists it updates adapter only
    /// @param targetContract Address of allowed contract
    /// @param adapter Adapter contract address
    

    /// @dev Forbids contract to use with credit manager
    /// @param targetContract Address of contract to be forbidden
    

    /// @dev Connects credit manager and checks that it has the same underlying token as pool
    

    /// @dev Checks the financial order and reverts if tokens aren't in list or collateral protection alerts
    /// @param creditAccount Address of credit account
    /// @param tokenIn Address of token In in swap operation
    /// @param tokenOut Address of token Out in swap operation
    /// @param amountIn Amount of tokens in
    /// @param amountOut Amount of tokens out
    

    /// @dev Checks collateral for operation which returns more than 1 token
    /// @param creditAccount Address of credit account
    /// @param tokenOut Addresses of returned tokens
    

    /// @dev Checks health factor after operations
    /// @param creditAccount Address of credit account
    function _checkCollateral(
        address creditAccount,
        uint256 collateralIn,
        uint256 collateralOut
    ) internal {
        if (
            (collateralOut.mul(PercentageMath.PERCENTAGE_FACTOR) >
                collateralIn.mul(chiThreshold)) &&
            fastCheckCounter[creditAccount] <= hfCheckInterval
        ) {
            fastCheckCounter[creditAccount]++; // T:[CF-25, 33]
        } else {
            // Require Hf > 1
            // SWC-135-Code With No Effects: L346
            console.log(calcCreditAccountHealthFactor(creditAccount));
            require(
                calcCreditAccountHealthFactor(creditAccount) >=
                    PercentageMath.PERCENTAGE_FACTOR,
                Errors.CF_OPERATION_LOW_HEALTH_FACTOR
            ); // T:[CF-25, 33, 34]
            fastCheckCounter[creditAccount] = 1; // T:[CF-34]
        }
    }

    /// @dev Initializes enabled tokens
    

    /// @dev Checks that token is in allowed list and updates enabledTokenMask
    /// for provided credit account if needed
    /// @param creditAccount Address of credit account
    /// @param token Address of token to be checked
    

    /// @dev Checks that token is in allowed list and updates enabledTokenMask
    /// for provided credit account if needed
    /// @param creditAccount Address of credit account
    /// @param token Address of token to be checked
    function _checkAndEnableToken(address creditAccount, address token)
        internal
    {
        revertIfTokenNotAllowed(token); //T:[CF-22, 36]

        if (enabledTokens[creditAccount] & tokenMasksMap[token] == 0) {
            enabledTokens[creditAccount] =
                enabledTokens[creditAccount] |
                tokenMasksMap[token];
        } // T:[CF-23]
    }

    /// @dev Change allowedTokenMask bit for partical token to opposite
    /// It disables enabled tokens and vice versa
    function changeAllowedTokenState(address token, bool state)
        external
        configuratorOnly // T:[CF-1]
    {
        _allowedTokensMap[token] = state; // T: [CF-35, 36]
    }

    /// @dev Sets fast check parameters chi & hfCheckCollateral
    /// It reverts if 1 - chi ** hfCheckCollateral > feeLiquidation
    function setFastCheckParameters(
        uint256 _chiThreshold,
        uint256 _hfCheckInterval
    )
        public
        configuratorOnly // T:[CF-1]
    {
        chiThreshold = _chiThreshold; // T:[CF-30]
        hfCheckInterval = _hfCheckInterval; // T:[CF-30]

        revertIfIncorrectFastCheckParams();

        emit NewFastCheckParameters(_chiThreshold, _hfCheckInterval); // T:[CF-30]
    }

    /// @dev It updates liquidation threshold for underlying token threshold
    /// to have enough buffer for liquidation (liquidaion premium + fee liq.)
    /// It reverts if that buffer is less with new paremters, or there is any
    /// liquidaiton threshold > new LT
    

    /// @dev It checks that 1 - chi ** hfCheckInterval < feeLiquidation
    function revertIfIncorrectFastCheckParams() internal view {
        // if credit manager is set, we add additional check
        if (creditManager != address(0)) {
            // computes maximum possible collateral drop between two health factor checks
            uint256 maxPossibleDrop = PercentageMath.PERCENTAGE_FACTOR.sub(
                calcMaxPossibleDrop(chiThreshold, hfCheckInterval)
            ); // T:[CF-39]

            require(
                maxPossibleDrop <
                    ICreditManager(creditManager).feeLiquidation(),
                Errors.CF_FAST_CHECK_NOT_COVERED_COLLATERAL_DROP
            ); // T:[CF-39]
        }
    }

    // @dev it computes percentage ** times
    // @param percentage Percentage in PERCENTAGE FACTOR format
    function calcMaxPossibleDrop(uint256 percentage, uint256 times)
        public
        pure
        returns (uint256 value)
    {
        value = PercentageMath.PERCENTAGE_FACTOR.mul(percentage); // T:[CF-37]
        for (uint256 i = 0; i < times.sub(1); i++) {
            value = value.mul(percentage).div(PercentageMath.PERCENTAGE_FACTOR); // T:[CF-37]
        }
        value = value.div(PercentageMath.PERCENTAGE_FACTOR); // T:[CF-37]
    }

    //
    // GETTERS
    //

    /// @dev Calculates total value for provided address
    /// More: https://dev.gearbox.fi/developers/credit/economy#total-value
    ///
    /// @param creditAccount Token creditAccount address
    function calcTotalValue(address creditAccount)
        external
        view
        override
        returns (uint256 total)
    {
        total = 0; // T:[CF-17]

        uint256 tokenMask;
        uint256 eTokens = enabledTokens[creditAccount];
        for (uint256 i = 0; i < allowedTokensCount(); i++) {
            tokenMask = 1 << i; // T:[CF-17]
            if (eTokens & tokenMask > 0) {
                (, , uint256 tv, ) = getCreditAccountTokenById(
                    creditAccount,
                    i
                );
                total = total.add(tv);
            } // T:[CF-17]
        }
    }

    /// @dev Calculates Threshold Weighted Total Value
    /// More: https://dev.gearbox.fi/developers/credit/economy#threshold-weighted-value
    ///
    /// @param creditAccount Credit account address
    function calcThresholdWeightedValue(address creditAccount)
        public
        view
        override
        returns (uint256 total)
    {
        total = 0;
        uint256 tokenMask;
        uint256 eTokens = enabledTokens[creditAccount];
        for (uint256 i = 0; i < allowedTokensCount(); i++) {
            tokenMask = 1 << i; // T:[CF-18]
            if (eTokens & tokenMask > 0) {
                (, , , uint256 twv) = getCreditAccountTokenById(
                    creditAccount,
                    i
                );
                total = total.add(twv);
            }
        } // T:[CF-18]
        return total.div(PercentageMath.PERCENTAGE_FACTOR); // T:[CF-18]
    }

    /// @dev Returns quantity of tokens in allowed list
    function allowedTokensCount() public view override returns (uint256) {
        return allowedTokens.length; // T:[CF-4, 6]
    }

    /// @dev Returns true if token is in allowed list otherwise false
    function isTokenAllowed(address token) public view override returns (bool) {
        return _allowedTokensMap[token]; // T:[CF-4, 6]
    }

    /// @dev Reverts if token isn't in token allowed list
    function revertIfTokenNotAllowed(address token) public view override {
        require(isTokenAllowed(token), Errors.CF_TOKEN_IS_NOT_ALLOWED); // T:[CF-7, 36]
    }

    /// @dev Returns quantity of contracts in allowed list
    function allowedContractsCount() public view override returns (uint256) {
        return allowedContractsSet.length(); // T:[CF-9]
    }

    /// @dev Returns allowed contract by index
    function allowedContracts(uint256 i)
        public
        view
        override
        returns (address)
    {
        return allowedContractsSet.at(i); // T:[CF-9]
    }

    /// @dev Returns address & balance of token by the id of allowed token in the list
    /// @param creditAccount Credit account address
    /// @param id Id of token in allowed list
    /// @return token Address of token
    /// @return balance Token balance
    /// @return tv Balance converted to undelying asset using price oracle
    /// @return tvw Balance converted to undelying asset using price oracle multipled with liquidation threshold
    function getCreditAccountTokenById(address creditAccount, uint256 id)
        public
        view
        override
        returns (
            address token,
            uint256 balance,
            uint256 tv,
            uint256 tvw
        )
    {
        token = allowedTokens[id]; // T:[CF-28]
        balance = IERC20(token).balanceOf(creditAccount); // T:[CF-28]

        // balance ==0 : T: [CF-28]
        if (balance > 1) {
            tv = IPriceOracle(priceOracle).convert(
                balance,
                token,
                underlyingToken
            ); // T:[CF-28]
            tvw = tv.mul(liquidationThresholds[token]); // T:[CF-28]
        }
    }

    /// @dev Calculates credit account interest accrued
    /// More: https://dev.gearbox.fi/developers/credit/economy#interest-rate-accrued
    ///
    /// @param creditAccount Credit account address
    function calcCreditAccountAccruedInterest(address creditAccount)
        public
        view
        override
        returns (uint256)
    {
        return
            ICreditAccount(creditAccount)
                .borrowedAmount()
                .mul(IPoolService(poolService).calcLinearCumulative_RAY())
                .div(ICreditAccount(creditAccount).cumulativeIndexAtOpen()); // T: [CF-26]
    }

    /**
     * @dev Calculates health factor for the credit account
     *
     *         sum(asset[i] * liquidation threshold[i])
     *   Hf = --------------------------------------------
     *             borrowed amount + interest accrued
     *
     *
     * More info: https://dev.gearbox.fi/developers/credit/economy#health-factor
     *
     * @param creditAccount Credit account address
     * @return Health factor in percents (see PERCENTAGE FACTOR in PercentageMath.sol)
     */
    function calcCreditAccountHealthFactor(address creditAccount)
        public
        view
        override
        returns (uint256)
    {
        return
            calcThresholdWeightedValue(creditAccount)
                .mul(PercentageMath.PERCENTAGE_FACTOR)
                .div(calcCreditAccountAccruedInterest(creditAccount)); // T:[CF-27]
    }
}
