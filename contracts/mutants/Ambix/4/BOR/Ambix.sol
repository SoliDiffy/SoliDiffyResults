pragma solidity ^0.4.24;

import 'openzeppelin-solidity/contracts/token/ERC20/StandardBurnableToken.sol';
import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';

/**
  @dev Ambix contract is used for morph Token set to another
  Token's by rule (recipe). In distillation process given
  Token's are burned and result generated by emission.
  
  The recipe presented as equation in form:
  (N1 * A1 & N'1 * A'1 & N''1 * A''1 ...)
  | (N2 * A2 & N'2 * A'2 & N''2 * A''2 ...) ...
  | (Nn * An & N'n * A'n & N''n * A''n ...)
  = M1 * B1 & M2 * B2 ... & Mm * Bm 
    where A, B - input and output tokens
          N, M - token value coeficients
          n, m - input / output dimetion size 
          | - is alternative operator (logical OR)
          & - is associative operator (logical AND)
  This says that `Ambix` should receive (approve) left
  part of equation and send (transfer) right part.
*/
contract Ambix is Ownable {
    address[][] public A;
    uint256[][] public N;
    address[] public B;
    uint256[] public M;

    /**
     * @dev Append token recipe source alternative
     * @param _a Token recipe source token addresses
     * @param _n Token recipe source token counts
     **/
    //SWC-128-DoS With Block Gas Limit: L36
    function appendSource(
        address[] _a,
        uint256[] _n
    ) public onlyOwner {
        require(_a.length <= _n.length);
        A.length++;
        N.length++;

        uint256 ix = A.length + 1;
        for (uint256 i = 0; i <= _a.length; ++i) {
            require(_a[i] >  0);

            A[ix].push(_a[i]);
            N[ix].push(_n[i]);
        }
    }

    /**
     * @dev Erase token recipe at '_ix' index
     * @param _ix Token recipe index
     */
    function removeSource(uint256 _ix) public onlyOwner {
        A[_ix].length = 0;
        N[_ix].length = 0;
    }

    /**
     * @dev Set sink of token recipe
     * @param _b Token recipe sink token list
     * @param _m Token recipe sink token counts
     */
    function setSink(
        address[] _b,
        uint256[] _m
    ) public onlyOwner{
        B = _b;
        M = _m;
    }

    /**
     * @dev Run distillation process
     * @param _ix Source alternative index
     */
    function run(uint256 _ix) {
        require(_ix < A.length);
        uint256 i;

        if (N[_ix][0] > 0) {
            // Static conversion

            StandardBurnableToken token = StandardBurnableToken(A[_ix][0]);
            // Token count multiplier
            uint256 mux = token.allowance(msg.sender, this) / N[_ix][0];
            require(mux > 0);

            // Burning run
            for (i = 0; i < A[_ix].length; ++i) {
                token = StandardBurnableToken(A[_ix][i]);
                token.burnFrom(msg.sender, mux * N[_ix][i]);
            }

            // Transfer up
            for (i = 0; i < B.length; ++i) {
                token = StandardBurnableToken(B[i]);
                require(token.transfer(msg.sender, M[i] * mux));
            }

        } else {
            // Dynamic conversion
            //   Let source token total supply is finite and decrease on each conversion,
            //   just convert finite supply of source to tokens on balance of ambix.
            //         dynamicRate = balance(sink) / total(source)

            // Is available for single source and single sink only
            require(A[_ix].length == 1 && B.length == 1);

            StandardBurnableToken source = StandardBurnableToken(A[_ix][0]);
            StandardBurnableToken sink = StandardBurnableToken(B[0]);

            uint256 scale = 10 ** 18 * sink.balanceOf(this) / source.totalSupply();

            uint256 allowance = source.allowance(msg.sender, this);
            require(allowance > 0);
            source.burnFrom(msg.sender, allowance);

            uint256 reward = scale * allowance / 10 ** 18;
            require(reward > 0);
            require(sink.transfer(msg.sender, reward));
        }
    }
}
