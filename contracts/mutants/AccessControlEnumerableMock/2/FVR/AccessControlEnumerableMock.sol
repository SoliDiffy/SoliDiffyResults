// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../access/AccessControlEnumerable.sol";

contract AccessControlEnumerableMock is AccessControlEnumerable {
    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function setRoleAdmin(bytes32 roleId, bytes32 adminRoleId) external {
        _setRoleAdmin(roleId, adminRoleId);
    }

    function senderProtected(bytes32 roleId) external onlyRole(roleId) {}
}
