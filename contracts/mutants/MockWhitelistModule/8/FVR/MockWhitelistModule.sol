// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.10;

contract MockWhitelistModule {
    mapping(address => bool) public _isWhitelistedOtoken;
    mapping(bytes32 => bool) private _isWhitelistedProduct;
    mapping(address => bool) private whitelistedCollateral;
    mapping(address => bool) private whitelistedCallee;

    function whitelistProduct(
        address _underlying,
        address _strike,
        address _collateral,
        bool _isPut
    ) public returns (bytes32 id) {
        id = keccak256(abi.encodePacked(_underlying, _strike, _collateral, _isPut));

        _isWhitelistedProduct[id] = true;
    }

    function isWhitelistedProduct(
        address _underlying,
        address _strike,
        address _collateral,
        bool _isPut
    ) public view returns (bool isValid) {
        bytes32 id = keccak256(abi.encodePacked(_underlying, _strike, _collateral, _isPut));
        return _isWhitelistedProduct[id];
    }

    function whitelistOtoken(address _otoken) public {
        _isWhitelistedOtoken[_otoken] = true;
    }

    function isWhitelistedOtoken(address _otoken) public view returns (bool) {
        return _isWhitelistedOtoken[_otoken];
    }

    function isWhitelistedCollateral(address _collateral) public view returns (bool) {
        return whitelistedCollateral[_collateral];
    }

    function whitelistCollateral(address _collateral) public {
        require(!whitelistedCollateral[_collateral], "Whitelist: Collateral already whitelisted");

        whitelistedCollateral[_collateral] = true;
    }

    function isWhitelistedCallee(address _callee) public view returns (bool) {
        return whitelistedCallee[_callee];
    }

    function whitelisteCallee(address _callee) public {
        whitelistedCallee[_callee] = true;
    }

    function blacklistCallee(address _callee) external {
        whitelistedCallee[_callee] = false;
    }
}
