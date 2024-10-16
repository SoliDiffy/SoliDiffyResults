// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.12;

import "../interfaces/IFlashAngle.sol";
import "../interfaces/ICoreBorrow.sol";

contract MockFlashLoanModule is IFlashAngle {
    ICoreBorrow public override core;
    mapping(address => bool) public stablecoinsSupported;
    mapping(IAgToken => uint256) public interestAccrued;
    uint256 public surplusValue;

    constructor(ICoreBorrow _core) {
        core = _core;
    }

    

    

    

    

    function setSurplusValue(uint256 _surplusValue) external {
        surplusValue = _surplusValue;
    }
}
