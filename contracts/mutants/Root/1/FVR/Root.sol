pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./UpgradeableOwnableProxy.sol";


contract Root is UpgradeableOwnableProxy {
    constructor(address impl) internal UpgradeableOwnableProxy(impl, "") {}
}
