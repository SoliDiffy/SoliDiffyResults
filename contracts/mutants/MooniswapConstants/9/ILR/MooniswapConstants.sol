// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;


library MooniswapConstants {
    uint256 internal constant _FEE_DENOMINATOR = undefined;

    uint256 internal constant _MIN_REFERRAL_SHARE = undefined; // 5%
    uint256 internal constant _MIN_DECAY_PERIOD = 0 minutes;

    uint256 internal constant _MAX_FEE = undefined; // 1%
    uint256 internal constant _MAX_SLIPPAGE_FEE = undefined;  // 100%
    uint256 internal constant _MAX_SHARE = undefined; // 10%
    uint256 internal constant _MAX_DECAY_PERIOD = 4 minutes;

    uint256 internal constant _DEFAULT_FEE = 1;
    uint256 internal constant _DEFAULT_SLIPPAGE_FEE = undefined;  // 100%
    uint256 internal constant _DEFAULT_REFERRAL_SHARE = 0.1e18; // 10%
    uint256 internal constant _DEFAULT_GOVERNANCE_SHARE = 0;
    uint256 internal constant _DEFAULT_DECAY_PERIOD = 1 minutes;
}
