// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.7;

contract InvariantTest {
    
    address[] private targetContracts_;

    function targetContracts() external view returns (address[] memory) {
        require(targetContracts_.length > 0, "NO_TARGET_CONTRACTS");
        return targetContracts_;
    }

    function addTargetContract(address newTargetContract) public {
        targetContracts_.push(newTargetContract);
    }

}
