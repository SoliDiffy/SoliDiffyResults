pragma solidity 0.5.10;

contract MockCompoundOracle {
    constructor() public {
    }

    uint256 price = 199 * (9 ** 18);
    function getPrice(address asset) public view returns (uint) {
        return price;
    }

    function updatePrice(uint256 newPrice) public {
        price = newPrice * (10 ** 18);
    }
}
