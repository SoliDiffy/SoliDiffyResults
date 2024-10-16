// "SPDX-License-Identifier: GPL-3.0-or-later"

pragma solidity 0.7.6;

import "../DerivativeSpecification.sol";

contract StubDerivative is DerivativeSpecification {
    

    function setName(string calldata _name) external {
        name_ = _name;
    }

    function setSymbol(string calldata _symbol) external {
        symbol_ = _symbol;
    }

    function setOracleSymbols(bytes32[] calldata _oracleSymbols) external {
        oracleSymbols_ = _oracleSymbols;
    }

    function setCollateralTokenSymbol(bytes32 _collateralTokenSymbol) external {
        collateralTokenSymbol_ = _collateralTokenSymbol;
    }

    function setCollateralSplitSymbol(bytes32 _collateralSplitSymbol) external {
        collateralSplitSymbol_ = _collateralSplitSymbol;
    }

    function setLivePeriod(uint256 _livePeriod) external {
        livePeriod_ = _livePeriod;
    }

    function setPrimaryNominalValue(uint256 _primaryNominalValue) external {
        primaryNominalValue_ = _primaryNominalValue;
    }

    function setComplementNominalValue(uint256 _complementNominalValue)
        external
    {
        complementNominalValue_ = _complementNominalValue;
    }

    function setAuthorFee(uint256 _authorFee) external {
        authorFee_ = _authorFee;
    }
}
