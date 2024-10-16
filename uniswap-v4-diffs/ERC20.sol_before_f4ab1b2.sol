pragma solidity 0.5.13;

import "../interfaces/IERC20.sol";
import "../libraries/SafeMath.sol";

contract ERC20 is IERC20 {
    using SafeMath for uint;

    string public name;
    string public symbol;
    uint8 public decimals;
    uint  public totalSupply;
    mapping (address => uint) public balanceOf;
    mapping (address => mapping (address => uint)) public allowance;

	bytes32 public DOMAIN_SEPARATOR;
    // keccak256("Approve(address owner,address spender,uint256 value,uint256 nonce,uint256 expiration)");
	bytes32 public constant APPROVE_TYPEHASH = hex"25a0822e8c2ed7ff64a57c55df37ff176282195b9e0c9bb770ed24a300c89762";
    mapping (address => uint) public nonces;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    function MOCK_getChainId() private pure returns (uint) {
        return 1;
    }

    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint _totalSupply) public {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        if (_totalSupply > 0) {
            mint(msg.sender, _totalSupply);
        }
        DOMAIN_SEPARATOR = keccak256(abi.encode(
			keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
			keccak256(bytes(name)),
			keccak256(bytes("1")),
			MOCK_getChainId(),
			address(this)
		));
    }

    function mint(address to, uint value) internal {
        totalSupply = totalSupply.add(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint value) internal {
        balanceOf[from] = balanceOf[from].sub(value);
        totalSupply = totalSupply.sub(value);
        emit Transfer(from, address(0), value);
    }

    function _transfer(address from, address to, uint value) private {
        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(from, to, value);
    }

    function _approve(address owner, address spender, uint value) private {
        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function transfer(address to, uint value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function burn(uint value) external {
        _burn(msg.sender, value);
    }

    function approve(address spender, uint value) external returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function approveMeta(
        address owner, address spender, uint value, uint nonce, uint expiration, uint8 v, bytes32 r, bytes32 s
    )
        external
    {
        require(nonce == nonces[owner]++, "ERC20: INVALID_NONCE");
        // solium-disable-next-line security/no-block-members
        require(expiration > block.timestamp, "ERC20: EXPIRED");
        require(v == 27 || v == 28, "ERC20: INVALID_V");
        require(uint(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ERC20: INVALID_S");
        bytes32 digest = keccak256(abi.encodePacked(
            hex"19",
            hex"01",
            DOMAIN_SEPARATOR,
            keccak256(abi.encode(APPROVE_TYPEHASH, owner, spender, value, nonce, expiration))
        ));
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0), "ERC20: INVALID_SIGNATURE");
        require(recoveredAddress == owner, "ERC20: INVALID_ADDRESS");
        _approve(owner, spender, value);
    }

    function transferFrom(address from, address to, uint value) external returns (bool) {
        if (allowance[from][msg.sender] != uint(-1)) {
            allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);
        }
        _transfer(from, to, value);
        return true;
    }

    function burnFrom(address from, uint value) external {
        if (allowance[from][msg.sender] != uint(-1)) {
            allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);
        }
        _burn(from, value);
    }
}