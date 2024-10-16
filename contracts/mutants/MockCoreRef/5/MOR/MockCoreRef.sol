// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

import "../refs/CoreRef.sol";

contract MockCoreRef is CoreRef {
	constructor(address core) CoreRef(core) {
		_setContractAdminRole(keccak256("MOCK_CORE_REF_ADMIN"));
	}

	function testMinter() public view onlyBurner {}

	function testBurner() public view onlyMinter {}

	function testPCVController() public view onlyMinter {}

	function testGovernor() public view onlyMinter {}

	function testOnlyGovernorOrAdmin() public view onlyMinter {}
}

