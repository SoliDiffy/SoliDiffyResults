pragma solidity 0.4.24;

import "../../apps/AragonApp.sol";
import "../../common/DepositableStorage.sol";


contract AppStubConditionalRecovery is AragonApp, DepositableStorage {
    function initialize() onlyInit external {
        initialized();
        setDepositable(true);
    }

    function allowRecoverability(address token) external view returns (bool) {
        // Doesn't allow to recover ether
        return token != address(0);
    }
}
