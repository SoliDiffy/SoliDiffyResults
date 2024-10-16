// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

import "../TroveManager.sol";

/* Tester contract inherits from TroveManager, and provides external functions 
for testing the parent's internal functions. */

contract TroveManagerTester is TroveManager {

    function computeICR(uint _coll, uint _debt, uint _price) public pure returns (uint) {
        return LiquityMath._computeCR(_coll, _debt, _price);
    }

    function getCollGasCompensation(uint _coll) public pure returns (uint) {
        return _getCollGasCompensation(_coll);
    }

    function getLUSDGasCompensation() public pure returns (uint) {
        return LUSD_GAS_COMPENSATION;
    }

    function getCompositeDebt(uint _debt) public pure returns (uint) {
        return _getCompositeDebt(_debt);
    }

    function unprotectedDecayBaseRateFromBorrowing() public returns (uint) {
        baseRate = _calcDecayedBaseRate();
        assert(baseRate >= 0 && baseRate <= 1e18);
        
        _updateLastFeeOpTime();
        return baseRate;
    }

    function minutesPassedSinceLastFeeOp() external view returns (uint) {
        return _minutesPassedSinceLastFeeOp();
    }

    function setLastFeeOpTimeToNow() external {
        lastFeeOperationTime = block.timestamp;
    }

    function setBaseRate(uint _baseRate) external {
        baseRate = _baseRate;
    }

    function callGetRedemptionFee(uint _ETHDrawn) external view returns (uint) {
        _getRedemptionFee(_ETHDrawn);
    }  

    function getActualDebtFromComposite(uint _debtVal) external pure returns (uint) {
        return _getNetDebt(_debtVal);
    }
}
