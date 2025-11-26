// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "../lib/forge-std/src/Script.sol";
import {console} from "../lib/forge-std/src/console.sol";

import {ERC20} from "../src/erc20-tokens/erc20token.sol";
import {SafSwapV0Pair} from "../src/swappool/saf-swapv0pair.sol";

import {SafToken} from "../src/erc20-tokens/saf-token.sol";
import {SafProxyContract} from "../src/swappool/saf-proxy-contract.sol";

import { UD60x18, ud, Math,Common } from "../node_modules/@prb/math/src/UD60x18.sol";


contract RecreatePoolImplScript is Script {
    ERC20 public tokenA;
    ERC20 public tokenB;
    string public poolName;
    

    function run() public {
    
        // string memory tokenA = vm.envString("tokenA");
        // string memory tokenB = vm.envString("tokenB");
        address tokenAAddr = address(0xa82fF9aFd8f496c3d6ac40E2a0F282E47488CFc9);
        address tokenBAddr = address(0x1613beB3B2C4f22Ee086B2b38C1476A3cE7f78E8);

        address payable proxyAddr = payable(address(0xf5059a5D33d5853360D16C683c16e67980206f36));
        vm.startBroadcast();
        
        SafSwapV0Pair swapPool = new SafSwapV0Pair(); // 1% swap fee
        SafProxyContract poolProxy = SafProxyContract(proxyAddr);
        poolProxy.upgradeTo(address(swapPool));
        vm.stopBroadcast();

        console.log("tokenA", tokenAAddr);
        console.log("tokenB", tokenBAddr);
        console.log("upgraded SafSwapV0Pair deployed at", address(swapPool));
        console.log('-------------- bash helper script ----------');
        console.log(string.concat('export poolSwap=', addrToHexString(address(swapPool))));
        console.log('-------------- js helper script ----------');
        console.log(string.concat("export const poolSwap='", addrToHexString(address(swapPool)), "'"));
        console.log('--------------  ----------');
        console.log(string.concat("proxy (", addrToHexString(proxyAddr), ")  impl upgraded to:  ", addrToHexString(address(swapPool))));
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
