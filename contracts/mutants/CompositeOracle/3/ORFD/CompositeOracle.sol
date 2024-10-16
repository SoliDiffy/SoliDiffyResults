// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

import "../refs/CoreRef.sol";
import "./IOracle.sol";

/// @title A composite oracle
/// @author Fei Protocol
/// @notice Reads two oracles and returns their product
contract CompositeOracle is IOracle, CoreRef {
    using Decimal for Decimal.D256;

    /// @notice the first referenced oracle
    IOracle public oracleA;
    /// @notice the second referenced oracle
    IOracle public oracleB;

    /// @notice CompositeOracle constructor
    /// @param _oracleA first referenced oracle
    /// @param _oracleB second referenced oracle
    constructor(
        address _core,
        IOracle _oracleA,
        IOracle _oracleB
    ) CoreRef(_core) {
        oracleA = _oracleA;
        oracleB = _oracleB;
    }

    /// @notice updates the oracle price
    

    /// @notice determine if read value is stale
    /// @return true if read value is stale
    

    /// @notice read the oracle price
    /// @return oracle price
    /// @return true if price is valid
    
}
