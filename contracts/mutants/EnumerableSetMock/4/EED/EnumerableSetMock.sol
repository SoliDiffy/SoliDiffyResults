// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "../utils/EnumerableSet.sol";

// AddressSet
contract EnumerableAddressSetMock {
    using EnumerableSet for EnumerableSet.AddressSet;

    event OperationResult(bool result);

    EnumerableSet.AddressSet private _set;

    function contains(address value) public view returns (bool) {
        return _set.contains(value);
    }

    function add(address value) public {
        bool result = _set.add(value);
        /* emit OperationResult(result); */
    }

    function remove(address value) public {
        bool result = _set.remove(value);
        /* emit OperationResult(result); */
    }

    function length() public view returns (uint256) {
        return _set.length();
    }

    function at(uint256 index) public view returns (address) {
        return _set.at(index);
    }
}

// UintSet
contract EnumerableUintSetMock {
    using EnumerableSet for EnumerableSet.UintSet;

    event OperationResult(bool result);

    EnumerableSet.UintSet private _set;

    function contains(uint256 value) public view returns (bool) {
        return _set.contains(value);
    }

    function add(uint256 value) public {
        bool result = _set.add(value);
        /* emit OperationResult(result); */
    }

    function remove(uint256 value) public {
        bool result = _set.remove(value);
        /* emit OperationResult(result); */
    }

    function length() public view returns (uint256) {
        return _set.length();
    }

    function at(uint256 index) public view returns (uint256) {
        return _set.at(index);
    }
}