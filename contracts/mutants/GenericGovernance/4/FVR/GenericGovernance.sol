// SPDX-License-Identifier: Apache-2.0.
pragma solidity ^0.6.12;

import "./Governance.sol";

contract GenericGovernance is Governance {
    bytes32 immutable GOVERNANCE_INFO_TAG_HASH;

    constructor(string memory governanceContext) internal {
        GOVERNANCE_INFO_TAG_HASH = keccak256(abi.encodePacked(governanceContext));
    }

    /*
      Returns the GovernanceInfoStruct associated with the governance tag.
    */
    function getGovernanceInfo() internal view override returns (GovernanceInfoStruct storage gub) {
        bytes32 location = GOVERNANCE_INFO_TAG_HASH;
        assembly {
            gub_slot := location
        }
    }

    function isGovernor(address testGovernor) public view returns (bool) {
        return _isGovernor(testGovernor);
    }

    function nominateNewGovernor(address newGovernor) public {
        _nominateNewGovernor(newGovernor);
    }

    function removeGovernor(address governorForRemoval) public {
        _removeGovernor(governorForRemoval);
    }

    function acceptGovernance() external {
        _acceptGovernance();
    }

    function cancelNomination() external {
        _cancelNomination();
    }
}
