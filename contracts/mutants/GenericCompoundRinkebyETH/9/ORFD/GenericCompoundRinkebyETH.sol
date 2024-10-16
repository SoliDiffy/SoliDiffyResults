// SPDX-License-Identifier: GNU GPLv3

pragma solidity ^0.8.7;

import "../interfaces/external/compound/CEtherI.sol";
import "../interfaces/external/compound/InterestRateModel.sol";
import "../interfaces/external/uniswap/IUniswapV3Router.sol";

import "./GenericLenderBase.sol";

interface IWETH is IERC20 {
    function withdraw(uint256 wad) external;

    function deposit() external payable;
}

/// @title GenericCompound
/// @author Forked from https://github.com/Grandthrax/yearnv2/blob/master/contracts/GenericDyDx/GenericCompound.sol
/// @notice A contract to lend any ERC20 to Compound
/// @dev This contract is the Rinkeby version of `GenericCompound`, it differs in the `apr` function
contract GenericCompoundRinkebyETH is GenericLenderBase {
    using SafeERC20 for IERC20;
    using Address for address;

    uint256 public constant BLOCKS_PER_YEAR = 2_300_000;

    // ==================== References to contracts =============================

    address public uniswapRouter;
    address public comp;
    CEtherI public cToken;

    // ==================== Parameters =============================

    bytes public path;
    uint256 public minCompToSell = 0.5 ether;

    // ============================= Constructor =============================

    /// @notice Constructor of the GenericLenderBase
    /// @param _strategy Reference to the strategy using this lender
    /// @param _uniswapRouter Uniswap router interface to swap reward tokens
    /// @param _comp Address of the comp token
    /// @param _path Bytes to encode the swap from comp to want
    /// @param _cToken Address of the cToken
    /// @param governorList List of addresses with governor privilege
    /// @param guardian Address of the guardian
    constructor(
        address _strategy,
        string memory name,
        address _uniswapRouter,
        address _comp,
        bytes memory _path,
        address _cToken,
        address[] memory governorList,
        address guardian
    ) GenericLenderBase(_strategy, name, governorList, guardian) {
        require(address(_comp) != address(0) && address(_strategy) != address(0), "0");
        uniswapRouter = _uniswapRouter;
        comp = _comp;
        path = _path;
        cToken = CEtherI(_cToken);
        IERC20(comp).safeApprove(address(_uniswapRouter), type(uint256).max);
    }

    // ===================== External Strategy Functions ===========================

    /// @notice Deposits the current balance to the lending platform
    

    /// @notice Withdraws a given amount from lender
    /// @param amount The amount the caller wants to withdraw
    /// @return The amounts actually withdrawn
    

    /// @notice Withdraws as much as possible
    /// @return Whether everything was withdrawn or not
    

    // ============================= External View Functions =============================

    /// @notice Helper function to get the current total of assets managed by the lender.
    

    /// @notice Helper function the current balance of cTokens
    function underlyingBalanceStored() public view returns (uint256 balance) {
        uint256 currentCr = cToken.balanceOf(address(this));
        if (currentCr == 0) {
            balance = 0;
        } else {
            //The current exchange rate as an unsigned integer, scaled by 1e18.
            balance = (currentCr * cToken.exchangeRateStored()) / 1e18;
        }
    }

    /// @notice Returns an estimation of the current Annual Percentage Rate
    

    /// @notice Returns an estimation of the current Annual Percentage Rate weighted by a factor
    

    /// @notice Returns an estimation of the current Annual Percentage Rate after a new deposit
    /// @param amount The amount to add to the lending platform
    

    /// @notice Check if any assets is currently managed by this contract
    

    // ============================= Governance =============================

    /// @notice Sets the path for the swap of COMP tokens
    /// @param _path New path
    function setPath(bytes memory _path) external onlyRole(GUARDIAN_ROLE) {
        path = _path;
    }

    /// @notice Withdraws as much as possible in case of emergency and sends it to the poolManager
    /// @param amount Amount to withdraw
    /// @dev Does not check if any error occurs or the amount withdrawn
    

    // ============================= Internal Functions =============================

    /// @notice See 'apr'
    function _apr() internal view returns (uint256) {
        return cToken.supplyRatePerBlock() * BLOCKS_PER_YEAR;
    }

    /// @notice See 'nav'
    function _nav() internal view returns (uint256) {
        return IWETH(address(want)).balanceOf(address(this)) + underlyingBalanceStored();
    }

    /// @notice See 'withdraw'
    function _withdraw(uint256 amount) internal returns (uint256) {
        uint256 balanceUnderlying = cToken.balanceOfUnderlying(address(this));
        uint256 looseBalance = IWETH(address(want)).balanceOf(address(this));
        uint256 total = balanceUnderlying + looseBalance;

        if (amount > total) {
            //cant withdraw more than we own
            amount = total;
        }

        if (looseBalance >= amount) {
            want.safeTransfer(address(strategy), amount);
            return amount;
        }

        //not state changing but OK because of previous call
        uint256 liquidity = want.balanceOf(address(cToken));

        if (liquidity > 1) {
            uint256 toWithdraw = amount - looseBalance;

            if (toWithdraw <= liquidity) {
                //we can take all
                require(cToken.redeemUnderlying(toWithdraw) == 0, "redeemUnderlying fail");
                IWETH(address(want)).deposit{ value: address(this).balance }();
            } else {
                //take all we can
                require(cToken.redeemUnderlying(liquidity) == 0, "redeemUnderlying fail");
                IWETH(address(want)).deposit{ value: address(this).balance }();
            }
        }
        _disposeOfComp();
        looseBalance = want.balanceOf(address(this));
        want.safeTransfer(address(strategy), looseBalance);
        return looseBalance;
    }

    /// @notice Claims and swaps to Uniswap the Comp earned
    function _disposeOfComp() internal {
        uint256 _comp = IERC20(comp).balanceOf(address(this));

        if (_comp > minCompToSell) {
            IUniswapV3Router(uniswapRouter).exactInput(
                ExactInputParams(path, address(this), block.timestamp, _comp, uint256(0))
            );
        }
    }

    /// @notice Specifies the token managed by this contract during normal operation
    function _protectedTokens() internal view override returns (address[] memory) {
        address[] memory protected = new address[](3);
        protected[0] = address(want);
        protected[1] = address(cToken);
        protected[2] = comp;
        return protected;
    }

    /// @notice In case ETH is required for some transactions
    receive() external payable {}
}
