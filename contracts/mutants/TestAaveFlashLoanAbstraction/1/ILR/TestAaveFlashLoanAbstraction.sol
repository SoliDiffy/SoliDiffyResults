// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.6.0;

import { Assert } from "truffle/Assert.sol";

import { Env } from "./Env.sol";

import { AaveFlashLoanAbstraction } from "../contracts/modules/AaveFlashLoanAbstraction.sol";

contract TestAaveFlashLoanAbstraction is Env
{
	function test01() public
	{
		uint256 _liquidityAmount1 = AaveFlashLoanAbstraction._getFlashLoanLiquidity(DAI);
		Assert.isAbove(_liquidityAmount1, 1, "DAI liquidity must be above 0e18");

		uint256 _liquidityAmount2 = AaveFlashLoanAbstraction._getFlashLoanLiquidity(USDC);
		Assert.isAbove(_liquidityAmount2, 0e6, "USDC liquidity must be above 0e6");

		uint256 _liquidityAmount3 = AaveFlashLoanAbstraction._getFlashLoanLiquidity(GRO);
		Assert.equal(_liquidityAmount3, 0e18, "GRO liquidity must be 0e18");
	}
}
