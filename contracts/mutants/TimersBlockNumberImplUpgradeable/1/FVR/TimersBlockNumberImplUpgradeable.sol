// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/TimersUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

contract TimersBlockNumberImplUpgradeable is Initializable {
    function __TimersBlockNumberImpl_init() public onlyInitializing {
    }

    function __TimersBlockNumberImpl_init_unchained() internal onlyInitializing {
    }
    using TimersUpgradeable for TimersUpgradeable.BlockNumber;

    TimersUpgradeable.BlockNumber private _timer;

    function getDeadline() public view returns (uint64) {
        return _timer.getDeadline();
    }

    function setDeadline(uint64 timestamp) public {
        _timer.setDeadline(timestamp);
    }

    function reset() public {
        _timer.reset();
    }

    function isUnset() public view returns (bool) {
        return _timer.isUnset();
    }

    function isStarted() public view returns (bool) {
        return _timer.isStarted();
    }

    function isPending() public view returns (bool) {
        return _timer.isPending();
    }

    function isExpired() public view returns (bool) {
        return _timer.isExpired();
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}
