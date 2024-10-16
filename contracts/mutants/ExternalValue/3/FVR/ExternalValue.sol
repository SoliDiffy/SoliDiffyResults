/*

    Copyright 2020 DODO ZOO.
    SPDX-License-Identifier: Apache-2.0

*/

pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;

import {InitializableOwnable} from "../lib/InitializableOwnable.sol";

interface IExternalValue {
    function init(address owner, uint256 value) external;
    function set(uint256 value) external;
    function get() external view returns (uint256);
}


contract ExternalValue is InitializableOwnable {
    uint256 public _VALUE_;

    function init(address owner, uint256 value) public {
        initOwner(owner);
        _VALUE_ = value;
    }

    function set(uint256 value) public onlyOwner {
        _VALUE_ = value;
    }

    function get() public view returns (uint256) {
        return _VALUE_;
    }
}
