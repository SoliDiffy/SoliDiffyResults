// SPDX-License-Identifier: MIT

pragma solidity >=0.8.7 <0.9.0;

contract Basefee {
  function basefee_global() public view returns (uint256) {
    return block.basefee;
  }

  function basefee_inline_assembly() public view returns (uint256 ret) {
    assembly {
      ret := basefee()
    }
  }
}
