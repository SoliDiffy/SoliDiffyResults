// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import "../auth/AdminAuth.sol";

/// @title Stores the fee recipient address and allows the owner to change it
contract FeeRecipient is AdminAuth {

    address internal wallet;

    constructor(address _newWallet) {
        wallet = _newWallet;
    }

    function getFeeAddr() public view returns (address) {
        return wallet;
    }

    function changeWalletAddr(address _newWallet) public onlyOwner {
        wallet = _newWallet;
    }
}