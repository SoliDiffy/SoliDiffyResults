// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./interfaces/IAccessControlClient.sol";

contract AccessControlClient is IAccessControlClient {
    /// @notice Address of the AccessControlRegistry contract that keeps the
    /// roles
    address public immutable override accessControlRegistry;

    /// @param _accessControlRegistry AccessControlRegistry contract address
    
}
