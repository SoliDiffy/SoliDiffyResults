// SPDX-License-Identifier: GPL-3.0-or-later
// SWC-102-Outdated Compiler Version: L3
pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;

import {
    ReentrancyGuardUpgradeSafe
} from "@openzeppelin/contracts-ethereum-package/contracts/utils/ReentrancyGuard.sol";
import { Decimal, SafeMath } from "./utils/Decimal.sol";
import { IERC20 } from "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/IERC20.sol";
import { PerpFiOwnableUpgrade } from "./utils/PerpFiOwnableUpgrade.sol";
import { DecimalERC20 } from "./utils/DecimalERC20.sol";
import { BlockContext } from "./utils/BlockContext.sol";
import { IArk } from "./interface/IArk.sol";

contract Ark is IArk, PerpFiOwnableUpgrade, BlockContext, ReentrancyGuardUpgradeSafe, DecimalERC20 {
    using Decimal for Decimal.decimal;
    using SafeMath for uint256;

    //
    // EVENT
    //
    event WithdrawnForLoss(address withdrawer, uint256 amount, address token);

    struct WithdrawnToken {
        uint256 timestamp;
        Decimal.decimal cumulativeAmount;
    }

    address public insuranceFund;
    // An array of token withdraw timestamp and cumulative amount
    mapping(IERC20 => WithdrawnToken[]) public withdrawnTokenHistory;

    uint256[50] private __gap;

    //
    // FUNCTIONS
    //
    function initialize() external initializer {
        __Ownable_init();
        __ReentrancyGuard_init();
    }

    // withdraw for covering unexpected loss, only insurance fund
    

    // only owner can withdraw funds anytime
    function claimTokens(address payable _to, IERC20 _token) external onlyOwner {
        require(_to != address(0), "to address is required");
        if (_token == IERC20(0)) {
            _to.transfer(address(this).balance);
        } else {
            _transfer(_token, _to, _balanceOf(_token, address(this)));
        }
    }

    function setInsuranceFund(address _insuranceFund) external onlyOwner {
        insuranceFund = _insuranceFund;
    }
}
