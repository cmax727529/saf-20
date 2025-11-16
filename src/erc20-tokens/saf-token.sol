// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;
import {ERC20} from "./erc20token.sol";

import {IERC165} from "../utils/erc165interface.sol";
import {IERC20} from "../erc20-interface/erc20interface.sol";

contract SafToken is ERC20, IERC165 {
    constructor(string memory name_, string memory symbol_, uint8 decimals_, uint256 mintAmount) ERC20(name_, symbol_, decimals_) {
        _mint(msg.sender, mintAmount);
    }

    function supportsInterface(bytes4 interfaceId) public pure override returns (bool) {
        // Return true for ERC165 itself
        if (interfaceId == type(IERC165).interfaceId) {
            return true;
        }
        // Return true for ERC20 interface (optional)
        if (interfaceId == type(IERC20).interfaceId) {
            return true;
        }
        return false;
    }

    // mint possible
    function mint(address to, uint256 amount) external override returns (bool) {
        require(msg.sender == _contractOwner, "Not authorized");
        _mint(to, amount);
        return true;
    }

    // burn possible
    function burn(address from, uint256 amount) external override returns (bool) {
        _burn(from, amount);
        return true;
    }
}
