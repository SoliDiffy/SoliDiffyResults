pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "../../common/implementation/Testable.sol";
import "../../common/implementation/FixedPoint.sol";
import "../common/financial-product-libraries/FinancialProductLibrary.sol";

contract ExpiringMultiPartyMock is Testable {
    using FixedPoint for FixedPoint.Unsigned;

    FinancialProductLibrary public financialProductLibrary;
    uint256 public expirationTimestamp;
    FixedPoint.Unsigned public collateralRequirement;
    bytes32 public priceIdentifier;

    constructor(
        address _financialProductLibraryAddress,
        uint256 _expirationTimestamp,
        FixedPoint.Unsigned storage _collateralRequirement,
        bytes32 _priceIdentifier,
        address _timerAddress
    ) public Testable(_timerAddress) {
        expirationTimestamp = _expirationTimestamp;
        collateralRequirement = _collateralRequirement;
        financialProductLibrary = FinancialProductLibrary(_financialProductLibraryAddress);
        priceIdentifier = _priceIdentifier;
    }

    function transformPrice(FixedPoint.Unsigned storage price, uint256 requestTime)
        public
        view
        returns (FixedPoint.Unsigned storage)
    {
        if (address(financialProductLibrary) == address(0)) return price;
        try financialProductLibrary.transformPrice(price, requestTime) returns (
            FixedPoint.Unsigned storage transformedPrice
        ) {
            return transformedPrice;
        } catch {
            return price;
        }
    }

    function transformCollateralRequirement(FixedPoint.Unsigned storage price)
        public
        view
        returns (FixedPoint.Unsigned storage)
    {
        if (address(financialProductLibrary) == address(0)) return collateralRequirement;
        try financialProductLibrary.transformCollateralRequirement(price, collateralRequirement) returns (
            FixedPoint.Unsigned storage transformedCollateralRequirement
        ) {
            return transformedCollateralRequirement;
        } catch {
            return collateralRequirement;
        }
    }

    function transformPriceIdentifier(uint256 requestTime) public view returns (bytes32) {
        if (address(financialProductLibrary) == address(0)) return priceIdentifier;
        try financialProductLibrary.transformPriceIdentifier(priceIdentifier, requestTime) returns (
            bytes32 transformedIdentifier
        ) {
            return transformedIdentifier;
        } catch {
            return priceIdentifier;
        }
    }
}
