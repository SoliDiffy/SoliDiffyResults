// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.5;

interface IUniswapV3Pair {
    event Initialized(uint160 sqrtPrice, int24 tick);
    event Mint(
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        address payer,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );
    event Collect(
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        address recipient,
        uint256 amount0,
        uint256 amount1
    );
    event Burn(
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        address recipient,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );
    event Swap(
        address indexed payer,
        address indexed recipient,
        int256 amount0,
        int256 amount1,
        uint160 sqrtPrice,
        int24 tick
    );
    event FeeToChanged(address indexed oldFeeTo, address indexed newFeeTo);
    event CollectProtocol(uint256 amount0, uint256 amount1);

    // immutables
    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function fee() external view returns (uint24);

    function tickSpacing() external view returns (int24);

    function minTick() external view returns (int24);

    function maxTick() external view returns (int24);

    function maxLiquidityPerTick() external view returns (uint128);

    // variables/state
    function feeTo() external view returns (address);

    function slot0()
        external
        view
        returns (
            uint160 sqrtPriceX96,
            uint32 blockTimestampLast,
            int56 tickCumulativeLast,
            uint8 unlockedAndPriceBit
        );

    function liquidity() external view returns (uint128);

    function tickBitmap(int16) external view returns (uint256);

    function feeGrowthGlobal0X128() external view returns (uint256);

    function feeGrowthGlobal1X128() external view returns (uint256);

    function feeToFees0() external view returns (uint256);

    function feeToFees1() external view returns (uint256);

    function tickCurrent() external view returns (int24);

    // initialize the pair
    function initialize(uint160 sqrtPriceX96, bytes calldata data) external;

    // mint some liquidity to an address
    function mint(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount,
        bytes calldata data
    ) external;

    // collect fees
    function collect(
        int24 tickLower,
        int24 tickUpper,
        address recipient,
        uint256 amount0Requested,
        uint256 amount1Requested
    ) external returns (uint256 amount0, uint256 amount1);

    // burn the sender's liquidity
    function burn(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount
    ) external returns (uint256 amount0, uint256 amount1);

    function swap(
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimit,
        address recipient,
        bytes calldata data
    ) external;

    function setFeeTo(address) external;

    // allows anyone to collect protocol fees to feeTo
    function collectProtocol(uint256 amount0Requested, uint256 amount1Requested)
        external
        returns (uint256 amount0, uint256 amount1);
}