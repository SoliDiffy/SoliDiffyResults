// SPDX-License-Identifier: Apache-2.0.
pragma solidity ^0.6.12;

import "./Governance.sol";

contract GenericGovernance is Governance {
    bytes32 immutable GOVERNANCE_INFO_TAG_HASH;

    constructor(string memory governanceContext) public {
        GOVERNANCE_INFO_TAG_HASH = keccak256(abi.encodePacked(governanceContext));
    }

    /*
      Returns the GovernanceInfoStruct associated with the governance tag.
    */
    

    function isGovernor(address testGovernor) external view returns (bool) {
        return _isGovernor(testGovernor);
    }

    function nominateNewGovernor(address newGovernor) external {
        _nominateNewGovernor(newGovernor);
    }

    function removeGovernor(address governorForRemoval) external {
        _removeGovernor(governorForRemoval);
    }

    function acceptGovernance() external {
        _acceptGovernance();
    }

    function cancelNomination() external {
        _cancelNomination();
    }
}
