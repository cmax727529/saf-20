// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "../lib/forge-std/src/Script.sol";
import {console} from "../lib/forge-std/src/console.sol";

import {SafeVault} from "../src/vault/SafeVault.sol";
import {SafProxyContract} from "../src/utils/saf-proxy-contract.sol";

interface ISingletonFactory {
    function deploy(bytes memory _initCode, bytes32 _salt) external returns (address);
}

contract DeployVaultProxyScript is Script {
    function run() public {
        // address SingletonFactory = 0x5FbDB2315678afecb367f032d93F642f64180aa3; // anvil
        address singletonFactoryAddress = address(0xce0042B868300000d44A59004Da54A005ffdcf9f); // production
        address mySafeGlobal = address(0x0b4537fefd706b04CF13d7BD4ac2EC5eF56b2077); // my safe.global
        address proxyAdmin = mySafeGlobal;
        address initialVaultOwner=address(0x9C9344950d2ab1072e4DDabeB436935785508F3E);

        ISingletonFactory singletonFactory = ISingletonFactory(singletonFactoryAddress);
        
        vm.startBroadcast();
        bytes32 salt = keccak256(abi.encodePacked("safsaf"));
        
        
        bytes memory vaultCode = type(SafeVault).creationCode;
        
        // to be consistant at deploy time
        address initialVaultImpl = singletonFactory.deploy(vaultCode, salt);
        console.log("Initial Vault Impl deployed at", initialVaultImpl);
        
        bytes memory initInitialVaultImplData = abi.encodeCall(SafeVault.initialize, (initialVaultOwner));

        bytes memory proxyImplCode = type(SafProxyContract).creationCode;

        bytes memory initCodeProxy = abi.encodePacked(
            proxyImplCode,
            abi.encode(initialVaultImpl, proxyAdmin, initInitialVaultImplData)
        );
        address vaultProxy = singletonFactory.deploy(initCodeProxy, salt);
        
        
        vm.stopBroadcast();
        console.log("Vault Proxy deployed at", vaultProxy);
        //calculated address = 0xdde9024CfC27a7FA43be2fAFC483355c439286d9
    }
}