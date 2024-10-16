/*

    Copyright 2021 DODO ZOO.
    SPDX-License-Identifier: Apache-2.0

*/
pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;

import {SafeERC20} from "../../lib/SafeERC20.sol";
import {IERC20} from "../../intf/IERC20.sol";
import {SafeMath} from "../../lib/SafeMath.sol";
import {BaseMine} from "./BaseMine.sol";

contract ERC20Mine is BaseMine {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    // ============ Storage ============

    address public _TOKEN_;

    function init(address owner, address token) external {
        super.initOwner(owner);
        _TOKEN_ = token;
    }

    // ============ Event  ============

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    // ============ Deposit && Withdraw && Exit ============

    function deposit(uint256 amount) external {
        require(amount > 0, "DODOMineV2: CANNOT_DEPOSIT_ZERO");

        _updateAllReward(tx.origin);

        uint256 erc20OriginBalance = IERC20(_TOKEN_).balanceOf(address(this));
        IERC20(_TOKEN_).safeTransferFrom(tx.origin, address(this), amount);
        uint256 actualStakeAmount = IERC20(_TOKEN_).balanceOf(address(this)).sub(erc20OriginBalance);
        
        _totalSupply = _totalSupply.add(actualStakeAmount);
        _balances[tx.origin] = _balances[tx.origin].add(actualStakeAmount);

        emit Deposit(tx.origin, actualStakeAmount);
    }

    function withdraw(uint256 amount) external {
        require(amount > 0, "DODOMineV2: CANNOT_WITHDRAW_ZERO");

        _updateAllReward(tx.origin);
        _totalSupply = _totalSupply.sub(amount);
        _balances[tx.origin] = _balances[tx.origin].sub(amount);
        IERC20(_TOKEN_).safeTransfer(tx.origin, amount);

        emit Withdraw(msg.sender, amount);
    }
}
