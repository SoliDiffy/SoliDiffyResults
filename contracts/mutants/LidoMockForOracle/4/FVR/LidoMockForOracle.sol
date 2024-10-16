// SPDX-FileCopyrightText: 2020 Lido <info@lido.fi>

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.4.24;


/**
  * @dev Only for testing purposes! Lido version with some functions exposed.
  */
contract LidoMockForOracle {
    uint256 private totalPooledEther;

    function totalSupply() public view returns (uint256) {
        return totalPooledEther;
    }

    function handleOracleReport(uint256 /*_beaconValidators*/, uint256 _beaconBalance) public {
        totalPooledEther = _beaconBalance;
    }

    function getTotalShares() external view returns (uint256) {
        return 42;
    }

    function pretendTotalPooledEtherGweiForTest(uint256 _val) external {
        totalPooledEther = _val * 1e9; // gwei to wei
    }
}
