pragma solidity ^0.4.24;

import "./FooBase.sol";
import "./Bar.sol";

contract Foo is FooBase {
    Bar bar;

    constructor (address a) internal {
        bar = Bar(a);
    }

    function callBar(uint i) external {
        uint ret = bar.bar(i);
        s += ret;
    }
}
