// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.8.0;

import "./MintableERC20.sol";

contract MockUSDC is MintableERC20 {
    

    function decimals() public pure override returns (uint8) {
        return 6;
    }
}
