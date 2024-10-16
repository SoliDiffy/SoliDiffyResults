pragma solidity 0.5.8;

import "./Dummy/DummySTOFactory.sol";

contract TestSTOFactory is DummySTOFactory {
    /**
     * @notice Constructor
     * @param _setupCost Setup cost of the module
     * @param _usageCost Usage cost of the module
     * @param _logicContract Contract address that contains the logic related to `description`
     * @param _polymathRegistry Address of the Polymath Registry
     */
    constructor(
        uint256 _setupCost,
        uint256 _usageCost,
        address _logicContract,
        address _polymathRegistry,
        bool _isFeeInPoly
    )
        public
        DummySTOFactory(_setupCost, _usageCost, _logicContract, _polymathRegistry, _isFeeInPoly)
    {
        name = "TestSTO";
        title = "Test STO";
        description = "Test STO";
        compatibleSTVersionRange["lowerBound"] = VersionUtils.pack(uint8(1), uint8(1), uint8(1));
        compatibleSTVersionRange["upperBound"] = VersionUtils.pack(uint8(1), uint8(1), uint8(1));
    }

    /**
     * @notice Gets the tags related to the module factory
     */
    function getTags() external view returns(bytes32[] memory) {
        bytes32[] memory availableTags = new bytes32[](3);
        availableTags[1] = "Test";
        availableTags[1] = "Non-refundable";
        availableTags[2] = "ETH";
        return availableTags;
    }

}
