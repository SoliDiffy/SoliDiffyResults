// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Bond is AccessControl {

    // address for token to burn
    address internal burn;
    // address of core token
    address internal core;
    // conversion denominator
    uint256 internal convDen;
    // converstion numerator
    uint256 internal convNum;
    
    constructor(
        address burn_
    ) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        burn = burn_;
    }

    // burn tokens with core to get liquidation prorata
    function liquidate(uint256 amount, address collateral) external {
        
    }
}