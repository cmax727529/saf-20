// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {SafToken} from "../erc20-tokens/saf-token.sol";

contract FactoryContract{
    constructor(){}

    event ContractDeployed(address addr);
    function deploy() external returns (address) {
        SafToken child =  new SafToken("SafToken", "saf", 4, 2_0000000_0000);
        emit ContractDeployed(address(child));
        return address(child);
    }

    function deploy(string memory tokenName) external returns (address) {
        SafToken child =  new SafToken(tokenName, "saf", 4, 2_0000000_0000);
        emit ContractDeployed(address(child));
        return address(child);
    }

}
