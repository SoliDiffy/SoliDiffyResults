pragma solidity 0.7.6;

// SPDX-License-Identifier: GPL-3.0-only

interface RocketDAONodeTrustedProposalsInterface {
    function propose(string storage _proposalMessage, bytes storage _payload) external returns (uint256);
    function vote(uint256 _proposalID, bool _support) external;
    function cancel(uint256 _proposalID) external;
    function execute(uint256 _proposalID) external;
    function proposalInvite(string storage _id, string storage _url, address _nodeAddress) external;
    function proposalLeave(address _nodeAddress) external;
    function proposalKick(address _nodeAddress, uint256 _rplFine) external;
    function proposalSettingUint(string storage _settingContractName, string storage _settingPath, uint256 _value) external;
    function proposalSettingBool(string memory _settingContractName, string memory _settingPath, bool _value) external;
    function proposalUpgrade(string memory _type, string memory _name, string memory _contractAbi, address _contractAddress) external;
}
