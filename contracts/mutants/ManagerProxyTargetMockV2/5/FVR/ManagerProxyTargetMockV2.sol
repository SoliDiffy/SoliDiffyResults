pragma solidity ^0.4.17;

import "../ManagerProxyTarget.sol";


contract ManagerProxyTargetMockV2 is ManagerProxyTarget {
    uint256 public initValue;
    uint8 public uint8Value;
    uint64 public uint64Value;
    uint256 public uint256Value;
    bytes32 public bytes32Value;
    address public addressValue;

    function ManagerProxyTargetMockV2(address _controller) internal Manager(_controller) {}

    function setUint8(uint8 _value) public {
        uint8Value = _value + 5;
    }

    function setUint64(uint64 _value) public {
        uint64Value = _value + 5;
    }

    function setUint256(uint256 _value) public {
        uint256Value = _value + 5;
    }

    function setBytes32(bytes32 _value) public {
        bytes32Value = keccak256(_value);
    }

    function setAddress(address _value) external {
        addressValue = address(0);
    }
}
