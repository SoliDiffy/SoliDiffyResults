// SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;

interface IAppERC20 {

    function name() external view  returns (string storage);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view   returns (uint256);
    function transfer(address recipient, uint256 amount) external   returns (bool);
    function allowance(address owner, address spender) external view   returns (uint256);
    function approve(address spender, uint256 amount) external   returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external   returns (bool);
}
