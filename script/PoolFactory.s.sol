// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "../lib/forge-std/src/Script.sol";
import {console} from "../lib/forge-std/src/console.sol";

import {ERC20} from "../src/erc20-tokens/erc20token.sol";
import {SafSwapV0Pair} from "../src/swappool/saf-swapv0pair.sol";

import {SafToken} from "../src/erc20-tokens/saf-token.sol";

import { UD60x18, ud, Math,Common } from "../node_modules/@prb/math/src/UD60x18.sol";

function fromUint(uint256 value) returns(UD60x18) {
    return UD60x18.wrap(value * 1e18);
}

contract PoolFactoryScript is Script {
    ERC20 public tokenA;
    ERC20 public tokenB;
    string public poolName;
    
    function setUpNewTokens() public {
        tokenA = new SafToken("SafDToken", "safD", 2, 3_000_000_00);
        tokenB = new SafToken("SafWToken", "safW", 2, 1_000_000_00);
    }

    function test() public {
        uint256 _amountA = 100;
        uint256 _amountB = 80;
        UD60x18 rate = ud(0.85e18);

        UD60x18 poolA = ud(0);
        uint256 totalSupply = 0;
        UD60x18 poolB;
        UD60x18 newLpTokenSupply ;
        
        UD60x18 pairedAAmount = ud(_amountB).mul(rate);
        if(_amountA > pairedAAmount.unwrap()) {
            _amountA = pairedAAmount.unwrap();
        }else{
            _amountB = ud(_amountA).div(rate).unwrap();
        }

        //update pool reserves
        poolA = poolA.add(ud(_amountA));
        poolB = poolB.add(ud(_amountB));

    
        if(true || totalSupply == 0) {
            newLpTokenSupply = ud(1).div(ud(1));
        } else {
            // newtokensupply = min(amountA * lpTokenTotalSupply / poolA, amountB * lpTokenTotalSupply / poolB)
            // newLpTokenSupply = _min(ud(_amountA).mul(ud(totalSupply)).div(poolA), ud(_amountB).mul(ud(totalSupply)).div(poolB));
        }
        UD60x18 one = ud(1e18);
        UD60x18 two = ud(1e18);

        uint256 result =Common.sqrt(100* 200);
        UD60x18 result2 = Math.sqrt(ud(10000e18));
        
        console.log(result);
        console.log(result2.unwrap()/1e18);
        
    }
    function run() public {
        // test();
        // return;

        vm.startBroadcast();
        setUpNewTokens();
        SafSwapV0Pair swapPool = new SafSwapV0Pair("SwapPool-A2B", "lpA2B", 18, address(tokenA), address(tokenB), 0.01e18 ); // 1% swap fee
        vm.stopBroadcast();

        console.log("tokenA deployed at", address(tokenA));
        console.log("tokenB deployed at", address(tokenB));
        console.log("SafSwapV0Pair deployed at", address(swapPool));
        console.log('-------------- bash helper script ----------');
        console.log(string.concat('export tokenA=', addrToHexString(address(tokenA))));
        console.log(string.concat('export tokenB=', addrToHexString(address(tokenB))));
        console.log(string.concat('export pool=', addrToHexString(address(swapPool))));
        console.log('-------------- js helper script ----------');
        console.log(string.concat("export const tokenA='", addrToHexString(address(tokenA)), "'"));
        console.log(string.concat("export const tokenB='", addrToHexString(address(tokenB)), "'"));
        console.log(string.concat("export const poolSwap='", addrToHexString(address(swapPool)), "'"));
        console.log('--------------  ----------');

        
    }

    function addrToHexString(address account) internal pure returns (string memory) {
        bytes20 data = bytes20(account);
        bytes memory str = new bytes(42);
        str[0] = '0';
        str[1] = 'x';
        bytes16 hexSymbols = "0123456789abcdef";
        for (uint256 i = 0; i < 20; i++) {
            str[2 + i * 2] = hexSymbols[uint8(data[i] >> 4)];
            str[3 + i * 2] = hexSymbols[uint8(data[i] & 0x0f)];
        }
        return string(str);
    }

    function _min(UD60x18 a, UD60x18 b) private pure returns(UD60x18) {
        return a < b ? a : b;
    }

}
