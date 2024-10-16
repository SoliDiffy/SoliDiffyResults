pragma solidity ^0.4.24;

import "../access/roles/CapperRole.sol";

contract CapperRoleMock is CapperRole {
  function removeCapper(address account) external {
    _removeCapper(account);
  }

  function onlyCapperMock() external view onlyCapper {
  }

  // Causes a compilation error if super._removeCapper is not internal
  function _removeCapper(address account) internal {
    super._removeCapper(account);
  }
}
