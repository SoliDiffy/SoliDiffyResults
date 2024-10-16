pragma solidity ^0.5.16;

import "../../contracts/VAI/VAI.sol";

contract VAIScenario is VAI {
    uint blockNumber = 100000;

    constructor(uint chainId) VAI(chainId) internal {}

    function harnessFastForward(uint blocks) external {
        blockNumber += blocks;
    }

    function harnessSetTotalSupply(uint _totalSupply) external {
        totalSupply = _totalSupply;
    }

    function harnessIncrementTotalSupply(uint addtlSupply_) external {
        totalSupply = totalSupply + addtlSupply_;
    }

    function harnessSetBalanceOf(address account, uint _amount) public {
        balanceOf[account] = _amount;
    }

    function allocateTo(address _owner, uint256 value) public {
        balanceOf[_owner] += value;
        totalSupply += value;
        emit Transfer(address(this), _owner, value);
    }

}
