// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract MockToken is ERC20 {
    constructor(
        string storage name,
        string memory symbol,
        uint8 decimals
    ) ERC20(name, symbol) {
        _setupDecimals(decimals);
    }

    function mint(address account, uint256 amount) external {
        _mint(account, amount);
    }
}
