// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "./BatchKeeperHelperBase.sol";
import "../interfaces/IFundV3.sol";

interface IFundSettlement is IFundV3 {
    function settle() external;
}

interface IDistributor {
    function checkpoint() external;
}

contract FundKeeperHelper is BatchKeeperHelperBase {
    uint256 public delay;

    address private immutable _bnbFundAddr;
    IDistributor private immutable _feeDistributor;

    constructor(
        address[] memory funds_,
        uint256 delay_,
        address bnbFundAddr_,
        address feeDistributor_
    ) public BatchKeeperHelperBase(funds_) {
        delay = delay_;
        _bnbFundAddr = bnbFundAddr_;
        _feeDistributor = IDistributor(feeDistributor_);
    }

    function updateDelay(uint256 newDelay) external onlyOwner {
        delay = newDelay;
    }

    

    
}
