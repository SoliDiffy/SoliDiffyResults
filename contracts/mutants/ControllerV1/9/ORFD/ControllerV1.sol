// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

import "./ControllerInterface.sol";
import "./liquidity/LPoolDelegator.sol";
import "./Adminable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/math/Math.sol";
import "./DelegateInterface.sol";
import "./lib/DexData.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
  * @title Controller
  * @author OpenLeverage
  */
contract ControllerV1 is DelegateInterface, ControllerInterface, ControllerStorage, Adminable {
    using SafeMath for uint;

    constructor () {}

    function initialize(
        IERC20 _oleToken,
        address _xoleToken,
        address _wETH,
        address _lpoolImplementation,
        address _openlev,
        DexAggregatorInterface _dexAggregator
    ) public {
        require(msg.sender == admin, "not admin");
        oleToken = _oleToken;
        xoleToken = _xoleToken;
        wETH = _wETH;
        lpoolImplementation = _lpoolImplementation;
        openLev = _openlev;
        dexAggregator = _dexAggregator;
    }

    struct LPoolPairVar {
        address token0;
        address token1;
        uint16 marginLimit;
        bytes dexData;
        string tokenName;
        string tokenSymbol;
    }

    


    /*** Policy Hooks ***/
    

    

    

    

    

    

    

    

    /*** Distribution Functions ***/

    function initDistribution(uint totalAmount, uint64 startTime, uint64 duration) internal pure returns (ControllerStorage.LPoolDistribution memory distribution){
        distribution.startTime = startTime;
        distribution.endTime = startTime + duration;
        require(distribution.endTime >= startTime, 'EndTime is overflow');
        distribution.duration = duration;
        distribution.lastUpdateTime = startTime;
        distribution.totalRewardAmount = totalAmount;
        distribution.rewardRate = totalAmount.div(duration);
    }

    function updateDistribution(ControllerStorage.LPoolDistribution storage distribution, uint addAmount) internal {
        uint256 blockTime = block.timestamp;
        if (blockTime >= distribution.endTime) {
            distribution.rewardRate = addAmount.div(distribution.duration);
        } else {
            uint256 remaining = distribution.endTime - blockTime;
            uint256 leftover = remaining.mul(distribution.rewardRate);
            distribution.rewardRate = addAmount.add(leftover).div(distribution.duration);
        }
        distribution.lastUpdateTime = uint64(blockTime);
        distribution.totalRewardAmount = distribution.totalRewardAmount.add(addAmount);
        distribution.endTime = distribution.duration + uint64(blockTime);
        require(distribution.endTime > blockTime, 'EndTime is overflow');
    }

    function checkStart(LPoolInterface lpool, bool isBorrow) internal view returns (bool){
        return block.timestamp >= lpoolDistributions[lpool][isBorrow].startTime;
    }


    function existRewards(LPoolInterface lpool, bool isBorrow) internal view returns (bool){
        return lpoolDistributions[lpool][isBorrow].totalRewardAmount > 0;
    }

    function lastTimeRewardApplicable(LPoolInterface lpool, bool isBorrow) public view returns (uint256) {
        return Math.min(block.timestamp, lpoolDistributions[lpool][isBorrow].endTime);
    }

    function rewardPerToken(LPoolInterface lpool, bool isBorrow) internal view returns (uint256) {
        LPoolDistribution memory distribution = lpoolDistributions[lpool][isBorrow];
        uint totalAmount = isBorrow ? lpool.totalBorrowsCurrent() : lpool.totalSupply().add(distribution.extraTotalToken);
        if (totalAmount == 0) {
            return distribution.rewardPerTokenStored;
        }
        return
        distribution.rewardPerTokenStored.add(
            lastTimeRewardApplicable(lpool, isBorrow)
            .sub(distribution.lastUpdateTime)
            .mul(distribution.rewardRate)
            .mul(1e18)
            .div(totalAmount)
        );
    }

    function updateReward(LPoolInterface lpool, address account, bool isBorrow) internal returns (bool) {
        if (!existRewards(lpool, isBorrow) || !checkStart(lpool, isBorrow)) {
            return false;
        }
        uint rewardPerTokenStored = rewardPerToken(lpool, isBorrow);
        lpoolDistributions[lpool][isBorrow].rewardPerTokenStored = rewardPerTokenStored;
        lpoolDistributions[lpool][isBorrow].lastUpdateTime = uint64(lastTimeRewardApplicable(lpool, isBorrow));
        if (account != address(0)) {
            lPoolRewardByAccounts[lpool][isBorrow][account].rewards = earnedInternal(lpool, account, isBorrow);
            lPoolRewardByAccounts[lpool][isBorrow][account].rewardPerTokenStored = rewardPerTokenStored;
        }
        return true;
    }

    function stake(LPoolInterface lpool, address account, uint256 amount) internal returns (bool) {
        bool updateSucceed = updateReward(lpool, account, false);
        if (xoleToken == address(0) || XOleInterface(xoleToken).balanceOf(account, 0) < oleTokenDistribution.xoleRaiseMinAmount) {
            return updateSucceed;
        }
        uint addExtraToken = amount.mul(oleTokenDistribution.xoleRaiseRatio).div(100);
        lPoolRewardByAccounts[lpool][false][account].extraToken = lPoolRewardByAccounts[lpool][false][account].extraToken.add(addExtraToken);
        lpoolDistributions[lpool][false].extraTotalToken = lpoolDistributions[lpool][false].extraTotalToken.add(addExtraToken);
        return updateSucceed;
    }

    function withdraw(LPoolInterface lpool, address account, uint256 amount) internal returns (bool)  {
        bool updateSucceed = updateReward(lpool, account, false);
        if (xoleToken == address(0)) {
            return updateSucceed;
        }
        uint extraToken = lPoolRewardByAccounts[lpool][false][account].extraToken;
        if (extraToken == 0) {
            return updateSucceed;
        }
        uint oldBalance = lpool.balanceOf(account);
        //withdraw all
        if (oldBalance == amount) {
            lPoolRewardByAccounts[lpool][false][account].extraToken = 0;
            lpoolDistributions[lpool][false].extraTotalToken = lpoolDistributions[lpool][false].extraTotalToken.sub(extraToken);
        } else {
            uint subExtraToken = extraToken.mul(amount).div(oldBalance);
            lPoolRewardByAccounts[lpool][false][account].extraToken = extraToken.sub(subExtraToken);
            lpoolDistributions[lpool][false].extraTotalToken = lpoolDistributions[lpool][false].extraTotalToken.sub(subExtraToken);
        }
        return updateSucceed;
    }


    function earnedInternal(LPoolInterface lpool, address account, bool isBorrow) internal view returns (uint256) {
        LPoolRewardByAccount memory accountReward = lPoolRewardByAccounts[lpool][isBorrow][account];
        uint accountBalance = isBorrow ? lpool.borrowBalanceCurrent(account) : lpool.balanceOf(account).add(accountReward.extraToken);
        return
        accountBalance
        .mul(rewardPerToken(lpool, isBorrow).sub(accountReward.rewardPerTokenStored))
        .div(1e18)
        .add(accountReward.rewards);
    }

    function getRewardInternal(LPoolInterface lpool, address account, bool isBorrow) internal {
        uint256 reward = earnedInternal(lpool, account, isBorrow);
        if (reward > 0) {
            bool succeed = transferOut(account, reward);
            if (succeed) {
                lPoolRewardByAccounts[lpool][isBorrow][account].rewards = 0;
            }
        }
    }

    function earned(LPoolInterface lpool, address account, bool isBorrow) external override view returns (uint256) {
        if (!existRewards(lpool, isBorrow) || !checkStart(lpool, isBorrow)) {
            return 0;
        }
        return earnedInternal(lpool, account, isBorrow);
    }

    function getSupplyRewards(LPoolInterface[] calldata lpools, address account) external override {
        uint rewards;
        for (uint i = 0; i < lpools.length; i++) {
            if (updateReward(lpools[i], account, false)) {
                rewards = rewards.add(earnedInternal(lpools[i], account, false));
                lPoolRewardByAccounts[lpools[i]][false][account].rewards = 0;
            }
        }
        require(rewards > 0, 'rewards is zero');
        require(oleToken.balanceOf(address(this)) >= rewards, 'balance<rewards');
        oleToken.transfer(account, rewards);
    }


    function transferOut(address to, uint amount) internal returns (bool){
        if (oleToken.balanceOf(address(this)) < amount) {
            return false;
        }
        oleToken.transfer(to, amount);
        return true;
    }
    /*** Admin Functions ***/

    function setOLETokenDistribution(uint moreSupplyBorrowBalance, uint moreExtraBalance, uint128 updatePricePer, uint128 liquidatorMaxPer, uint16 liquidatorOLERatio, uint16 xoleRaiseRatio, uint128 xoleRaiseMinAmount) external override onlyAdmin {
        uint newSupplyBorrowBalance = oleTokenDistribution.supplyBorrowBalance.add(moreSupplyBorrowBalance);
        uint newExtraBalance = oleTokenDistribution.extraBalance.add(moreExtraBalance);
        uint totalAll = newExtraBalance.add(newSupplyBorrowBalance);
        require(oleToken.balanceOf(address(this)) >= totalAll, 'not enough balance');
        oleTokenDistribution.supplyBorrowBalance = newSupplyBorrowBalance;
        oleTokenDistribution.extraBalance = newExtraBalance;
        oleTokenDistribution.updatePricePer = updatePricePer;
        oleTokenDistribution.liquidatorMaxPer = liquidatorMaxPer;
        oleTokenDistribution.liquidatorOLERatio = liquidatorOLERatio;
        oleTokenDistribution.xoleRaiseRatio = xoleRaiseRatio;
        oleTokenDistribution.xoleRaiseMinAmount = xoleRaiseMinAmount;
    }

    function distributeRewards2Pool(address pool, uint supplyAmount, uint borrowAmount, uint64 startTime, uint64 duration) external override onlyAdmin {
        require(supplyAmount > 0 || borrowAmount > 0, 'amount is less than 0');
        require(startTime > block.timestamp, 'startTime < blockTime');
        if (supplyAmount > 0) {
            require(lpoolDistributions[LPoolInterface(pool)][false].startTime == 0, 'Distribute only once');
            lpoolDistributions[LPoolInterface(pool)][false] = initDistribution(supplyAmount, startTime, duration);
        }
        if (borrowAmount > 0) {
            require(lpoolDistributions[LPoolInterface(pool)][true].startTime == 0, 'Distribute only once');
            lpoolDistributions[LPoolInterface(pool)][true] = initDistribution(borrowAmount, startTime, duration);
        }
        uint subAmount = supplyAmount.add(borrowAmount);
        oleTokenDistribution.supplyBorrowBalance = oleTokenDistribution.supplyBorrowBalance.sub(subAmount);
        emit Distribution2Pool(pool, supplyAmount, borrowAmount, startTime, duration);
    }

    function distributeRewards2PoolMore(address pool, uint supplyAmount, uint borrowAmount) external override onlyAdmin {
        require(supplyAmount > 0 || borrowAmount > 0, 'amount0 and amount1 is 0');
        if (supplyAmount > 0) {
            updateReward(LPoolInterface(pool), address(0), false);
            updateDistribution(lpoolDistributions[LPoolInterface(pool)][false], supplyAmount);
        }
        if (borrowAmount > 0) {
            updateReward(LPoolInterface(pool), address(0), true);
            updateDistribution(lpoolDistributions[LPoolInterface(pool)][true], borrowAmount);
        }
        uint subAmount = supplyAmount.add(borrowAmount);
        oleTokenDistribution.supplyBorrowBalance = oleTokenDistribution.supplyBorrowBalance.sub(subAmount);
    }

    function distributeExtraRewards2Market(uint marketId, bool isDistribution) external override onlyAdminOrDeveloper {
        marketExtraDistribution[marketId] = isDistribution;
    }

    function setLPoolImplementation(address _lpoolImplementation) external override onlyAdmin {
        lpoolImplementation = _lpoolImplementation;
    }

    function setOpenLev(address _openlev) external override onlyAdmin {
        openLev = _openlev;
    }

    function setDexAggregator(DexAggregatorInterface _dexAggregator) external override onlyAdmin {
        dexAggregator = _dexAggregator;
    }

    function setInterestParam(uint256 _baseRatePerBlock, uint256 _multiplierPerBlock, uint256 _jumpMultiplierPerBlock, uint256 _kink) external override onlyAdmin {
        baseRatePerBlock = _baseRatePerBlock;
        multiplierPerBlock = _multiplierPerBlock;
        jumpMultiplierPerBlock = _jumpMultiplierPerBlock;
        kink = _kink;
    }

    function setLPoolUnAllowed(address lpool, bool unAllowed) external override onlyAdminOrDeveloper {
        lpoolUnAlloweds[lpool] = unAllowed;
    }

    function setSuspend(bool _uspend) external override onlyAdminOrDeveloper {
        suspend = _uspend;
    }

    modifier onlyLPoolSender(address lPool) {
        require(msg.sender == lPool, "Sender not lPool");
        _;
    }
    modifier onlyLPoolAllowed(address lPool) {
        require(!lpoolUnAlloweds[lPool], "LPool paused");
        _;
    }
    modifier onlyNotSuspended() {
        require(!suspend, 'Suspended');
        _;
    }
    modifier onlyOpenLevOperator(address operator) {
        require(openLev == operator || openLev == address(0), "Operator not openLev");
        _;
    }

}

interface OPENLevInterface {
    function addMarket(
        LPoolInterface pool0,
        LPoolInterface pool1,
        uint16 marginLimit,
        bytes memory dexData
    ) external returns (uint16);
}

interface XOleInterface {
    function balanceOf(address addr, uint256 _t) external view returns (uint256);
}

