// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "../erc20-interface/erc20interface.sol";
import { UD60x18, ud, Math } from "../../node_modules/@prb/math/src/UD60x18.sol";

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

contract SafSwapV0 {
    string public poolName;

    IERC20 public tokenA;
    
    IERC20 public tokenB;
    
    UD60x18 public exchangeRateAtoB = ud(0.85e18); // 0.85 * 1e18

    UD60x18 public lpTokenTotalSupply = ud(0);

    mapping(address => UD60x18) public lpPositions;

    UD60x18 public poolA;
    UD60x18 public poolB;

    function withdrawLp(UD60x18 _lpAmount) public {
        require(_lpAmount > 0, "LP amount must be greater than 0");
        require(lpPositions[msg.sender] >= _lpAmount, "Insufficient LP position");
        
        lpPositions[msg.sender] -= _lpAmount;

        _safeTransferFrom(tokenA, address(this), msg.sender, _lpAmount.mul(poolA).div(lpTokenTotalSupply));
        _safeTransferFrom(tokenB, address(this), msg.sender, _lpAmount.mul(poolB).div(lpTokenTotalSupply));
        
        lpTokenTotalSupply -= _lpAmount;
    }

    function depositPair(address _tokenA, uint256 _amountA, address _tokenB, uint256 _amountB) public {
        require(_amountA > 0 && _amountB > 0, "Amounts must be greater than 0");

        UD60x18 newLpTokenSupply = ud(0);
        if(lpTokenTotalSupply == ud(0)) {
            newLpTokenSupply = ud(_amountA).mul(ud(_amountB)).sqrt();
        } else {
            newLpTokenSupply = Math.min(ud(_amountA).mul(lpTokenTotalSupply).div(poolA), ud(_amountB).mul(lpTokenTotalSupply).div(poolB));
        }
        lpPositions[msg.sender] += newLpTokenSupply;
        lpTokenTotalSupply += newLpTokenSupply;

        _safeTransferFrom(tokenA, msg.sender, address(this), _amountA);
        _safeTransferFrom(tokenB, msg.sender, address(this), _amountB);
    }

    constructor(
        string memory _name,
        address _tokenA,
        address _tokenB
    ) {
        poolName = _name;
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }


    function swap() public {
        
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
}