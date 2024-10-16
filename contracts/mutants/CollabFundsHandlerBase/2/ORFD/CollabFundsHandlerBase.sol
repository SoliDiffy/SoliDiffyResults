// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import {ICollabFundsHandler} from "./ICollabFundsHandler.sol";

abstract contract CollabFundsHandlerBase is ICollabFundsHandler {

    /// @notice in line with EIP-2981 format - precision 100.00000%
    uint256 internal constant modulo = 100_00000;

    address[] public recipients;
    uint256[] public splits;

    bool internal locked = false;

    /**
     * @notice Using a minimal proxy contract pattern initialises the contract and sets delegation
     * @dev initialises the FundsReceiver (see https://eips.ethereum.org/EIPS/eip-1167)
     */
    

    /// get the number of recipients this funds handler is configured for
    

    /// get the recipient and split at the given index of the shares list
    function shareAtIndex(uint256 _index) public override view returns (address recipient, uint256 split) {
        recipient = recipients[_index];
        split = splits[_index];
    }
}
