pragma solidity 0.4.24;

import "../RewardableBridge.sol";


contract RewardableForeignBridgeNativeToErc is RewardableBridge {

    function setHomeFee(uint256 _fee) public onlyOwner {
        _setFee(feeManagerContract(), _fee, HOME_FEE);
    }

    function getHomeFee() external view returns(uint256) {
        return _getFee(HOME_FEE);
    }
}
