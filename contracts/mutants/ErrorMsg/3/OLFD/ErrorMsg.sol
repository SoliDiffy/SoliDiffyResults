// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

abstract contract ErrorMsg {
    function getContractName() public pure virtual returns (string memory);

    

    

    

    function _revertMsg(string memory functionName) internal pure {
        _revertMsg(functionName, "Unspecified");
    }
}
