/**
 *Submitted for verification at Etherscan.io on 2020-09-01
 */

pragma solidity ^0.5.17;

interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address owner, address spender) external view returns (uint256);

  function decimals() external view returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, 'SafeMath: addition overflow');

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, 'SafeMath: subtraction overflow');
  }

  function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, 'SafeMath: multiplication overflow');

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, 'SafeMath: division by zero');
  }

  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, 'SafeMath: modulo by zero');
  }

  function mod(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

library Address {
  function isContract(address account) internal view returns (bool) {
    bytes32 codehash;
    bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
    // solhint-disable-next-line no-inline-assembly
    assembly {
      codehash := extcodehash(account)
    }
    return (codehash != 0x0 && codehash != accountHash);
  }

  function toPayable(address account) internal pure returns (address payable) {
    return address(uint160(account));
  }

  function sendValue(address payable recipient, uint256 amount) internal {
    require(address(this).balance >= amount, 'Address: insufficient balance');

    // solhint-disable-next-line avoid-call-value
    (bool success, ) = recipient.call.value(amount)('');
    require(success, 'Address: unable to send value, recipient may have reverted');
  }
}

library SafeERC20 {
  using SafeMath for uint256;
  using Address for address;

  function safeTransfer(
    IERC20 token,
    address to,
    uint256 value
  ) internal {
    callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
  }

  function safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint256 value
  ) internal {
    callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
  }

  function safeApprove(
    IERC20 token,
    address spender,
    uint256 value
  ) internal {
    require((value == 0) || (token.allowance(address(this), spender) == 0), 'SafeERC20: approve from non-zero to non-zero allowance');
    callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
  }

  function callOptionalReturn(IERC20 token, bytes memory data) private {
    require(address(token).isContract(), 'SafeERC20: call to non-contract');

    // solhint-disable-next-line avoid-low-level-calls
    (bool success, bytes memory returndata) = address(token).call(data);
    require(success, 'SafeERC20: low-level call failed');

    if (returndata.length > 0) {
      // Return data is optional
      // solhint-disable-next-line max-line-length
      require(abi.decode(returndata, (bool)), 'SafeERC20: ERC20 operation did not succeed');
    }
  }
}

interface yVault {
  function getPricePerFullShare() external view returns (uint256);

  function balanceOf(address) external view returns (uint256);

  function depositAll() external;

  function withdraw(uint256 _shares) external;

  function withdrawAll() external;
}

interface Controller {
  function vaults(address) external view returns (address);

  function strategies(address) external view returns (address);

  function rewards() external view returns (address);
}

interface Strategy {
  function withdrawalFee() external view returns (uint256);
}

/* MakerDao interfaces */

interface GemLike {
  function approve(address, uint256) external;

  function transfer(address, uint256) external;

  function transferFrom(
    address,
    address,
    uint256
  ) external;

  function deposit() external ;

  function withdraw(uint256) external;
}

interface ManagerLike {
  function cdpCan(
    address,
    uint256,
    address
  ) external view returns (uint256);

  function ilks(uint256) external view returns (bytes32);

  function owns(uint256) external view returns (address);

  function urns(uint256) external view returns (address);

  function vat() external view returns (address);

  function open(bytes32, address) external returns (uint256);

  function give(uint256, address) external;

  function cdpAllow(
    uint256,
    address,
    uint256
  ) external;

  function urnAllow(address, uint256) external;

  function frob(
    uint256,
    int256,
    int256
  ) external;

  function flux(
    uint256,
    address,
    uint256
  ) external;

  function move(
    uint256,
    address,
    uint256
  ) external;

  function exit(
    address,
    uint256,
    address,
    uint256
  ) external;

  function quit(uint256, address) external;

  function enter(address, uint256) external;

  function shift(uint256, uint256) external;
}

interface VatLike {
  function can(address, address) external view returns (uint256);

  function ilks(bytes32)
    external
    view
    returns (
      uint256,
      uint256,
      uint256,
      uint256,
      uint256
    );

  function dai(address) external view returns (uint256);

  function urns(bytes32, address) external view returns (uint256, uint256);

  function frob(
    bytes32,
    address,
    address,
    address,
    int256,
    int256
  ) external;

  function hope(address) external;

  function move(
    address,
    address,
    uint256
  ) external;
}

interface GemJoinLike {
  function dec() external returns (uint256);

  function gem() external returns (GemLike);

  function join(address, uint256) external ;

  function exit(address, uint256) external;
}

interface GNTJoinLike {
  function bags(address) external view returns (address);

  function make(address) external returns (address);
}

interface DaiJoinLike {
  function vat() external returns (VatLike);

  function dai() external returns (GemLike);

  function join(address, uint256) external payable;

  function exit(address, uint256) external;
}

interface HopeLike {
  function hope(address) external;

  function nope(address) external;
}

interface EndLike {
  function fix(bytes32) external view returns (uint256);

  function cash(bytes32, uint256) external;

  function free(bytes32) external;

  function pack(uint256) external;

  function skim(bytes32, address) external;
}

interface JugLike {
  function drip(bytes32) external returns (uint256);
}

interface PotLike {
  function pie(address) external view returns (uint256);

  function drip() external returns (uint256);

  function join(uint256) external;

  function exit(uint256) external;
}

interface SpotLike {
  function ilks(bytes32) external view returns (address, uint256);
}

interface OSMedianizer {
  function read() external view returns (uint256, bool);

  function foresight() external view returns (uint256, bool);
}

interface Uni {
  function swapExactTokensForTokens(
    uint256,
    uint256,
    address[] calldata,
    address,
    uint256
  ) external;
}

/*

 A strategy must implement the following calls;

 - deposit()
 - withdraw(address) must exclude any tokens used in the yield - Controller role - withdraw should return to Controller
 - withdraw(uint) - Controller | Vault role - withdraw should always return to vault
 - withdrawAll() - Controller | Vault role - withdraw should always return to vault
 - balanceOf()

 Where possible, strategies must remain as immutable as possible, instead of updating variables, we update the contract by linking it in the controller

*/

contract StrategyMKRVaultDAIDelegate {
  using SafeERC20 for IERC20;
  using Address for address;
  using SafeMath for uint256;

  address public constant token = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
  address public constant want = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
  address public constant weth = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
  address public constant dai = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);

  address public cdp_manager = address(0x5ef30b9986345249bc32d8928B7ee64DE9435E39);
  address public vat = address(0x35D1b3F3D7966A1DFe207aa4514C12a259A0492B);
  address public mcd_join_eth_a = address(0x2F0b23f53734252Bda2277357e97e1517d6B042A);
  address public mcd_join_dai = address(0x9759A6Ac90977b93B58547b4A71c78317f391A28);
  address public mcd_spot = address(0x65C79fcB50Ca1594B025960e539eD7A9a6D434A3);
  address public jug = address(0x19c0976f590D67707E62397C87829d896Dc0f1F1);

  address public eth_price_oracle = address(0xCF63089A8aD2a9D8BD6Bb8022f3190EB7e1eD0f1);
  address public constant yVaultDAI = address(0xACd43E627e64355f1861cEC6d3a6688B31a6F952);

  address public constant unirouter = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

  uint256 public c = 20000;
  uint256 public c_safe = 30000;
  uint256 public constant c_base = 10000;

  uint256 public performanceFee = 500;
  uint256 public constant performanceMax = 10000;

  uint256 public withdrawalFee = 50;
  uint256 public constant withdrawalMax = 10000;

  uint256 public strategistReward = 5000;
  uint256 public constant strategistRewardMax = 10000;

  bytes32 public constant ilk = 'ETH-A';

  address public governance;
  address public controller;
  address public strategist;
  address public harvester;

  uint256 public cdpId;

  constructor(address _controller) public {
    governance = msg.sender;
    strategist = msg.sender;
    harvester = msg.sender;
    controller = _controller;
    cdpId = ManagerLike(cdp_manager).open(ilk, address(this));
    _approveAll();
  }

  function getName() external pure returns (string memory) {
    return 'StrategyMKRVaultDAIDelegate';
  }

  function setStrategist(address _strategist) external {
    require(msg.sender == governance, '!governance');
    strategist = _strategist;
  }

  function setHarvester(address _harvester) external {
    require(msg.sender == harvester || msg.sender == governance, '!allowed');
    harvester = _harvester;
  }

  function setWithdrawalFee(uint256 _withdrawalFee) external {
    require(msg.sender == governance, '!governance');
    withdrawalFee = _withdrawalFee;
  }

  function setPerformanceFee(uint256 _performanceFee) external {
    require(msg.sender == governance, '!governance');
    performanceFee = _performanceFee;
  }

  function setStrategistReward(uint256 _strategistReward) external {
    require(msg.sender == governance, '!governance');
    strategistReward = _strategistReward;
  }

  function setBorrowCollateralizationRatio(uint256 _c) external {
    require(msg.sender == governance, '!governance');
    c = _c;
  }

  function setWithdrawCollateralizationRatio(uint256 _c_safe) external {
    require(msg.sender == governance, '!governance');
    c_safe = _c_safe;
  }

  function setOracle(address _oracle) external {
    require(msg.sender == governance, '!governance');
    eth_price_oracle = _oracle;
  }

  // optional
  function setMCDValue(
    address _manager,
    address _ethAdapter,
    address _daiAdapter,
    address _spot,
    address _jug
  ) external {
    require(msg.sender == governance, '!governance');
    cdp_manager = _manager;
    vat = ManagerLike(_manager).vat();
    mcd_join_eth_a = _ethAdapter;
    mcd_join_dai = _daiAdapter;
    mcd_spot = _spot;
    jug = _jug;
  }

  function _approveAll() internal {
    IERC20(token).approve(mcd_join_eth_a, uint256(-1));
    IERC20(dai).approve(mcd_join_dai, uint256(-1));
    IERC20(dai).approve(yVaultDAI, uint256(-1));
    IERC20(dai).approve(unirouter, uint256(-1));
  }

  function deposit() public {
    uint256 _token = IERC20(token).balanceOf(address(this));
    if (_token > 0) {
      uint256 p = _getPrice();
      uint256 _draw = _token.mul(p).mul(c_base).div(c).div(1e18);
      // approve adapter to use token amount
      require(_checkDebtCeiling(_draw), 'debt ceiling is reached!');
      _lockWETHAndDrawDAI(_token, _draw);
    }
    // approve yVaultDAI use DAI
    yVault(yVaultDAI).depositAll();
  }

  function _getPrice() internal view returns (uint256 p) {
    (uint256 _read, ) = OSMedianizer(eth_price_oracle).read();
    (uint256 _foresight, ) = OSMedianizer(eth_price_oracle).foresight();
    p = _foresight < _read ? _foresight : _read;
  }

  function _checkDebtCeiling(uint256 _amt) internal view returns (bool) {
    (, , , uint256 _line, ) = VatLike(vat).ilks(ilk);
    uint256 _debt = getTotalDebtAmount().add(_amt);
    if (_line.div(1e27) < _debt) {
      return false;
    }
    return true;
  }

  function _lockWETHAndDrawDAI(uint256 wad, uint256 wadD) internal {
    address urn = ManagerLike(cdp_manager).urns(cdpId);

    // GemJoinLike(mcd_join_eth_a).gem().approve(mcd_join_eth_a, wad);
    GemJoinLike(mcd_join_eth_a).join(urn, wad);
    ManagerLike(cdp_manager).frob(cdpId, toInt(wad), _getDrawDart(urn, wadD));
    ManagerLike(cdp_manager).move(cdpId, address(this), wadD.mul(1e27));
    if (VatLike(vat).can(address(this), address(mcd_join_dai)) == 0) {
      VatLike(vat).hope(mcd_join_dai);
    }
    DaiJoinLike(mcd_join_dai).exit(address(this), wadD);
  }

  function _getDrawDart(address urn, uint256 wad) internal returns (int256 dart) {
    uint256 rate = JugLike(jug).drip(ilk);
    uint256 _dai = VatLike(vat).dai(urn);

    // If there was already enough DAI in the vat balance, just exits it without adding more debt
    if (_dai < wad.mul(1e27)) {
      dart = toInt(wad.mul(1e27).sub(_dai).div(rate));
      dart = uint256(dart).mul(rate) < wad.mul(1e27) ? dart + 1 : dart;
    }
  }

  function toInt(uint256 x) internal pure returns (int256 y) {
    y = int256(x);
    require(y >= 0, 'int-overflow');
  }

  // Controller only function for creating additional rewards from dust
  function withdraw(IERC20 _asset) external returns (uint256 balance) {
    require(msg.sender == controller, '!controller');
    require(want != address(_asset), 'want');
    require(dai != address(_asset), 'dai');
    require(yVaultDAI != address(_asset), 'ydai');
    balance = _asset.balanceOf(address(this));
    _asset.safeTransfer(controller, balance);
  }

  // Withdraw partial funds, normally used with a vault withdrawal
  function withdraw(uint256 _amount) external {
    require(msg.sender == controller, '!controller');
    uint256 _balance = IERC20(want).balanceOf(address(this));
    if (_balance < _amount) {
      _amount = _withdrawSome(_amount.sub(_balance));
      _amount = _amount.add(_balance);
    }

    uint256 _fee = _amount.mul(withdrawalFee).div(withdrawalMax);

    IERC20(want).safeTransfer(Controller(controller).rewards(), _fee);
    address _vault = Controller(controller).vaults(address(want));
    require(_vault != address(0), '!vault'); // additional protection so we don't burn the funds

    IERC20(want).safeTransfer(_vault, _amount.sub(_fee));
  }

  function _withdrawSome(uint256 _amount) internal returns (uint256) {
    if (getTotalDebtAmount() != 0 && getmVaultRatio(_amount) < c_safe.mul(1e2)) {
      uint256 p = _getPrice();
      _wipe(_withdrawDaiLeast(_amount.mul(p).div(1e18)));
    }

    _freeWETH(_amount);

    return _amount;
  }

  function _freeWETH(uint256 wad) internal {
    ManagerLike(cdp_manager).frob(cdpId, -toInt(wad), 0);
    ManagerLike(cdp_manager).flux(cdpId, address(this), wad);
    GemJoinLike(mcd_join_eth_a).exit(address(this), wad);
  }

  function _wipe(uint256 wad) internal {
    // wad in DAI
    address urn = ManagerLike(cdp_manager).urns(cdpId);

    DaiJoinLike(mcd_join_dai).join(urn, wad);
    ManagerLike(cdp_manager).frob(cdpId, 0, _getWipeDart(VatLike(vat).dai(urn), urn));
  }

  function _getWipeDart(uint256 _dai, address urn) internal view returns (int256 dart) {
    (, uint256 rate, , , ) = VatLike(vat).ilks(ilk);
    (, uint256 art) = VatLike(vat).urns(ilk, urn);

    dart = toInt(_dai / rate);
    dart = uint256(dart) <= art ? -dart : -toInt(art);
  }

  // Withdraw all funds, normally used when migrating strategies
  function withdrawAll() external returns (uint256 balance) {
    require(msg.sender == controller, '!controller');
    _withdrawAll();

    _swap(IERC20(dai).balanceOf(address(this)));
    balance = IERC20(want).balanceOf(address(this));

    address _vault = Controller(controller).vaults(address(want));
    require(_vault != address(0), '!vault'); // additional protection so we don't burn the funds
    IERC20(want).safeTransfer(_vault, balance);
  }

  function _withdrawAll() internal {
    yVault(yVaultDAI).withdrawAll(); // get Dai
    _wipe(getTotalDebtAmount().add(1)); // in case of edge case
    _freeWETH(balanceOfmVault());
  }

  function balanceOf() public view returns (uint256) {
    return balanceOfWant().add(balanceOfmVault());
  }

  function balanceOfWant() public view returns (uint256) {
    return IERC20(want).balanceOf(address(this));
  }

  function balanceOfmVault() public view returns (uint256) {
    uint256 ink;
    address urnHandler = ManagerLike(cdp_manager).urns(cdpId);
    (ink, ) = VatLike(vat).urns(ilk, urnHandler);
    return ink;
  }

  function harvest() public {
    require(msg.sender == strategist || msg.sender == harvester || msg.sender == governance, '!authorized');

    uint256 v = getUnderlyingDai();
    uint256 d = getTotalDebtAmount();
    require(v > d, 'profit is not realized yet!');
    uint256 profit = v.sub(d);

    uint256 _before = IERC20(want).balanceOf(address(this));
    _swap(_withdrawDaiMost(profit));
    uint256 _after = IERC20(want).balanceOf(address(this));

    uint256 _want = _after.sub(_before);
    if (_want > 0) {
      uint256 _fee = _want.mul(performanceFee).div(performanceMax);
      uint256 _strategistReward = _fee.mul(strategistReward).div(strategistRewardMax);
      IERC20(want).safeTransfer(strategist, _strategistReward);
      IERC20(want).safeTransfer(Controller(controller).rewards(), _fee.sub(_strategistReward));
    }

    deposit();
  }

  function shouldDraw() external view returns (bool) {
    uint256 _safe = c.mul(1e2);
    uint256 _current = getmVaultRatio(0);
    if (_current > c_base.mul(c_safe).mul(1e2)) {
      _current = c_base.mul(c_safe).mul(1e2);
    }
    return (_current > _safe);
  }

  function drawAmount() public view returns (uint256) {
    uint256 _safe = c.mul(1e2);
    uint256 _current = getmVaultRatio(0);
    if (_current > c_base.mul(c_safe).mul(1e2)) {
      _current = c_base.mul(c_safe).mul(1e2);
    }
    if (_current > _safe) {
      uint256 _eth = balanceOfmVault();
      uint256 _diff = _current.sub(_safe);
      uint256 _draw = _eth.mul(_diff).div(_safe).mul(c_base).mul(1e2).div(_current);
      return _draw.mul(_getPrice()).div(1e18);
    }
    return 0;
  }

  function draw() external {
    uint256 _drawD = drawAmount();
    if (_drawD > 0) {
      _lockWETHAndDrawDAI(0, _drawD);
      yVault(yVaultDAI).depositAll();
    }
  }

  function shouldRepay() external view returns (bool) {
    uint256 _safe = c.mul(1e2);
    uint256 _current = getmVaultRatio(0);
    _current = _current.mul(105).div(100); // 5% buffer to avoid deposit/rebalance loops
    return (_current < _safe);
  }

  function repayAmount() public view returns (uint256) {
    uint256 _safe = c.mul(1e2);
    uint256 _current = getmVaultRatio(0);
    _current = _current.mul(105).div(100); // 5% buffer to avoid deposit/rebalance loops
    if (_current < _safe) {
      uint256 d = getTotalDebtAmount();
      uint256 diff = _safe.sub(_current);
      return d.mul(diff).div(_safe);
    }
    return 0;
  }

  function repay() external {
    uint256 free = repayAmount();
    if (free > 0) {
      _wipe(_withdrawDaiLeast(free));
    }
  }

  function forceRebalance(uint256 _amount) external {
    require(msg.sender == governance || msg.sender == strategist || msg.sender == harvester, '!authorized');
    _wipe(_withdrawDaiLeast(_amount));
  }

  function getTotalDebtAmount() public view returns (uint256) {
    uint256 art;
    uint256 rate;
    address urnHandler = ManagerLike(cdp_manager).urns(cdpId);
    (, art) = VatLike(vat).urns(ilk, urnHandler);
    (, rate, , , ) = VatLike(vat).ilks(ilk);
    return art.mul(rate).div(1e27);
  }

  function getmVaultRatio(uint256 amount) public view returns (uint256) {
    uint256 spot; // ray
    uint256 liquidationRatio; // ray
    uint256 denominator = getTotalDebtAmount();

    if (denominator == 0) {
      return uint256(-1);
    }

    (, , spot, , ) = VatLike(vat).ilks(ilk);
    (, liquidationRatio) = SpotLike(mcd_spot).ilks(ilk);
    uint256 delayedCPrice = spot.mul(liquidationRatio).div(1e27); // ray

    uint256 _balance = balanceOfmVault();
    if (_balance < amount) {
      _balance = 0;
    } else {
      _balance = _balance.sub(amount);
    }

    uint256 numerator = _balance.mul(delayedCPrice).div(1e18); // ray
    return numerator.div(denominator).div(1e3);
  }

  function getUnderlyingDai() public view returns (uint256) {
    return IERC20(yVaultDAI).balanceOf(address(this)).mul(yVault(yVaultDAI).getPricePerFullShare()).div(1e18);
  }

  function _withdrawDaiMost(uint256 _amount) internal returns (uint256) {
    uint256 _shares = _amount.mul(1e18).div(yVault(yVaultDAI).getPricePerFullShare());

    if (_shares > IERC20(yVaultDAI).balanceOf(address(this))) {
      _shares = IERC20(yVaultDAI).balanceOf(address(this));
    }

    uint256 _before = IERC20(dai).balanceOf(address(this));
    yVault(yVaultDAI).withdraw(_shares);
    uint256 _after = IERC20(dai).balanceOf(address(this));
    return _after.sub(_before);
  }

  function _withdrawDaiLeast(uint256 _amount) internal returns (uint256) {
    uint256 _shares = _amount.mul(1e18).div(yVault(yVaultDAI).getPricePerFullShare()).mul(withdrawalMax).div(withdrawalMax.sub(withdrawalFee));

    if (_shares > IERC20(yVaultDAI).balanceOf(address(this))) {
      _shares = IERC20(yVaultDAI).balanceOf(address(this));
    }

    uint256 _before = IERC20(dai).balanceOf(address(this));
    yVault(yVaultDAI).withdraw(_shares);
    uint256 _after = IERC20(dai).balanceOf(address(this));
    return _after.sub(_before);
  }

  function _swap(uint256 _amountIn) internal {
    address[] memory path = new address[](2);
    path[0] = address(dai);
    path[1] = address(want);

    // approve unirouter to use dai
    Uni(unirouter).swapExactTokensForTokens(_amountIn, 0, path, address(this), now.add(1 days));
  }

  function setGovernance(address _governance) external {
    require(msg.sender == governance, '!governance');
    governance = _governance;
  }

  function setController(address _controller) external {
    require(msg.sender == governance, '!governance');
    controller = _controller;
  }
}
