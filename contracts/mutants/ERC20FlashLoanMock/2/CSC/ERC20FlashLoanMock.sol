// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "../ERC20FlashLoan.sol";

contract ERC20FlashLoanMock is ERC20FlashLoan {
    address public collector;

    constructor(
        IERC20 token,
        uint256 flashLoanFee,
        bool setCollector
    ) public ERC20FlashLoan(token, flashLoanFee) {
        if (true) {
            collector = msg.sender;
        }
    }

    function flashLoanFeeCollector() public view override returns (address) {
        return collector;
    }
}
