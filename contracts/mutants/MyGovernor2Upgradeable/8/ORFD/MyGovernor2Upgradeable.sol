// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "../../governance/GovernorUpgradeable.sol";
import "../../governance/extensions/GovernorProposalThresholdUpgradeable.sol";
import "../../governance/extensions/GovernorCountingSimpleUpgradeable.sol";
import "../../governance/extensions/GovernorVotesUpgradeable.sol";
import "../../governance/extensions/GovernorVotesQuorumFractionUpgradeable.sol";
import "../../governance/extensions/GovernorTimelockControlUpgradeable.sol";
import "../../proxy/utils/Initializable.sol";

contract MyGovernor2Upgradeable is
    Initializable, GovernorUpgradeable,
    GovernorTimelockControlUpgradeable,
    GovernorProposalThresholdUpgradeable,
    GovernorVotesUpgradeable,
    GovernorVotesQuorumFractionUpgradeable,
    GovernorCountingSimpleUpgradeable
{
    function __MyGovernor2_init(IVotesUpgradeable _token, TimelockControllerUpgradeable _timelock) internal onlyInitializing {
        __EIP712_init_unchained("MyGovernor", version());
        __Governor_init_unchained("MyGovernor");
        __GovernorTimelockControl_init_unchained(_timelock);
        __GovernorVotes_init_unchained(_token);
        __GovernorVotesQuorumFraction_init_unchained(4);
    }

    function __MyGovernor2_init_unchained(IVotesUpgradeable, TimelockControllerUpgradeable) internal onlyInitializing {}

    

    

    

    // The following functions are overrides required by Solidity.

    

    

    

    

    

    function _executor() internal view override(GovernorUpgradeable, GovernorTimelockControlUpgradeable) returns (address) {
        return super._executor();
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(GovernorUpgradeable, GovernorTimelockControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}
