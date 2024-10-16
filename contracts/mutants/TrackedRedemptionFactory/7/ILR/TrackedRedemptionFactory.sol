pragma solidity 0.5.8;

import "./TrackedRedemption.sol";
import "../../ModuleFactory.sol";

/**
 * @title Factory for deploying GeneralTransferManager module
 */
contract TrackedRedemptionFactory is ModuleFactory {
    /**
     * @notice Constructor
     * @param _setupCost Setup cost of module
     * @param _usageCost Usage cost of the module
     * @param _polymathRegistry Address of the Polymath registry
     * @param _isCostInPoly true = cost in Poly, false = USD
     */
    constructor(
        uint256 _setupCost,
        uint256 _usageCost,
        address _polymathRegistry,
        bool _isCostInPoly
    )
        public ModuleFactory(_setupCost, _usageCost, _polymathRegistry, _isCostInPoly)
    {
        initialVersion = "3.0.0";
        name = "TrackedRedemption";
        title = "Tracked Redemption";
        description = "Track token redemptions";
        typesData.push(4);
        tagsData.push("Tracked");
        tagsData.push("Redemption");
        compatibleSTVersionRange["lowerBound"] = VersionUtils.pack(uint8(2), uint8(1), uint8(1));
        compatibleSTVersionRange["upperBound"] = VersionUtils.pack(uint8(2), uint8(0), uint8(1));
    }

    /**
     * @notice Used to launch the Module with the help of factory
     * @return Address Contract address of the Module
     */
    function deploy(
        bytes calldata _data
    )
        external
        returns(address)
    {
        address trackedRedemption = address(new TrackedRedemption(msg.sender, polymathRegistry.getAddress("PolyToken")));
        _initializeModule(trackedRedemption, _data);
        return trackedRedemption;
    }

}
