// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "../lib/forge-std/src/Script.sol";
import {console} from "../lib/forge-std/src/console.sol";

import {SafeVault} from "../src/valut/SafeVault.sol";

interface ISingletonFactory {
    function deploy(bytes memory _initCode, bytes32 _salt) external returns (address);
}

contract DeployVaultScript is Script {
    function run() public {
        // address SingletonFactory = 0x5FbDB2315678afecb367f032d93F642f64180aa3; // anvil
        address singletonFactoryAddress = address(0xce0042B868300000d44A59004Da54A005ffdcf9f); // production
        address mySafeGlobal = address(0x0b4537fefd706b04CF13d7BD4ac2EC5eF56b2077); // my safe.global

        ISingletonFactory singletonFactory = ISingletonFactory(singletonFactoryAddress);
        
        vm.startBroadcast();

        bytes32 salt = keccak256(abi.encodePacked("saf"));
        bytes memory bytecode = type(SafeVault).creationCode;
        address vault = singletonFactory.deploy(bytecode, salt);
        
        // address vault = address(0xdde9024CfC27a7FA43be2fAFC483355c439286d9);
        // SafeVault(vault).initialize{gas: 8000000}(owner);
        SafeVault(vault).initialize(mySafeGlobal);
        
        vm.stopBroadcast();
        console.log("Vault deployed at", vault);
        //calculated address = 0xdde9024CfC27a7FA43be2fAFC483355c439286d9
    }
}