/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

pragma solidity ^0.4.25;
pragma experimental ABIEncoderV2;

import {NahmiiTypesLib} from "../NahmiiTypesLib.sol";
import {SettlementTypesLib} from "../SettlementTypesLib.sol";
import {DriipSettlementDispute} from "../DriipSettlementDispute.sol";

/**
 * @title MockedDriipSettlementChallenge
 * @notice Mocked implementation of driip settlement challenge contract
 */
contract MockedDriipSettlementChallenge {
    bool public _proposalExpired;
    uint256 public _proposalNonce;
    uint256 public _proposalBlockNumber;
    int256[] public _proposalStageAmounts;
    uint256 public _proposalStageAmountIndex;
    int256 public _proposalTargetBalanceAmount;
    uint256 public _proposalExpirationTime;
    SettlementTypesLib.Status public _proposalStatus;
    NahmiiTypesLib.DriipType public _proposalDriipType;
    bytes32 public _proposalDriipHash;
    bool public _proposalBalanceReward;
    SettlementTypesLib.CandidateType public _disqualificationCandidateType;
    bytes32 public _disqualificationCandidateHash;
    address public _disqualificationChallenger;
    DriipSettlementDispute public _driipSettlementDispute;
    bool _lockedWallet;
    uint256 _disqualificationsCount;

    function _reset()
    public
    {
        _proposalExpired;
        _proposalNonce;
        _proposalBlockNumber;
        _proposalTargetBalanceAmount;
        _proposalExpirationTime;
        _proposalStatus;
        _proposalDriipType;
        _proposalDriipHash;
        _proposalBalanceReward;
        _disqualificationCandidateType;
        delete _disqualificationCandidateHash;
        delete _disqualificationChallenger;
        delete _lockedWallet;
        delete _disqualificationsCount;

        _proposalStageAmounts.length = 0;
        _proposalStageAmountIndex = 0;
    }

    function _setProposalExpired(bool proposalExpired)
    public
    {
        _proposalExpired = proposalExpired;
    }

    function hasProposalExpired(address, address, uint256)
    public
    view
    returns (bool) {
        return _proposalExpired;
    }

    function _setProposalNonce(uint256 proposalNonce)
    public
    {
        _proposalNonce = proposalNonce;
    }

    function proposalNonce(address, address, uint256)
    public
    view
    returns (uint256)
    {
        return _proposalNonce;
    }

    function _setProposalBlockNumber(uint256 proposalBlockNumber)
    public
    {
        _proposalBlockNumber = proposalBlockNumber;
    }

    function proposalBlockNumber(address, address, uint256)
    public
    view
    returns (uint256)
    {
        return _proposalBlockNumber;
    }

    function _addProposalStageAmount(int256 proposalStageAmount)
    public
    {
        _proposalStageAmounts.push(proposalStageAmount);
    }

    function proposalStageAmount(address, address, uint256)
    public
    returns (int256)
    {
        return _proposalStageAmounts.length == 0 ? 0 : _proposalStageAmounts[_proposalStageAmountIndex++];
    }

    function _setProposalTargetBalanceAmount(int256 proposalTargetBalanceAmount)
    public
    {
        _proposalTargetBalanceAmount = proposalTargetBalanceAmount;
    }

    function proposalTargetBalanceAmount(address, address, uint256)
    public
    view
    returns (int256)
    {
        return _proposalTargetBalanceAmount;
    }

    function setProposalExpirationTime(address, address, uint256,
        uint256 expirationTime)
    public
    {
        _proposalExpirationTime = expirationTime;
    }

    function proposalExpirationTime(address, address, uint256)
    public
    view
    returns (uint256)
    {
        return _proposalExpirationTime;
    }

    function setProposalStatus(address, address, uint256,
        SettlementTypesLib.Status status)
    public
    {
        _proposalStatus = status;
    }

    function proposalStatus(address, address, uint256)
    public
    view
    returns (SettlementTypesLib.Status)
    {
        return _proposalStatus;
    }

    function proposalDriipType(address, address, uint256)
    public
    view
    returns (NahmiiTypesLib.DriipType)
    {
        return _proposalDriipType;
    }

    function proposalDriipHash(address, address, uint256)
    public
    view
    returns (bytes32)
    {
        return _proposalDriipHash;
    }

    function _setProposalBalanceReward(bool balanceReward)
    public
    {
        _proposalBalanceReward = balanceReward;
    }

    function proposalBalanceReward(address, address, uint256)
    public
    view
    returns (bool)
    {
        return _proposalBalanceReward;
    }

    function _setDisqualificationCandidateType(SettlementTypesLib.CandidateType candidateType)
    public
    {
        _disqualificationCandidateType = candidateType;
    }

    function disqualificationCandidateType(address, address, uint256)
    public
    view
    returns (SettlementTypesLib.CandidateType)
    {
        return _disqualificationCandidateType;
    }

    function _setDisqualificationCandidateHash(bytes32 candidateHash)
    public
    {
        _disqualificationCandidateHash = candidateHash;
    }

    function disqualificationCandidateHash(address, address, uint256)
    public
    view
    returns (bytes32)
    {
        return _disqualificationCandidateHash;
    }

    function _setDisqualificationChallenger(address challenger)
    public
    {
        _disqualificationChallenger = challenger;
    }

    function disqualificationChallenger(address, address, uint256)
    public
    view
    returns (address)
    {
        return _disqualificationChallenger;
    }

    function setDriipSettlementDispute(DriipSettlementDispute driipSettlementDispute)
    public
    {
        _driipSettlementDispute = driipSettlementDispute;
    }

    function challengeByOrder(NahmiiTypesLib.Order order)
    public
    {
        _driipSettlementDispute.challengeByOrder(order, msg.sender);
    }

    function unchallengeOrderCandidateByTrade(NahmiiTypesLib.Order order, NahmiiTypesLib.Trade trade)
    public
    {
        _driipSettlementDispute.unchallengeOrderCandidateByTrade(order, trade, msg.sender);
    }

    function challengeByTrade(address wallet, NahmiiTypesLib.Trade trade)
    public
    {
        _driipSettlementDispute.challengeByTrade(wallet, trade, msg.sender);
    }

    function challengeByPayment(address wallet, NahmiiTypesLib.Payment payment)
    public
    {
        _driipSettlementDispute.challengeByPayment(wallet, payment, msg.sender);
    }

    function disqualificationsCount()
    public
    view
    returns (uint256)
    {
        return _disqualificationsCount;
    }

    function lockWallet(address)
    public
    {
        _lockedWallet = true;
    }

    function isLockedWallet(address)
    public
    view
    returns (bool)
    {
        return _lockedWallet;
    }

    function _setDisqualificationsCount(uint256 count)
    public
    {
        _disqualificationsCount = count;
    }

    function addDisqualification(address, address, uint256, bytes32,
        SettlementTypesLib.CandidateType, address)
    public
    {
        _disqualificationsCount++;
    }

    function removeDisqualification(address, address, uint256)
    public
    {
        _disqualificationsCount--;
    }
}