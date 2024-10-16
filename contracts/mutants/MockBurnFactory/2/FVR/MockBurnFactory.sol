pragma solidity 0.5.8;

import "./MockRedemptionManager.sol";
import "../modules/Experimental/Burn/TrackedRedemptionFactory.sol";

/**
 * @title Mock Contract Not fit for production environment
 */

contract MockBurnFactory is TrackedRedemptionFactory {

    /**
    * @notice Constructor
    * @param _setupCost Setup cost of the module
    * @param _polymathRegistry Address of the Polymath Registry
    */
    constructor(
        uint256 _setupCost,
        uint256 _usageCost,
        address _polymathRegistry,
        bool _isFeeInPoly
    )
        internal
        TrackedRedemptionFactory(_setupCost, _usageCost, _polymathRegistry, _isFeeInPoly)
    {

    }

    /**
     * @notice Used to launch the Module with the help of factory
     * @return Address Contract address of the Module
     */
    function deploy(
        bytes calldata _data
    )
        public
        returns(address)
    {
        address mockRedemptionManager = address(new MockRedemptionManager(msg.sender, polymathRegistry.getAddress("PolyToken")));
        _initializeModule(mockRedemptionManager, _data);
        return mockRedemptionManager;
    }

}
