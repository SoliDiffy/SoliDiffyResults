// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.11;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../aave/IncentiveController.sol";
import "./ERC20Mintable.sol";

import {
    ILendingPoolAddressesProvider
} from "../aave/ILendingPoolAddressesProvider.sol";
import {ILendingPool} from "../aave/ILendingPool.sol";

contract IncentiveControllerMock is
    ILendingPoolAddressesProvider,
    ILendingPool,
    IncentiveController,
    MockERC20Mintable
{
    address public underlyingAssetAddress;

    constructor(string memory name, string memory symbol)
        public
        MockERC20Mintable(name, symbol)
    {}

    /// ILendingPoolAddressesProvider interface
    

    

    

    function getLendingPoolCore()
        public
        override
        view
        returns (address payable)
    {
        return address(uint160(address(this))); // cast to make it payable
    }

    function getReserveTokensAddresses(address asset)
        public
        view
        returns (
            address,
            address,
            address
        )
    {
        return (address(this), address(this), address(this));
    }

    function setLendingPoolCoreImpl(address _lendingPoolCore) public override {}

    function getLendingPoolConfigurator()
        public
        override
        view
        returns (address)
    {}

    function setLendingPoolConfiguratorImpl(address _configurator)
        public
        override
    {}

    function getLendingPoolDataProvider()
        public
        override
        view
        returns (address)
    {}

    function setLendingPoolDataProviderImpl(address _provider)
        public
        override
    {}

    function getLendingPoolParametersProvider()
        public
        override
        view
        returns (address)
    {}

    function setLendingPoolParametersProviderImpl(address _parametersProvider)
        public
        override
    {}

    function getTokenDistributor() public override view returns (address) {}

    function setTokenDistributor(address _tokenDistributor) public override {}

    function getFeeProvider() public override view returns (address) {}

    function setFeeProviderImpl(address _feeProvider) public override {}

    function getLendingPoolLiquidationManager()
        public
        override
        view
        returns (address)
    {}

    function setLendingPoolLiquidationManager(address _manager)
        public
        override
    {}

    function getLendingPoolManager() public override view returns (address) {}

    function setLendingPoolManager(address _lendingPoolManager)
        public
        override
    {}

    function getPriceOracle() public override view returns (address) {}

    function setPriceOracle(address _priceOracle) public override {}

    function getLendingRateOracle() public override view returns (address) {}

    function setLendingRateOracle(address _lendingRateOracle) public override {}

      function getRewardsBalance(address[] calldata assets, address user) external override view returns(uint256) {
          return 1e18;
      }


    /// ILendingPool interface
    function deposit(address _reserve, uint256 _amount, address onBehalfOf, uint16 _referralCode)
     public override {
        IERC20 reserve = IERC20(_reserve);
        reserve.transferFrom(msg.sender, address(this), _amount);
        _mint(msg.sender, _amount);
    }

        /// ILendingPool interface
    function claimRewards(address[] calldata assets,
    uint256 amount,
    address to)
     public override returns (uint256) {
        _mint(to, amount);
        return amount;
    }

    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) public override {
        amount = IERC20(address(this)).balanceOf(msg.sender);
        _burn(to, amount);
        IERC20(asset).transfer(to, amount);
    }

    //Helpers
    //We need to bootstrap the underlyingAssetAddress to use the redeem function
    function setUnderlyingAssetAddress(address _addr) public {
        underlyingAssetAddress = _addr;
    }

    //We need to bootstrap the pool with liquidity to pay interest
    function addLiquidity(
        address _reserve,
        address _bank,
        address _addr,
        uint256 _amount
    ) public {
        IERC20 reserve = IERC20(_reserve);
        reserve.transferFrom(_addr, address(this), _amount);
        _mint(_bank, _amount);
    }
}

