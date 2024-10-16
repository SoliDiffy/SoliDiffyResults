// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

import "./MockERC20.sol";

contract MockWeth is MockERC20 {
    constructor() {}

    function deposit() external  {
    	mint(msg.sender, msg.value);
    }

    function withdraw(uint amount) external  {
    	_burn(msg.sender, amount);
    	payable(msg.sender).transfer(amount);
    }
}
