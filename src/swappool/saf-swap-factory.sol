// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;


import {SafSwapV0Pair} from "./saf-swapv0pair.sol";
import {SafProxyContract} from "./saf-proxy-contract.sol";

contract SafSwapFactory {
    string public name;
    constructor(string memory _name){
        name = _name;
    }

    mapping(address => mapping(address=>address)) public pairs;
    
    function createPair(address _tokenA, address _tokenB, uint256 _swapFee) external returns(address) {
        require(_tokenA != address(0) && _tokenB != address(0), "Invalid token address");
        require(_tokenA != _tokenB, "Tokens cannot be the same");
        require(pairs[_tokenA][_tokenB] == address(0), "Pair already exists");
        require(pairs[_tokenB][_tokenA] == address(0), "Pair already exists");

        address v0pair = address(new SafSwapV0Pair());
        SafProxyContract  proxy= new SafProxyContract(payable(v0pair), msg.sender);
        SafSwapV0Pair  swapProxy= SafSwapV0Pair(payable(proxy));
        
        swapProxy.initialize("SwapPool-A2B", "lpA2B", 0, address(_tokenA), address(_tokenB), 0.01e18 );
        pairs[_tokenA][_tokenB] = address(swapProxy);
        return address(swapProxy) ;
    }

    function getPair(address _tokenA, address _tokenB) external view returns(address) {
        return pairs[_tokenA][_tokenB];
    }

}
