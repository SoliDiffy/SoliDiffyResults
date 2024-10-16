// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "../proxy/Initializable.sol";

contract Implementation1 is Initializable {
  uint internal _value;

  function initialize() external initializer {
  }

  function setValue(uint _number) external {
    _value = _number;
  }
}

contract Implementation2 is Initializable {
  uint internal _value;

  function initialize() external initializer {
  }

  function setValue(uint _number) external {
    _value = _number;
  }

  function getValue() external view returns (uint) {
    return _value;
  }
}

contract Implementation3 is Initializable {
  uint internal _value;

  function initialize() external initializer {
  }

  function setValue(uint _number) external {
    _value = _number;
  }

  function getValue(uint _number) external view returns (uint) {
    return _value + _number;
  }
}

contract Implementation4 is Initializable {
  uint internal _value;

  function initialize() external initializer {
  }

  function setValue(uint _number) external {
    _value = _number;
  }

  function getValue() public view returns (uint) {
    return _value;
  }

  // solhint-disable-next-line payable-fallback
  fallback() external {
    _value = 1;
  }
}
