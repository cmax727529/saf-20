// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "../lib/forge-std/src/Test.sol";
import {SafToken} from "../src/erc20-tokens/saf-token.sol";

contract CounterTest is Test {
    SafToken public safToken;

    function setUp() public {
        vm.startBroadcast();
        safToken = new SafToken("SafToken", "saf", 18, 1000000000000000000);
        vm.stopBroadcast();

    }

    function test_Increment() public {
        
        assertEq(safToken.name(), "SafToken");
        assertEq(safToken.symbol(), "saf");
        assertEq(safToken.decimals(), 18);
        assertEq(safToken.totalSupply(), 1000000000000000000);
    }

    function testFuzz_SetNumber(uint256 x) public {
        assertEq(safToken.totalSupply(), x);
    }
}
