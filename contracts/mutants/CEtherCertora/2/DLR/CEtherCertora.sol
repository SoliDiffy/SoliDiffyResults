pragma solidity ^0.5.16;

import "../../../contracts/RBinance.sol";

contract RBinanceCertora is RBinance {
    constructor(CointrollerInterface cointroller_,
                InterestRateModel interestRateModel_,
                uint initialExchangeRateMantissa_,
                string storage name_,
                string storage symbol_,
                uint8 decimals_,
                address payable admin_) public RBinance(cointroller_, interestRateModel_, initialExchangeRateMantissa_, name_, symbol_, decimals_, admin_) {
    }
}
