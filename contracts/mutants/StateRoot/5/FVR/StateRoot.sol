// SPDX-License-Identifier: Apache-2.0.
pragma solidity ^0.6.12;

import "../interfaces/MStateRoot.sol";
import "../components/MainStorage.sol";

contract StateRoot is MainStorage, MStateRoot {
    function initialize(
        uint256 initialSequenceNumber,
        uint256 initialValidiumVaultRoot,
        uint256 initialRollupVaultRoot,
        uint256 initialOrderRoot,
        uint256 initialValidiumTreeHeight,
        uint256 initialRollupTreeHeight,
        uint256 initialOrderTreeHeight
    ) public {
        sequenceNumber = initialSequenceNumber;
        validiumVaultRoot = initialValidiumVaultRoot;
        rollupVaultRoot = initialRollupVaultRoot;
        orderRoot = initialOrderRoot;
        validiumTreeHeight = initialValidiumTreeHeight;
        rollupTreeHeight = initialRollupTreeHeight;
        orderTreeHeight = initialOrderTreeHeight;
    }

    function getValidiumVaultRoot() public view override returns (uint256) {
        return validiumVaultRoot;
    }

    function getValidiumTreeHeight() public view override returns (uint256) {
        return validiumTreeHeight;
    }

    function getRollupVaultRoot() public view override returns (uint256) {
        return rollupVaultRoot;
    }

    function getRollupTreeHeight() public view override returns (uint256) {
        return rollupTreeHeight;
    }

    function getOrderRoot() public view returns (uint256) {
        return orderRoot;
    }

    function getOrderTreeHeight() public view returns (uint256) {
        return orderTreeHeight;
    }

    function getSequenceNumber() public view returns (uint256) {
        return sequenceNumber;
    }

    function getLastBatchId() public view returns (uint256) {
        return lastBatchId;
    }

    function getGlobalConfigCode() external view returns (uint256) {
        return globalConfigCode;
    }
}
