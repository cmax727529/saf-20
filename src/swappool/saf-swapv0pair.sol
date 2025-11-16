// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ERC20} from "../erc20-tokens/erc20token.sol";
import {IERC20} from "../erc20-interface/erc20interface.sol";
import { UD60x18, ud, Math,Common } from "../../node_modules/@prb/math/src/UD60x18.sol";

/*
How to swap tokens

1. Alice has 100 tokens from AliceCoin, which is a ERC20 token.
2. Bob has 100 tokens from BobCoin, which is also a ERC20 token.
3. Alice and Bob wants to trade 10 AliceCoin for 20 BobCoin.
4. Alice or Bob deploys TokenSwap
5. Alice approves TokenSwap to withdraw 10 tokens from AliceCoin
6. Bob approves TokenSwap to withdraw 20 tokens from BobCoin
7. Alice or Bob calls TokenSwap.swap()
8. Alice and Bob traded tokens successfully.
*/

contract SafSwapV0Pair is ERC20 {
    
    event Swap(address indexed owner, 
        address indexed tokenIn,
        address indexed tokenOut,
        uint256 amountIn,
        uint256 amountOut,
        uint256 rate);

    
    IERC20 public tokenA;
    
    IERC20 public tokenB;
    uint256 internal constant _scale = 1e18;
    function exchangeRate () public view returns(UD60x18) {
        // return fixed
        return ud(0.85e18); // 0.85 * 1e18, A = exchangeRate * B
    }

    // swap fee is 1%
    uint256 public swapFee ; // 1%
    

    mapping(address => UD60x18) public lpPositions; //track lp balances

    uint256 public poolA;
    uint256 public poolB;

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        address _tokenA,
        address _tokenB,
        uint256 _swapFee // 1%
    )  ERC20(_name, _symbol, _decimals) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
        swapFee = _swapFee < 0.005e18 ? _swapFee : 0.01e18; // 1%
        require(swapFee >= 0.01e18, "Swap fee must be less than 1%");
    }
    // =========================== pool functions ===========================
    // only deposit pair tokens under the rate of exchangeRate
    function depositPair(uint256 _amountA, uint256 _amountB) external  {
        require(_amountA > 0 && _amountB > 0, "Amounts must be greater than 0");

        uint256 newLpTokenSupply=0;
        
        UD60x18 pairedAAmount = ud(_amountB).mul(exchangeRate());
        if(_amountA > pairedAAmount.unwrap()) {
            _amountA = pairedAAmount.unwrap();
        }else{
            _amountB = ud(_amountA).div(exchangeRate()).unwrap();
        }

        //update pool reserves
        poolA += _amountA;
        poolB += _amountB;

        if(totalSupply == 0) {
            newLpTokenSupply = Common.sqrt(_amountA * _amountB);
        } else {
            // newtokensupply = min(amountA * lpTokenTotalSupply / poolA, amountB * lpTokenTotalSupply / poolB)
            newLpTokenSupply = _min(ud(_amountA).mul(ud(totalSupply*_scale/poolA)), ud(_amountB).mul(ud(totalSupply*_scale/poolB))).unwrap();
        }
        
        
        _mint(msg.sender, newLpTokenSupply);
      
        
        _safeTransferFrom(tokenA, msg.sender, address(this), _amountA);
        _safeTransferFrom(tokenB, msg.sender, address(this), _amountB);
    }



    function withdrawLp(uint256 _lpAmount) external {
                
        require(_lpAmount > 0, "LP amount must be greater than 0");
        require(balanceOf[msg.sender] >= _lpAmount, "Insufficient LP position");
        
        uint256 _withdrawlAmtA = _lpAmount * poolA  / totalSupply;
        uint256 _withdrawlAmtB = _lpAmount * poolB  / totalSupply;
        //update pool reserves
        poolA -= _withdrawlAmtA;
        poolB -= _withdrawlAmtB;

        _burn(msg.sender, _lpAmount);
        _safeTransferFrom(tokenA, address(this), msg.sender, _withdrawlAmtA);
        _safeTransferFrom(tokenB, address(this), msg.sender, _withdrawlAmtB);
        
    }

    //========================== swap functions ===========================
    // swap function
    function _swap(IERC20 tokenIn, uint256 _amountIn, IERC20 tokenOut, uint256 _amountOut) internal returns(bool){
        require(_amountIn > 0 && _amountOut > 0, "Amounts must be greater than 0");

        // tokenIn.transferFrom(msg.sender, address(this), _amountIn.unwrap());
        // tokenOut.transfer(msg.sender, _amountOut.unwrap());

        _safeTransferFrom(tokenIn, msg.sender, address(this), _amountIn);
        _safeTransferFrom(tokenOut, address(this), msg.sender, _amountOut);

        //update pool reserves
        poolA += _amountIn;
        poolB += _amountOut;

        emit Swap(msg.sender, address(tokenIn), address(tokenOut), _amountIn, _amountOut, exchangeRate().unwrap());

        return true;    
    }

    // sell A, buy B
    function swapA(uint256 _amountA) external returns(uint256){
        UD60x18 rate = exchangeRate();
        UD60x18 _amountB = ud(_amountA).mul(rate).mul(ud(1e18 - swapFee));

        require(_swap(tokenA, _amountA, tokenB, _amountB.unwrap()), "Swap failed");
        return _amountB.unwrap();
    }

    // sell B, buy A
    function swapB(uint256 _amountB) external returns(uint256){
        UD60x18 rate = exchangeRate();
        UD60x18 _amountA = ud(_amountB).div(rate).mul(ud(1e18 - swapFee));
        require(_swap(tokenB, _amountB, tokenA, _amountA.unwrap()), "Swap failed");
        return _amountA.unwrap();
    }


    function getReserves() external view returns(uint256, uint256) {
        return (poolA, poolB);
    }


    // ========= alowance functions =========
    function requestApprove(IERC20 token, address spender, uint256 amount) external {
        // how to send request message to wallet?
        bool approved = token.approve(spender, amount);
        require(approved, "Approve failed");
    }



    function _safeTransferFrom(
        IERC20 token,
        address sender, 
        address recipient,
        uint256 amount
    ) private {
        bool sent = token.transferFrom(sender, recipient, amount);
        require(sent, "Token transfer failed");
    }


    // math helper function
    function _min(UD60x18 a, UD60x18 b) private pure returns(UD60x18) {
        return a < b ? a : b;
    }

    function _max(UD60x18 a, UD60x18 b) private pure returns(UD60x18) { 
        return a > b ? a : b;
    }
}