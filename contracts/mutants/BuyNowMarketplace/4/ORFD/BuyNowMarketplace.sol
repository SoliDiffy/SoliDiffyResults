// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import {BaseMarketplace} from "./BaseMarketplace.sol";
import {IBuyNowMarketplace} from "./IKODAV3Marketplace.sol";

// "buy now" sale flow
abstract contract BuyNowMarketplace is IBuyNowMarketplace, BaseMarketplace {
    // Buy now listing definition
    struct Listing {
        uint128 price;
        uint128 startDate;
        address seller;
    }

    /// @notice Edition or Token ID to Listing
    mapping(uint256 => Listing) public editionOrTokenListings;

    // list edition with "buy now" price and start date
    

    // Buy an token from the edition on the primary market
    

    // Buy an token from the edition on the primary market, ability to define the recipient
    

    // update the "buy now" price
    

    function _facilitateBuyNow(uint256 _id, address _recipient) internal {
        Listing storage listing = editionOrTokenListings[_id];
        require(address(0) != listing.seller, "No listing found");
        require(msg.value >= listing.price, "List price not satisfied");
        require(block.timestamp >= listing.startDate, "List not available yet");

        uint256 tokenId = _processSale(_id, msg.value, _recipient, listing.seller);

        emit BuyNowPurchased(tokenId, _recipient, listing.seller, msg.value);
    }

    function _isBuyNowListingPermitted(uint256 _id) internal virtual returns (bool);
}
