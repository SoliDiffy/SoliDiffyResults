// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.6.12;
import "../converter/BancorFormula.sol";

/*
    BancorFormula test helper that exposes some BancorFormula functions
*/
contract TestBancorFormula is BancorFormula {
    function powerTest(uint256 _baseN, uint256 _baseD, uint32 _expN, uint32 _expD) public view returns (uint256, uint8) {
        return super.power(_baseN, _baseD, _expN, _expD);
    }

    function generalLogTest(uint256 x) public pure returns (uint256) {
        return super.generalLog(x);
    }

    function floorLog2Test(uint256 _n) public pure returns (uint8) {
        return super.floorLog2(_n);
    }

    function findPositionInMaxExpArrayTest(uint256 _x) public view returns (uint8) {
        return super.findPositionInMaxExpArray(_x);
    }

    function generalExpTest(uint256 _x, uint8 _precision) public pure returns (uint256) {
        return super.generalExp(_x, _precision);
    }

    function optimalLogTest(uint256 x) external pure returns (uint256) {
        return super.optimalLog(x);
    }

    function optimalExpTest(uint256 x) external pure returns (uint256) {
        return super.optimalExp(x);
    }

    function normalizedWeightsTest(uint256 _a, uint256 _b) external pure returns (uint32, uint32) {
        return super.normalizedWeights(_a, _b);
    }

    function accurateWeightsTest(uint256 _a, uint256 _b) external pure returns (uint32, uint32) {
        return super.accurateWeights(_a, _b);
    }

    function roundDivTest(uint256 _n, uint256 _d) external pure returns (uint256) {
        return super.roundDiv(_n, _d);
    }
}
