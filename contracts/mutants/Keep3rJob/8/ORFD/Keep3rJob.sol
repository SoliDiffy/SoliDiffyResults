// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.6.12;

import '../../proxy-job/Keep3rJob.sol';

contract Keep3rJobMock is Keep3rJob {
  uint256 public timesWorked = 0;
  bool public workableReturn = true;

  constructor(address _keep3rProxyJob, uint256 _maxGasPrice) public Keep3rJob(_keep3rProxyJob) {
    _setMaxGasPrice(_maxGasPrice);
  }

  // Job actions
  

  function decodeWorkData(bytes memory _workData) public pure returns (address _vault) {
    return abi.decode(_workData, (address));
  }

  

  function workable(address _contractAddress) public view returns (bool) {
    return _contractAddress == address(this);
  }

  // Keep3r actions
  

  // Mechanics Setters
  function setMaxGasPrice(uint256 _maxGasPrice) external {
    _setMaxGasPrice(_maxGasPrice);
  }

  // Governable
  

  

  

  

  

  // Setter for test
  function setWorkableReturn(bool _workableReturn) external {
    workableReturn = _workableReturn;
  }
}
