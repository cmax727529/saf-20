// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "../lib/forge-std/src/Script.sol";
import {ERC20} from "../src/erc20-tokens/erc20token.sol";
import {SafToken} from "../src/erc20-tokens/SafToken.sol";


contract TokenFactoryScript is Script {
    ERC20 public safdToken;
    ERC20 public safwToken;
    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        // safdToken = new SafToken("SafDToken", "safD", 4, 3_000_000_00); //already deployed
        safdToken = 0x98Ef35d155BE8315fE034aF067A22D4013742Fe2;
        // safwToken = new SafToken("SafWToken", "safW", 2, 1_000_000_00); //already deployed
        safwToken = 0xBE092AB6b4743C193e53204Eb1E169BDB0B804Ff;
        
        TokenSwap tokenSwap = new TokenSwap(address(safdToken), address(safwToken));

        vm.stopBroadcast();
    }
}
