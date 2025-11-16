// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "../lib/forge-std/src/Script.sol";
import {ERC20} from "../src/erc20-tokens/erc20token.sol";
import {SafToken} from "../src/erc20-tokens/saf-token.sol";


contract TokenFactoryScript is Script {
    ERC20 public safdToken;
    ERC20 public safwToken;
    function setUp() public {}

    function run() public {
        
        vm.startBroadcast();

        safdToken = new SafToken("SafDToken", "safD", 4, 3_000_000_00); //already deployed
        
        safwToken = new SafToken("SafWToken", "safW", 2, 1_000_000_00); //already deployed
        
        
        

        vm.stopBroadcast();
    }
}
