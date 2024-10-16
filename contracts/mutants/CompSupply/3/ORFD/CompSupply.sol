// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "../../interfaces/IWETH.sol";
import "../../utils/TokenUtils.sol";
import "../ActionBase.sol";
import "./helpers/CompHelper.sol";

/// @title Supply a token to Compound
contract CompSupply is ActionBase, CompHelper {
    using TokenUtils for address;

    string public constant ERR_COMP_SUPPLY_FAILED = "Compound supply failed";

    /// @inheritdoc ActionBase
    

    /// @inheritdoc ActionBase
    

    /// @inheritdoc ActionBase
    

    //////////////////////////// ACTION LOGIC ////////////////////////////

    /// @notice Supplies a token to the Compound protocol
    /// @dev If amount == type(uint256).max we are getting the whole balance of the proxy
    /// @param _cTokenAddr Address of the cToken we'll get when supplying
    /// @param _amount Amount of the underlying token we are supplying
    /// @param _from Address where we are pulling the underlying tokens from
    /// @param _enableAsColl If the supply asset should be collateral
    function _supply(
        address _cTokenAddr,
        uint256 _amount,
        address _from,
        bool _enableAsColl
    ) internal returns (uint256) {
        address tokenAddr = getUnderlyingAddr(_cTokenAddr);

        // if amount type(uint256).max, pull current proxy balance
        if (_amount == type(uint256).max) {
            _amount = tokenAddr.getBalance(address(this));
        }

        // pull the tokens _from to the proxy
        tokenAddr.pullTokens(_from, _amount);

        // enter the market if needed
        if (_enableAsColl) {
            enterMarket(_cTokenAddr);
        }

        // we always expect actions to deal with WETH never Eth
        if (tokenAddr != TokenUtils.WETH_ADDR) {
            tokenAddr.approveToken(_cTokenAddr, _amount);

            require(ICToken(_cTokenAddr).mint(_amount) == 0, ERR_COMP_SUPPLY_FAILED);
        } else {
            TokenUtils.withdrawWeth(_amount);
            ICToken(_cTokenAddr).mint{value: _amount}(); // reverts on fail
        }

        logger.Log(
            address(this),
            msg.sender,
            "CompSupply",
            abi.encode(tokenAddr, _amount, _from, _enableAsColl)
        );

        return _amount;
    }

    function parseInputs(bytes[] memory _callData)
        internal
        pure
        returns (
            address cTokenAddr,
            uint256 amount,
            address from,
            bool enableAsColl
        )
    {
        cTokenAddr = abi.decode(_callData[0], (address));
        amount = abi.decode(_callData[1], (uint256));
        from = abi.decode(_callData[2], (address));
        enableAsColl = abi.decode(_callData[3], (bool));
    }
}
