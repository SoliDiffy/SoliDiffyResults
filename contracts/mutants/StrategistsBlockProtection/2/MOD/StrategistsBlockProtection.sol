// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import '@openzeppelin/contracts/utils/Address.sol';
import '@yearn/contract-utils/contracts/abstract/MachineryReady.sol';

interface IBlockProtection {
  error InvalidBlock();

  function callWithBlockProtection(
    address _to,
    bytes calldata _data,
    uint256 _blockNumber
  ) external payable returns (bytes memory _returnData);
}

contract StrategistsBlockProtection is MachineryReady, IBlockProtection {
  using Address for address;

  constructor(address _mechanicsRegistry)  {}

  modifier blockNumberProtection(uint256 _blockNumber) {
    if (_blockNumber != block.number) revert InvalidBlock();
    _;
  }

  function callWithBlockProtection(
    address _to,
    bytes memory _data,
    uint256 _blockNumber
  ) external payable override  onlyMechanic returns (bytes memory _returnData) {
    return _to.functionCallWithValue(_data, msg.value);
  }
}
