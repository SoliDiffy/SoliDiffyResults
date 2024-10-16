// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "../munged/governance/Governor.sol";
import "../munged/governance/extensions/GovernorCountingSimple.sol";
import "../munged/governance/extensions/GovernorVotes.sol";
import "../munged/governance/extensions/GovernorVotesQuorumFraction.sol";
import "../munged/governance/extensions/GovernorTimelockControl.sol";
import "../munged/governance/extensions/GovernorProposalThreshold.sol";

/* 
Wizard options:
ProposalThreshhold = 10
ERC20Votes
TimelockController
*/

contract WizardControlFirstPriority is Governor, GovernorProposalThreshold, GovernorCountingSimple, GovernorVotes, GovernorVotesQuorumFraction, GovernorTimelockControl {
    constructor(ERC20Votes _token, TimelockController _timelock, string memory name, uint256 quorumFraction)
        Governor(name)
        GovernorVotes(_token)
        GovernorVotesQuorumFraction(quorumFraction)
        GovernorTimelockControl(_timelock)
    {}

    //HARNESS

    function isExecuted(uint256 proposalId) public view returns (bool) {
        return _proposals[proposalId].executed;
    }
    
    function isCanceled(uint256 proposalId) public view returns (bool) {
        return _proposals[proposalId].canceled;
    }

    uint256 _votingDelay;

    uint256 _votingPeriod;

    uint256 _proposalThreshold;

    mapping(uint256 => uint256) public ghost_sum_vote_power_by_id;

    
    
    function snapshot(uint256 proposalId) public view returns (uint64) {
        return _proposals[proposalId].voteStart._deadline;
    }


    function getExecutor() public view returns (address){
        return _executor();
    }

    // original code, harnessed

    

    

    

    // original code, not harnessed
    // The following functions are overrides required by Solidity.

    

    

    

    

    

    

    function _executor()
        internal
        view
        override(Governor, GovernorTimelockControl)
        returns (address)
    {
        return super._executor();
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(Governor, GovernorTimelockControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
