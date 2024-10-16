// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;
import "./IOracle.sol";
import "./ISwapper.sol";
import "./IERC20.sol";
import "./IBentoBox.sol";

interface ILendingPair {
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event LogAccrue(uint256 accruedAmount, uint256 feeAmount, uint256 rate, uint256 utilization);
    event LogAddAsset(address indexed user, uint256 amount, uint256 fraction);
    event LogAddBorrow(address indexed user, uint256 amount, uint256 fraction);
    event LogAddCollateral(address indexed user, uint256 amount);
    event LogDev(address indexed newFeeTo);
    event LogExchangeRate(uint256 rate);
    event LogFeeTo(address indexed newFeeTo);
    event LogRemoveAsset(address indexed user, uint256 amount, uint256 fraction);
    event LogRemoveBorrow(address indexed user, uint256 amount, uint256 fraction);
    event LogRemoveCollateral(address indexed user, uint256 amount);
    event LogWithdrawFees();
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function accrueInfo() external view returns (uint64 interestPerBlock, uint64 lastBlockAccrued, uint128 feesPendingAmount);
    function allowance(address, address) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool success);
    function asset() external view returns (IERC20);
    function balanceOf(address) external view returns (uint256);
    function bentoBox() external view returns (IBentoBox);
    function borrowOpeningFee() external view returns (uint256);
    function claimOwnership() external;
    function closedCollaterizationRate() external view returns (uint256);
    function collateral() external view returns (IERC20);
    function dev() external view returns (address);
    function devFee() external view returns (uint256);
    function exchangeRate() external view returns (uint256);
    function feeTo() external view returns (address);
    function interestElasticity() external view returns (uint256);
    function liquidationMultiplier() external view returns (uint256);
    function masterContract() external view returns (ILendingPair);
    function maximumInterestPerBlock() external view returns (uint256);
    function maximumTargetUtilization() external view returns (uint256);
    function minimumInterestPerBlock() external view returns (uint256);
    function minimumTargetUtilization() external view returns (uint256);
    function nonces(address) external view returns (uint256);
    function openCollaterizationRate() external view returns (uint256);
    function oracle() external view returns (IOracle);
    function oracleData() external view returns (bytes storage);
    function owner() external view returns (address);
    function pendingOwner() external view returns (address);
    function permit(address owner_, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;
    function protocolFee() external view returns (uint256);
    function renounceOwnership() external;
    function startingInterestPerBlock() external view returns (uint256);
    function swappers(ISwapper) external view returns (bool);
    function totalAsset() external view returns (uint128 amount, uint128 fraction);
    function totalBorrow() external view returns (uint128 amount, uint128 fraction);
    function totalCollateralAmount() external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool success);
    function transferFrom(address from, address to, uint256 amount) external returns (bool success);
    function transferOwnership(address newOwner) external;
    function transferOwnershipDirect(address newOwner) external;
    function userBorrowFraction(address) external view returns (uint256);
    function userCollateralAmount(address) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function symbol() external pure returns (string storage);
    function name() external pure returns (string storage);
    function decimals() external view returns (uint8);
    function init(bytes calldata data) external;
    function getInitData(IERC20 collateral_, IERC20 asset_, IOracle oracle_, bytes calldata oracleData_)
        external pure returns (bytes memory data);
    function accrue() external;
    function isSolvent(address user, bool open) external view returns (bool);
    function peekExchangeRate() external view returns (bool, uint256);
    function updateExchangeRate() external returns (uint256);
    function addCollateral(uint256 amount) external payable;
    function addCollateralTo(uint256 amount, address to) external payable;
    function addCollateralFromBento(uint256 amount) external;
    function addCollateralFromBentoTo(uint256 amount, address to) external;
    function addAsset(uint256 amount) external payable;
    function addAssetTo(uint256 amount, address to) external payable;
    function addAssetFromBento(uint256 amount) external payable;
    function addAssetFromBentoTo(uint256 amount, address to) external payable;
    function removeCollateral(uint256 amount, address to) external;
    function removeCollateralToBento(uint256 amount, address to) external;
    function removeAsset(uint256 fraction, address to) external;
    function removeAssetToBento(uint256 fraction, address to) external;
    function borrow(uint256 amount, address to) external;
    function borrowToBento(uint256 amount, address to) external;
    function repay(uint256 fraction) external;
    function repayFor(uint256 fraction, address beneficiary) external;
    function repayFromBento(uint256 fraction) external;
    function repayFromBentoTo(uint256 fraction, address beneficiary) external;
    function short(ISwapper swapper, uint256 assetAmount, uint256 minCollateralAmount) external;
    function unwind(ISwapper swapper, uint256 borrowFraction, uint256 maxAmountCollateral) external;
    function liquidate(address[] calldata users, uint256[] calldata borrowFractions, address to, ISwapper swapper, bool open) external;
    function batch(bytes[] calldata calls, bool revertOnFail) external payable returns (bool[] memory, bytes[] memory);
    function withdrawFees() external;
    function setSwapper(ISwapper swapper, bool enable) external;
    function setFeeTo(address newFeeTo) external;
    function setDev(address newDev) external;
    function swipe(IERC20 token) external;
}
