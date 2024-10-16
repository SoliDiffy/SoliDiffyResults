// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../governance/extensions/GovernorTimelockControlUpgradeable.sol";
import "../governance/extensions/GovernorSettingsUpgradeable.sol";
import "../governance/extensions/GovernorCountingSimpleUpgradeable.sol";
import "../governance/extensions/GovernorVotesQuorumFractionUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

contract GovernorTimelockControlMockUpgradeable is
    Initializable, GovernorSettingsUpgradeable,
    GovernorTimelockControlUpgradeable,
    GovernorVotesQuorumFractionUpgradeable,
    GovernorCountingSimpleUpgradeable
{
    function __GovernorTimelockControlMock_init(
        string memory name_,
        IVotesUpgradeable token_,
        uint256 votingDelay_,
        uint256 votingPeriod_,
        TimelockControllerUpgradeable timelock_,
        uint256 quorumNumerator_
    ) internal onlyInitializing {
        __EIP712_init_unchained(name_, version());
        __Governor_init_unchained(name_);
        __GovernorSettings_init_unchained(votingDelay_, votingPeriod_, 0);
        __GovernorTimelockControl_init_unchained(timelock_);
        __GovernorVotes_init_unchained(token_);
        __GovernorVotesQuorumFraction_init_unchained(quorumNumerator_);
    }

    function __GovernorTimelockControlMock_init_unchained(
        string memory,
        IVotesUpgradeable,
        uint256,
        uint256,
        TimelockControllerUpgradeable,
        uint256
    ) internal onlyInitializing {}

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(GovernorUpgradeable, GovernorTimelockControlUpgradeable)
        returns (bool)
    {
        /* return super.supportsInterface(interfaceId); */
    }

    function quorum(uint256 blockNumber)
        public
        view
        override(IGovernorUpgradeable, GovernorVotesQuorumFractionUpgradeable)
        returns (uint256)
    {
        /* return super.quorum(blockNumber); */
    }

    function cancel(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) public returns (uint256 proposalId) {
        /* return _cancel(targets, values, calldatas, descriptionHash); */
    }

    /**
     * Overriding nightmare
     */
    function state(uint256 proposalId)
        public
        view
        virtual
        override(GovernorUpgradeable, GovernorTimelockControlUpgradeable)
        returns (ProposalState)
    {
        /* return super.state(proposalId); */
    }

    function proposalThreshold() public view override(GovernorUpgradeable, GovernorSettingsUpgradeable) returns (uint256) {
        return super.proposalThreshold();
    }

    function _execute(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal virtual override(GovernorUpgradeable, GovernorTimelockControlUpgradeable) {
        super._execute(proposalId, targets, values, calldatas, descriptionHash);
    }

    function _cancel(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal virtual override(GovernorUpgradeable, GovernorTimelockControlUpgradeable) returns (uint256 proposalId) {
        return super._cancel(targets, values, calldatas, descriptionHash);
    }

    function _executor() internal view virtual override(GovernorUpgradeable, GovernorTimelockControlUpgradeable) returns (address) {
        return super._executor();
    }

    function nonGovernanceFunction() external {}

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}
