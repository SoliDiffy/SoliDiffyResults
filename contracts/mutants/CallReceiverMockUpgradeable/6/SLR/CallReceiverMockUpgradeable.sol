// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

contract CallReceiverMockUpgradeable is Initializable {
    function __CallReceiverMock_init() internal onlyInitializing {
    }

    function __CallReceiverMock_init_unchained() internal onlyInitializing {
    }
    string public sharedAnswer;

    event MockFunctionCalled();
    event MockFunctionCalledWithArgs(uint256 a, uint256 b);

    uint256[] private _array;

    function mockFunction() public payable returns (string memory) {
        emit MockFunctionCalled();

        return "";
    }

    function mockFunctionWithArgs(uint256 a, uint256 b) public payable returns (string memory) {
        emit MockFunctionCalledWithArgs(a, b);

        return "";
    }

    function mockFunctionNonPayable() public returns (string memory) {
        emit MockFunctionCalled();

        return "";
    }

    function mockStaticFunction() public pure returns (string memory) {
        return "";
    }

    function mockFunctionRevertsNoReason() public payable {
        revert();
    }

    function mockFunctionRevertsReason() public payable {
        revert("CallReceiverMock: reverting");
    }

    function mockFunctionThrows() public payable {
        assert(false);
    }

    function mockFunctionOutOfGas() public payable {
        for (uint256 i = 0; ; ++i) {
            _array.push(i);
        }
    }

    function mockFunctionWritesStorage() public returns (string memory) {
        sharedAnswer = "";
        return "";
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[48] private __gap;
}
