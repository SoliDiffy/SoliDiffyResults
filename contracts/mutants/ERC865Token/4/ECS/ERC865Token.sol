pragma solidity ^0.4.24;

// import "zeppelin-solidity/contracts/token/ERC20/StandardToken.sol";
// import "openzeppelin-eth/contracts/token/ERC20/ERC20.sol";
import "./ERC865.sol";

/**
 * @title ERC865Token Token
 *
 * ERC865Token allows users paying transfers in tokens instead of gas
 * https://github.com/ethereum/EIPs/issues/865
 *
 */

contract ERC865Token is ERC865 {

    /* Nonces of transfers performed */
    mapping(bytes => bool) signatures;

    event TransferPreSigned(address indexed from, address indexed to, address indexed delegate, uint256 amount, uint256 fee);
    event ApprovalPreSigned(address indexed from, address indexed to, address indexed delegate, uint256 amount, uint256 fee);

    /**
     * @notice Submit a presigned transfer
     * @param _signature bytes The signature, issued by the owner.
     * @param _to address The address which you want to transfer to.
     * @param _value uint256 The amount of tokens to be transferred.
     * @param _fee uint256 The amount of tokens paid to msg.sender, by the owner.
     * @param _nonce uint256 Presigned transaction number.
     */
    function transferPreSigned(
        bytes _signature,
        address _to,
        uint256 _value,
        uint256 _fee,
        uint256 _nonce
    )
        public
        returns (bool)
    {
        require(_to != address(0));
        require(signatures[_signature] == false);

        bytes32 hashedTx = transferPreSignedHashing(address(this), _to, _value, _fee, _nonce);

        address from = recover(hashedTx, _signature);
        require(from != address(0));
        _transfer(from, _to, _value);
        _transfer(from, msg.sender, _fee);
        // _balances[from] = _balances[from].sub(_value).sub(_fee);
        // _balances[_to] = _balances[_to].add(_value);
        // _balances[msg.sender] = _balances[msg.sender].add(_fee);
        signatures[_signature] = true;

        // Transfer(from, _to, _value);
        // Transfer(from, msg.sender, _fee);
        TransferPreSigned(from, _to, msg.sender, _value, _fee);
        return true;
    }

    /**
     * @notice Submit a presigned approval
     * @param _signature bytes The signature, issued by the owner.
     * @param _spender address The address which will spend the funds.
     * @param _value uint256 The amount of tokens to allow.
     * @param _fee uint256 The amount of tokens paid to msg.sender, by the owner.
     * @param _nonce uint256 Presigned transaction number.
     */
    function approvePreSigned(
        bytes _signature,
        address _spender,
        uint256 _value,
        uint256 _fee,
        uint256 _nonce
    )
        public
        returns (bool)
    {
        require(_spender != address(0));
        require(signatures[_signature] == false);

        bytes32 hashedTx = approvePreSignedHashing(address(this), _spender, _value, _fee, _nonce);
        address from = recover(hashedTx, _signature);
        require(from != address(0));
        _approve(from, spender, _value);
        // _allowed[from][_spender] = _value;
        _transfer(from, msg.sender, _fee);
        // _balances[from] = _balances[from].sub(_fee);
        // _balances[msg.sender] = _balances[msg.sender].add(_fee);
        signatures[_signature] = true;

        // Approval(from, _spender, _value);
        // Transfer(from, msg.sender, _fee);
        ApprovalPreSigned(from, _spender, msg.sender, _value, _fee);
        return true;
    }

    /**
     * @notice Increase the amount of tokens that an owner allowed to a spender.
     * @param _signature bytes The signature, issued by the owner.
     * @param _spender address The address which will spend the funds.
     * @param _addedValue uint256 The amount of tokens to increase the allowance by.
     * @param _fee uint256 The amount of tokens paid to msg.sender, by the owner.
     * @param _nonce uint256 Presigned transaction number.
     */
    function increaseApprovalPreSigned(
        bytes _signature,
        address _spender,
        uint256 _addedValue,
        uint256 _fee,
        uint256 _nonce
    )
        public
        returns (bool)
    {
        require(_spender != address(0));
        require(signatures[_signature] == false);

        bytes32 hashedTx = increaseApprovalPreSignedHashing(address(this), _spender, _addedValue, _fee, _nonce);
        address from = recover(hashedTx, _signature);
        require(from != address(0));
        _approve(from, _spender, allowance(from, _spender).add(_addedValue));
        // _allowed[from][_spender] = _allowed[from][_spender].add(_addedValue);
        _transfer(from, msg.sender, _fee);
        // _balances[from] = _balances[from].sub(_fee);
        // _balances[msg.sender] = _balances[msg.sender].add(_fee);
        signatures[_signature] = true;

        // Approval(from, _spender, _allowed[from][_spender]);
        // Transfer(from, msg.sender, _fee);
        ApprovalPreSigned(from, _spender, msg.sender, _allowed[from][_spender], _fee);
        return true;
    }

    /**
     * @notice Decrease the amount of tokens that an owner allowed to a spender.
     * @param _signature bytes The signature, issued by the owner
     * @param _spender address The address which will spend the funds.
     * @param _subtractedValue uint256 The amount of tokens to decrease the allowance by.
     * @param _fee uint256 The amount of tokens paid to msg.sender, by the owner.
     * @param _nonce uint256 Presigned transaction number.
     */
    function decreaseApprovalPreSigned(
        bytes _signature,
        address _spender,
        uint256 _subtractedValue,
        uint256 _fee,
        uint256 _nonce
    )
        public
        returns (bool)
    {
        require(_spender != address(0));
        require(signatures[_signature] == false);

        bytes32 hashedTx = decreaseApprovalPreSignedHashing(address(this), _spender, _subtractedValue, _fee, _nonce);
        address from = recover(hashedTx, _signature);
        require(from != address(0));

        // uint oldValue = _allowed[from][_spender];
        if (_subtractedValue > oldValue) {
            _approve(from, spender, 0);
            // _allowed[from][_spender] = 0;
        } else {
            _approve(from, spender, allowed(from,spender).sub(_subtractedValue));
            // _allowed[from][_spender] = oldValue.sub(_subtractedValue);
        }
        _transfer(from, msg.sender, _fee);
        // _balances[from] = _balances[from].sub(_fee);
        // _balances[msg.sender] = _balances[msg.sender].add(_fee);
        signatures[_signature] = true;

        // Approval(from, _spender, _subtractedValue);
        // Transfer(from, msg.sender, _fee);
        ApprovalPreSigned(from, _spender, msg.sender, _allowed[from][_spender], _fee);
        return true;
    }

    /**
     * @notice Transfer tokens from one address to another
     * @param _signature bytes The signature, issued by the spender.
     * @param _from address The address which you want to send tokens from.
     * @param _to address The address which you want to transfer to.
     * @param _value uint256 The amount of tokens to be transferred.
     * @param _fee uint256 The amount of tokens paid to msg.sender, by the spender.
     * @param _nonce uint256 Presigned transaction number.
     */
    function transferFromPreSigned(
        bytes _signature,
        address _from,
        address _to,
        uint256 _value,
        uint256 _fee,
        uint256 _nonce
    )
        public
        returns (bool)
    {
        require(_to != address(0));
        require(signatures[_signature] == false);

        bytes32 hashedTx = transferFromPreSignedHashing(address(this), _from, _to, _value, _fee, _nonce);

        address spender = recover(hashedTx, _signature);
        require(spender != address(0));

        _transfer(_from, _to, _value);
        // _balances[_from] = _balances[_from].sub(_value);
        // _balances[_to] = _balances[_to].add(_value);
        _aprove(_from, spender, approved(_from, spender).sub(_value));
        // _allowed[_from][spender] = _allowed[_from][spender].sub(_value);
        _transfer(spender, msg.sender, _fee);
        // _balances[spender] = _balances[spender].sub(_fee);
        // _balances[msg.sender] = _balances[msg.sender].add(_fee);
        signatures[_signature] = true;

        // Transfer(_from, _to, _value);
        // Transfer(spender, msg.sender, _fee);
        return true;
    }


    /**
     * @notice Hash (keccak256) of the payload used by transferPreSigned
     * @param _token address The address of the token.
     * @param _to address The address which you want to transfer to.
     * @param _value uint256 The amount of tokens to be transferred.
     * @param _fee uint256 The amount of tokens paid to msg.sender, by the owner.
     * @param _nonce uint256 Presigned transaction number.
     */
    function transferPreSignedHashing(
        address _token,
        address _to,
        uint256 _value,
        uint256 _fee,
        uint256 _nonce
    )
        public
        pure
        returns (bytes32)
    {
        /* "48664c16": transferPreSignedHashing(address,address,address,uint256,uint256,uint256) */
        return keccak256(bytes1(0x48664c16), _token, _to, _value, _fee, _nonce);
    }

    /**
     * @notice Hash (keccak256) of the payload used by approvePreSigned
     * @param _token address The address of the token
     * @param _spender address The address which will spend the funds.
     * @param _value uint256 The amount of tokens to allow.
     * @param _fee uint256 The amount of tokens paid to msg.sender, by the owner.
     * @param _nonce uint256 Presigned transaction number.
     */
    function approvePreSignedHashing(
        address _token,
        address _spender,
        uint256 _value,
        uint256 _fee,
        uint256 _nonce
    )
        public
        pure
        returns (bytes32)
    {
        /* "f7ac9c2e": approvePreSignedHashing(address,address,uint256,uint256,uint256) */
        return keccak256(bytes1(0xf7ac9c2e), _token, _spender, _value, _fee, _nonce);
    }

    /**
     * @notice Hash (keccak256) of the payload used by increaseApprovalPreSigned
     * @param _token address The address of the token
     * @param _spender address The address which will spend the funds.
     * @param _addedValue uint256 The amount of tokens to increase the allowance by.
     * @param _fee uint256 The amount of tokens paid to msg.sender, by the owner.
     * @param _nonce uint256 Presigned transaction number.
     */
    function increaseApprovalPreSignedHashing(
        address _token,
        address _spender,
        uint256 _addedValue,
        uint256 _fee,
        uint256 _nonce
    )
        public
        pure
        returns (bytes32)
    {
        /* "a45f71ff": increaseApprovalPreSignedHashing(address,address,uint256,uint256,uint256) */
        return keccak256(bytes1(0xa45f71ff), _token, _spender, _addedValue, _fee, _nonce);
    }

     /**
      * @notice Hash (keccak256) of the payload used by decreaseApprovalPreSigned
      * @param _token address The address of the token
      * @param _spender address The address which will spend the funds.
      * @param _subtractedValue uint256 The amount of tokens to decrease the allowance by.
      * @param _fee uint256 The amount of tokens paid to msg.sender, by the owner.
      * @param _nonce uint256 Presigned transaction number.
      */
    function decreaseApprovalPreSignedHashing(
        address _token,
        address _spender,
        uint256 _subtractedValue,
        uint256 _fee,
        uint256 _nonce
    )
        public
        pure
        returns (bytes32)
    {
        /* "59388d78": decreaseApprovalPreSignedHashing(address,address,uint256,uint256,uint256) */
        return keccak256(bytes1(0x59388d78), _token, _spender, _subtractedValue, _fee, _nonce);
    }

    /**
     * @notice Hash (keccak256) of the payload used by transferFromPreSigned
     * @param _token address The address of the token
     * @param _from address The address which you want to send tokens from.
     * @param _to address The address which you want to transfer to.
     * @param _value uint256 The amount of tokens to be transferred.
     * @param _fee uint256 The amount of tokens paid to msg.sender, by the spender.
     * @param _nonce uint256 Presigned transaction number.
     */
    function transferFromPreSignedHashing(
        address _token,
        address _from,
        address _to,
        uint256 _value,
        uint256 _fee,
        uint256 _nonce
    )
        public
        pure
        returns (bytes32)
    {
        /* "b7656dc5": transferFromPreSignedHashing(address,address,address,uint256,uint256,uint256) */
        return keccak256(bytes4(0xb7656dc5), _token, _from, _to, _value, _fee, _nonce);
    }

    /**
     * @notice Recover signer address from a message by using his signature
     * @param hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
     * @param sig bytes signature, the signature is generated using web3.eth.sign()
     */
    function recover(bytes32 hash, bytes sig) public pure returns (address) {
      bytes32 r;
      bytes32 s;
      uint8 v;

      //Check the signature length
      if (sig.length != 65) {
        return (address(0));
      }

      // Divide the signature in r, s and v variables
      assembly {
        r := mload(add(sig, 32))
        s := mload(add(sig, 64))
        v := byte(0, mload(add(sig, 96)))
      }

      // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
      if (v < 27) {
        v += 27;
      }

      // If the version is correct return the signer address
      if (v != 27 && v != 28) {
        return (address(0));
      } else {
        return ecrecover(hash, v, r, s);
      }
    }

}