// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "@openzeppelin/contracts/utils/Strings.sol";
import "./interfaces/IMark2Market.sol";
import "./interfaces/IPriceGetter.sol";
import "./registries/Portfolio.sol";
import "./Vault.sol";

contract Mark2Market is IMark2Market, Initializable, AccessControlUpgradeable, UUPSUpgradeable{
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");


    // ---  fields

    Vault public vault;
    Portfolio public portfolio;

    // ---  events

    event VaultUpdated(address vault);
    event PortfolioUpdated(address portfolio);


    // ---  modifiers

    modifier onlyAdmin() {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Restricted to admins");
        _;
    }


    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function initialize() initializer public {
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
    }

    


    // ---  setters

    function setVault(address _vault) external onlyAdmin {
        require(_vault != address(0), "Zero address not allowed");
        vault = Vault(_vault);
        emit VaultUpdated(_vault);
    }

    function setPortfolio(address _portfolio) external onlyAdmin {
        require(_portfolio != address(0), "Zero address not allowed");
        portfolio = Portfolio(_portfolio);
        emit PortfolioUpdated(_portfolio);
    }

    // ---  logic


    function assetPricesView() public view returns(AssetPrices[] memory){
        return assetPrices().assetPrices;
    }

    


    

    

    function totalAssets(bool sell) internal view returns (uint256)
    {
        Portfolio.AssetWeight[] memory assetWeights = portfolio.getAllAssetWeights();

        uint256 totalUsdcPrice = 0;
        uint256 count = assetWeights.length;
        for (uint8 i = 0; i < count; i++) {
            Portfolio.AssetWeight memory assetWeight = assetWeights[i];

            uint256 amountInVault = _currentAmountInVault(assetWeight.asset);

            Portfolio.AssetInfo memory assetInfo = portfolio.getAssetInfo(assetWeight.asset);
            IPriceGetter priceGetter = IPriceGetter(assetInfo.priceGetter);

            uint256 usdcPriceDenominator = priceGetter.denominator();

            uint256 usdcPrice;
            if(sell)
                usdcPrice = priceGetter.getUsdcSellPrice();
            else
                usdcPrice = priceGetter.getUsdcBuyPrice();

            // in decimals: 18 + 18 - 18 => 18
            uint256 usdcPriceInVault = (amountInVault * usdcPrice) / usdcPriceDenominator;

            totalUsdcPrice += usdcPriceInVault;
        }

        return totalUsdcPrice;
    }


    

    /**
     * @param withdrawToken Token to withdraw
     * @param withdrawAmount Not normalized amount to withdraw
     */
    

    /**
     * @param totalUsdcPrice - Total normilized to 10**18
     * @param assetWeight - Token address to calc
     * @return normalized to 10**18 signed diff amount and mark that mean that need sell all
     */
    function _diffToTarget(uint256 totalUsdcPrice, Portfolio.AssetWeight memory assetWeight)
        internal
        view
        returns (
            int256,
            bool
        )
    {
        address asset = assetWeight.asset;

        uint256 targetUsdcAmount = (totalUsdcPrice * assetWeight.targetWeight) /
            portfolio.TOTAL_WEIGHT();

        Portfolio.AssetInfo memory assetInfo = portfolio.getAssetInfo(asset);
        IPriceGetter priceGetter = IPriceGetter(assetInfo.priceGetter);

        uint256 usdcPriceDenominator = priceGetter.denominator();
        uint256 usdcBuyPrice = priceGetter.getUsdcBuyPrice();

        // in decimals: 18 * 18 / 18 => 18
        uint256 targetTokenAmount = (targetUsdcAmount * usdcPriceDenominator) / usdcBuyPrice;

        // normalize currentAmount to 18 decimals
        uint256 currentAmount = _currentAmountInVault(asset);

        bool targetIsZero;
        if (targetTokenAmount == 0) {
            targetIsZero = true;
        } else {
            targetIsZero = false;
        }

        int256 diff = int256(targetTokenAmount) - int256(currentAmount);
        return (diff, targetIsZero);
    }

    function _currentAmountInVault(address asset) internal view returns (uint256){
        // normalize currentAmount to 18 decimals
        uint256 currentAmount = IERC20(asset).balanceOf(address(vault));
        //TODO: denominator usage
        uint256 denominator = 10 ** (18 - IERC20Metadata(asset).decimals());
        currentAmount = currentAmount * denominator;
        return currentAmount;
    }




}
