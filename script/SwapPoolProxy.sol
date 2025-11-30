// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "../lib/forge-std/src/Script.sol";
import {console} from "../lib/forge-std/src/console.sol";

import {ERC20} from "../src/erc20-tokens/erc20token.sol";
import {SafSwapV0Pair} from "../src/swappool/saf-swapv0pair.sol";

import {SafToken} from "../src/erc20-tokens/saf-token.sol";
import {SafProxyContract} from "../src/swappool/saf-proxy-contract.sol";

import { UD60x18, ud, Math,Common } from "../node_modules/@prb/math/src/UD60x18.sol";


contract SwapPoolProxyScript is Script {
    ERC20 public tokenA;
    ERC20 public tokenB;
    string public poolName;
    
    function setUpNewTokens() public {
        // tokenA = new SafToken("SafDToken", "safD", 2, 3_000_000_00);
        // tokenB = new SafToken("SafWToken", "safW", 2, 1_000_000_00);

        tokenA = ERC20(payable(0x5FbDB2315678afecb367f032d93F642f64180aa3));
        tokenB = ERC20(payable(0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512));
    }


    function run() public {

        vm.startBroadcast();
        setUpNewTokens();
        SafSwapV0Pair swapPool = new SafSwapV0Pair(); // 1% swap fee
        SafProxyContract poolProxy = new SafProxyContract(payable(swapPool), msg.sender);
        SafSwapV0Pair  swapProxy= SafSwapV0Pair(payable(poolProxy));
        swapProxy.initialize("SwapPool-A2B", "lpA2B", 0, address(tokenA), address(tokenB), 0.01e18 );

        vm.stopBroadcast();

        console.log("tokenA deployed at", address(tokenA));
        console.log("tokenB deployed at", address(tokenB));
        console.log("SafSwapV0Pair deployed at", address(poolProxy));
        console.log('-------------- bash helper script ----------');
        console.log(string.concat('export tokenA=', addrToHexString(address(tokenA))));
        console.log(string.concat('export tokenB=', addrToHexString(address(tokenB))));
        console.log(string.concat('export pool=', addrToHexString(address(poolProxy))));
        console.log('-------------- js helper script ----------');
        console.log(string.concat("export const tokenA='", addrToHexString(address(tokenA)), "'"));
        console.log(string.concat("export const tokenB='", addrToHexString(address(tokenB)), "'"));
        console.log(string.concat("export const pool='", addrToHexString(address(poolProxy)), "'"));
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
