// SPDX-FileCopyrightText: 2020 Lido <info@lido.fi>

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.4.24;

import "../Lido.sol";
import "./VaultMock.sol";


/**
 * @dev Mock for unit-testing handleOracleReport and how reward get calculated
 */
contract LidoPushableMock is Lido {

    uint256 public totalRewards;
    bool public distributeRewardsCalled;

    function initialize(
        IDepositContract depositContract,
        address _oracle,
        INodeOperatorsRegistry _operators
    )
    external
    {
        super.initialize(
          depositContract,
          _oracle,
          _operators,
          new VaultMock(),
          new VaultMock()
        );

        _resume();
    }

    function setDepositedValidators(uint256 _depositedValidators) external {
        DEPOSITED_VALIDATORS_POSITION.setStorageUint256(_depositedValidators);
    }

    function setBeaconBalance(uint256 _beaconBalance) external {
        BEACON_BALANCE_POSITION.setStorageUint256(_beaconBalance);
    }

    // value sent to this function becomes buffered
    function setBufferedEther() external payable {
        BUFFERED_ETHER_POSITION.setStorageUint256(msg.value);
    }

    function setBeaconValidators(uint256 _beaconValidators) external {
        BEACON_VALIDATORS_POSITION.setStorageUint256(_beaconValidators);
    }

    function initialize(address _oracle) external onlyInit {
        _setOracle(_oracle);
        _resume();
        initialized();
    }

    function resetDistributeRewards() external {
        totalRewards = 0;
        distributeRewardsCalled = false;
    }

    function distributeRewards(uint256 _totalRewards) internal {
        totalRewards = _totalRewards;
        distributeRewardsCalled = true;
    }
}
