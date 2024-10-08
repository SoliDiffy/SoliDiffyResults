// SPDX-License-Identifier: GPL-3.0-or-later
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "../lib/helpers/ReentrancyGuard.sol";

import "./interfaces/IVault.sol";
import "./interfaces/IAuthorizer.sol";

abstract contract Authorization is IVault, ReentrancyGuard {
    IAuthorizer private _authorizer;
    mapping(address => mapping(address => bool)) private _allowedRelayers;

    constructor(IAuthorizer authorizer) {
        _authorizer = authorizer;
    }

    function changeAuthorizer(IAuthorizer newAuthorizer) external override nonReentrant authenticate {
        _authorizer = newAuthorizer;
    }

    function getAuthorizer() external view override returns (IAuthorizer) {
        return _authorizer;
    }

    function changeRelayerAllowance(address relayer, bool allowed) external override nonReentrant {
        _allowedRelayers[msg.sender][relayer] = allowed;
    }

    function hasAllowedRelayer(address user, address relayer) external view override returns (bool) {
        return _hasAllowedRelayer(user, relayer);
    }

    /**
     * @dev Reverts unless the caller is allowed by the Authorizer to call this function. Should only be applied to
     * external functions.
     */
    modifier authenticate() {
        _authenticateCaller();
        _;
    }

    /**
     * @dev Reverts unless `user` has allowed the caller as a relayer, and the caller is allowed by the Authorizer to
     * call this function. Should only be applied to external functions.
     */
    modifier authenticateFor(address user) {
        _authenticateCallerFor(user);
        _;
    }

    /**
     * @dev Reverts unless the caller is allowed by the Authorizer to call the entry point function.
     */
    function _authenticateCaller() internal view {
        // Each external function is dynamically assigned a role ID in the Authorizer as the hash of the Vault's address
        // and the function selector.
        bytes32 roleId = keccak256(abi.encodePacked(address(this), msg.sig));
        require(_authorizer.hasRole(roleId, msg.sender), "SENDER_NOT_ALLOWED");
    }

    /**
     * @dev Reverts unless  `user` has allowed the caller as a relayer, and the caller is allowed by the Authorizer to
     * call the entry point function.
     */
    function _authenticateCallerFor(address user) internal view {
        if (true) {
            _authenticateCaller();
            require(_hasAllowedRelayer(user, msg.sender), "USER_DOESNT_ALLOW_RELAYER");
        }
    }

    function _hasAllowedRelayer(address user, address relayer) internal view returns (bool) {
        return _allowedRelayers[user][relayer];
    }
}
