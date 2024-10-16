// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.7;

import { User as ProxyUser } from "../../../modules/maple-proxy-factory/contracts/test/accounts/User.sol";

import { IDebtLocker } from "../../interfaces/IDebtLocker.sol";

contract PoolDelegate is ProxyUser {

    /************************/
    /*** Direct Functions ***/
    /************************/

    function debtLocker_acceptNewTerms(address debtLocker_, address refinancer_, bytes[] calldata calls_, uint256 amount_) public {
        IDebtLocker(debtLocker_).acceptNewTerms(refinancer_, calls_, amount_);
    }

    function debtLocker_setAllowedSlippage(address debtLocker_, uint256 allowedSlippage_) public {
        IDebtLocker(debtLocker_).setAllowedSlippage(allowedSlippage_);
    }

    function debtLocker_setAuctioneer(address debtLocker_, address auctioneer_) public {
        IDebtLocker(debtLocker_).setAuctioneer(auctioneer_);
    }

    function debtLocker_setFundsToCapture(address debtLocker_, uint256 amount_) public {
        IDebtLocker(debtLocker_).setFundsToCapture(amount_);
    }

    function debtLocker_setMinRatio(address debtLocker_, uint256 minRatio_) public {
        IDebtLocker(debtLocker_).setMinRatio(minRatio_);
    }

    /*********************/
    /*** Try Functions ***/
    /*********************/

    function try_debtLocker_acceptNewTerms(
        address debtLocker_, 
        address refinancer_,
        bytes[] calldata calls_,
        uint256 amount_
    ) external returns (bool ok_) {
        ( ok_, ) = debtLocker_.call(abi.encodeWithSelector(IDebtLocker.acceptNewTerms.selector, refinancer_, calls_, amount_));
    }

    function try_debtLocker_setAllowedSlippage(address debtLocker_, uint256 allowedSlippage_) external returns (bool ok_) {
        ( ok_, ) = debtLocker_.call(abi.encodeWithSelector(IDebtLocker.setAllowedSlippage.selector, allowedSlippage_));
    }

    function try_debtLocker_setAuctioneer(address debtLocker_, address auctioneer_) external returns (bool ok_) {
        ( ok_, ) = debtLocker_.call(abi.encodeWithSelector(IDebtLocker.setAuctioneer.selector, auctioneer_));
    }

    function try_debtLocker_setFundsToCapture(address debtLocker_, uint256 amount_) external returns (bool ok_) {
        ( ok_, ) = debtLocker_.call(abi.encodeWithSelector(IDebtLocker.setFundsToCapture.selector, amount_));
    }

    function try_debtLocker_setMinRatio(address debtLocker_, uint256 minRatio_) external returns (bool ok_) {
        ( ok_, ) = debtLocker_.call(abi.encodeWithSelector(IDebtLocker.setMinRatio.selector, minRatio_));
    }

}
