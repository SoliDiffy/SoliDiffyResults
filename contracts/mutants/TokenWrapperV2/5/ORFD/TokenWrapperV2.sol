// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0;

import "@openzeppelin/contracts-upgradeable/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "./interfaces/IUTokens.sol";
import "./interfaces/ITokenWrapper.sol";
import "./libraries/Bech32.sol";
import "./libraries/FullMath.sol";

contract TokenWrapperV2 is
	ITokenWrapper,
	PausableUpgradeable,
	AccessControlUpgradeable
{
	using SafeMathUpgradeable for uint256;
	using FullMath for uint256;
	using Bech32 for string;

	//Private instances of contracts to handle Utokens and Stokens
	IUTokens public _uTokens;

	// defining the fees and minimum values
	uint256 private _minDeposit;
	uint256 private _minWithdraw;
	uint256 private _depositFee;
	uint256 private _withdrawFee;
	uint256 private _valueDivisor;

	// constants defining access control ROLES
	bytes32 public constant BRIDGE_ADMIN_ROLE = keccak256("BRIDGE_ADMIN_ROLE");
	bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

	//variables defining bech32 validation attributes
	bytes public hrpBytes;
	bytes public controlDigitBytes;
	uint256 public dataBytesSize;

	/*
	 * @dev Constructor for initializing the TokenWrapper contract.
	 * @param uAddress - address of the UToken contract.
	 * @param bridgeAdminAddress - address of the bridge admin.
	 * @param pauserAddress - address of the pauser admin.
	 * @param valueDivisor - valueDivisor set to 10^9.
	 */
	function initialize(
		address uAddress,
		address bridgeAdminAddress,
		address pauserAddress,
		uint256 valueDivisor
	) public virtual initializer {
		__AccessControl_init();
		__Pausable_init();
		_setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
		_setupRole(BRIDGE_ADMIN_ROLE, bridgeAdminAddress);
		_setupRole(PAUSER_ROLE, pauserAddress);
		setUTokensContract(uAddress);
		setMinimumValues(1, 1);
		_valueDivisor = valueDivisor;
		// setting bech32 validation attributes
		hrpBytes = "cosmos";
		controlDigitBytes = "1";
		dataBytesSize = 38;
	}

	/**
	 * @dev Set 'fees', called from admin
	 * @param withdrawFee: withdraw fee
	 * @param depositFee: deposit fee
	 *
	 * Emits a {SetFees} event with 'fee' set to the withdraw.
	 *
	 */
	function setFees(uint256 depositFee, uint256 withdrawFee)
		public
		virtual
		returns (bool success)
	{
		require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "TW1");
		// range checks for fees. Since fee cannot be more than 100%, the max cap
		// is _valueDivisor * 100, which then brings the fees to 100 (percentage)
		require(
			(depositFee <= _valueDivisor.mul(100) || depositFee == 0) &&
				(withdrawFee <= _valueDivisor.mul(100) || withdrawFee == 0),
			"TW2"
		);
		_depositFee = depositFee;
		_withdrawFee = withdrawFee;
		emit SetFees(depositFee, withdrawFee);
		return true;
	}

	/**
	 * @dev get fees, minimum set values and value divisor
	 *
	 */
	function getProps()
		public
		view
		virtual
		returns (
			uint256 depositFee,
			uint256 withdrawFee,
			uint256 minDeposit,
			uint256 minWithdraw,
			uint256 valueDivisor
		)
	{
		depositFee = _depositFee;
		withdrawFee = _withdrawFee;
		minDeposit = _minDeposit;
		minWithdraw = _minWithdraw;
		valueDivisor = _valueDivisor;
	}

	/**
	 * @dev Set 'minimum values', called from admin
	 * @param minDeposit: deposit minimum value
	 * @param minWithdraw: withdraw minimum value
	 *
	 * Emits a {SetMinimumValues} event with 'minimum value' set to withdraw.
	 *
	 */
	function setMinimumValues(uint256 minDeposit, uint256 minWithdraw)
		public
		virtual
		returns (bool success)
	{
		require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "TW3");
		require(minDeposit >= 1, "TW4");
		require(minWithdraw >= 1, "TW5");
		_minDeposit = minDeposit;
		_minWithdraw = minWithdraw;
		emit SetMinimumValues(minDeposit, minWithdraw);
		return true;
	}

	/*
	 * @dev Set 'contract address', called for utokens smart contract
	 * @param uAddress: utoken contract address
	 *
	 * Emits a {SetUTokensContract} event with '_contract' set to the utoken contract address.
	 *
	 */
	

	/**
	 * @dev Triggers stopped state.
	 *
	 * Requirements:
	 *
	 * - The contract must not be paused.
	 */
	function pause() public virtual returns (bool success) {
		require(hasRole(PAUSER_ROLE, _msgSender()), "TW7");
		_pause();
		return true;
	}

	/**
	 * @dev Returns to normal state.
	 *
	 * Requirements:
	 *
	 * - The contract must be paused.
	 */
	function unpause() public virtual returns (bool success) {
		require(hasRole(PAUSER_ROLE, _msgSender()), "TW8");
		_unpause();
		return true;
	}

	/**
	 * @dev common function added to be called by generateUTokens and generateUTokensInBatch and mints new utokens for the provided 'address' and 'amount'
	 * @param to: account address, amount: number of tokens
	 * Requirements:
	 *
	 * - `amount` cannot be less than zero.
	 *
	 */
	function _generateUTokens(address to, uint256 amount)
		internal
		virtual
		returns (uint256 finalTokens)
	{
		// the tokens to be generated to the user's address will be after the fee processing
		uint256 _fee = (amount.mulDiv(_depositFee, _valueDivisor)).div(100);
		finalTokens = amount.sub(_fee);
		_uTokens.mint(to, finalTokens);
		return finalTokens;
	}

	/**
	 * @dev Mint new utokens for the provided 'address' and 'amount'
	 * @param to: account address, amount: number of tokens
	 *
	 * Emits a {GenerateUTokens} event with 'to' set to address and 'amount' set to amount of tokens.
	 *
	 * Requirements:
	 *
	 * - `amount` cannot be less than zero.
	 *
	 */
	

	/**
	 * @dev Mint new utokens for the provided 'address' and 'amount' in batch
	 * @param to[]: array of account addresses, amount[]: array of tokens
	 *
	 * Emits a {GenerateUTokens} event with 'to' set to address and 'amount' set to amount of tokens.
	 *
	 * Requirements:
	 *
	 * - `amount` cannot be less than zero.
	 *
	 */
	

	/**
	 * @dev check if the address is Bech32Valid
	 *
	 */
	

	/**
	 * @dev Burn utokens for the provided 'address' and 'tokens'
	 * @param from: account address, tokens: number of tokens, toChainAddress: atom wallet address
	 *
	 * Emits a {WithdrawUTokens} event with 'from' set to address, 'finalTokens' set to amount of tokens and 'toChainAddress'
	 *
	 * Requirements:
	 *
	 * - `tokens` cannot be less than zero.
	 *
	 */
	
}
