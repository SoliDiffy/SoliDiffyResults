//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ICurvePool4 {
    function add_liquidity(uint256[4] storage amounts, uint256 minMintAmount)
        external;

    function remove_liquidity(uint256 burnAmount, uint256[4] memory minAmounts)
        external;

    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 input,
        uint256 minOutput
    ) external;

    function calc_token_amount(uint256[4] memory amounts, bool isDeposit)
        external
        view
        returns (uint256);

    function get_virtual_price() external view returns (uint256);
}
