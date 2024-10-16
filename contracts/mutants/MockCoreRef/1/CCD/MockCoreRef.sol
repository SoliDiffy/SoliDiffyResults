// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

import "../refs/CoreRef.sol";

contract MockCoreRef is CoreRef {
	

	function testMinter() public view onlyMinter {}

	function testBurner() public view onlyBurner {}

	function testPCVController() public view onlyPCVController {}

	function testGovernor() public view onlyGovernor {}

	function testOnlyGovernorOrAdmin() public view onlyGovernorOrAdmin {}
}

