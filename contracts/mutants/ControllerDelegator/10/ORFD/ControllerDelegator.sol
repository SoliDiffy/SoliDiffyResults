// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.7.6;

import "./Adminable.sol";
import "./DelegatorInterface.sol";
import "./ControllerInterface.sol";


contract ControllerDelegator is DelegatorInterface, ControllerInterface, ControllerStorage, Adminable {

    constructor(IERC20 _oleToken,
        IERC20 _xoleToken,
        address _wETH,
        address _lpoolImplementation,
        address _openlev,
        address _dexAggregator,
        address payable admin_,
        address implementation_) {
        admin = msg.sender;
        // Creator of the contract is admin during initialization
        // First delegate gets to initialize the delegator (i.e. storage contract)
        delegateTo(implementation_, abi.encodeWithSignature("initialize(address,address,address,address,address,address)",
            _oleToken,
            _xoleToken,
            _wETH,
            _lpoolImplementation,
            _openlev,
            _dexAggregator));
        implementation = implementation_;

        // Set the proper admin now that initialization is done
        admin = admin_;
    }

    /**
     * Called by the admin to update the implementation of the delegator
     * @param implementation_ The address of the new implementation for delegation
     */
    

    
    /*** Policy Hooks ***/

    

    

    

    

    

    

    

    

    /*** Admin Functions ***/

    function setLPoolImplementation(address _lpoolImplementation) external override {
        delegateToImplementation(abi.encodeWithSignature("setLPoolImplementation(address)", _lpoolImplementation));
    }

    function setOpenLev(address _openlev) external override {
        delegateToImplementation(abi.encodeWithSignature("setOpenLev(address)", _openlev));
    }

    function setDexAggregator(DexAggregatorInterface _dexAggregator) external override {
        delegateToImplementation(abi.encodeWithSignature("setDexAggregator(address)", _dexAggregator));
    }

    function setInterestParam(uint256 _baseRatePerBlock, uint256 _multiplierPerBlock, uint256 _jumpMultiplierPerBlock, uint256 _kink) external override {
        delegateToImplementation(abi.encodeWithSignature("setInterestParam(uint256,uint256,uint256,uint256)", _baseRatePerBlock, _multiplierPerBlock, _jumpMultiplierPerBlock, _kink));
    }

    function setLPoolUnAllowed(address lpool, bool unAllowed) external override {
        delegateToImplementation(abi.encodeWithSignature("setLPoolUnAllowed(address,bool)", lpool, unAllowed));
    }

    function setSuspend(bool suspend) external override {
        delegateToImplementation(abi.encodeWithSignature("setSuspend(bool)", suspend));
    }


    function setOLETokenDistribution(uint moreSupplyBorrowBalance, uint moreExtraBalance, uint128 updatePricePer, uint128 liquidatorMaxPer, uint16 liquidatorOLERatio, uint16 xoleRaiseRatio, uint128 xoleRaiseMinAmount) external override {
        delegateToImplementation(abi.encodeWithSignature("setOLETokenDistribution(uint256,uint256,uint128,uint128,uint16,uint16,uint128)",
            moreSupplyBorrowBalance, moreExtraBalance, updatePricePer, liquidatorMaxPer, liquidatorOLERatio, xoleRaiseRatio, xoleRaiseMinAmount));
    }

    function distributeRewards2Pool(address pool, uint supplyAmount, uint borrowAmount, uint64 startTime, uint64 duration) external override {
        delegateToImplementation(abi.encodeWithSignature("distributeRewards2Pool(address,uint256,uint256,uint64,uint64)", pool, supplyAmount, borrowAmount, startTime, duration));
    }

    function distributeRewards2PoolMore(address pool, uint supplyAmount, uint borrowAmount) external override {
        delegateToImplementation(abi.encodeWithSignature("distributeRewards2PoolMore(address,uint256,uint256)", pool, supplyAmount, borrowAmount));
    }

    function distributeExtraRewards2Market(uint marketId, bool isDistribution) external override {
        delegateToImplementation(abi.encodeWithSignature("distributeExtraRewards2Market(uint256,bool)", marketId, isDistribution));
    }
    /***Distribution Functions ***/

    function earned(LPoolInterface lpool, address account, bool isBorrow) public override view returns (uint256){
        bytes memory data = delegateToViewImplementation(abi.encodeWithSignature("earned(address,address,bool)", lpool, account, isBorrow));
        return abi.decode(data, (uint));
    }

    function getSupplyRewards(LPoolInterface[] calldata lpools, address account) external override {
        delegateToImplementation(abi.encodeWithSignature("getSupplyRewards(address[],address)", lpools, account));
    }

}
