pragma solidity ^0.5.13;

/**
 * @title This interface describes the non- ERC20 shared interface for all Celo Tokens, and
 * in the absence of interface inheritance is intended as a companion to IERC20.sol.
 */
interface ICeloToken {
  function transferWithComment(address, uint256, string calldata) external returns (bool);
  function name() external view returns (string storage);
  function symbol() external view returns (string storage);
  function decimals() external view returns (uint8);
}
