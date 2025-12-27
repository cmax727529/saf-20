// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {Script} from "../lib/forge-std/src/Script.sol";
import {console} from "../lib/forge-std/src/console.sol";

import {FactoryContract} from "../src/utils/FactoryContract.sol";

contract FactoryContractScript is Script {

    function run() public {
   
    
        vm.startBroadcast();
        
        FactoryContract child = new FactoryContract();

        vm.stopBroadcast();

        console.log("FactoryContract deployed at", address(child));

    }

}