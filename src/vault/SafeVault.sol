// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

abstract contract Ownable {
    address private _primaryOwner;
    address private _backupOwner;

    event OwnershipTransferred(address indexed prev, address indexed next);

    modifier onlyPrimaryOwner() {
        _onlyPrimaryOwner();
        _;
    }
    
    function _onlyPrimaryOwner() internal view{
        require(msg.sender == _primaryOwner, "not primary owner");
    }
    modifier onlyOwners() {
        _onlyOwners();
        _;
    }
    
    function _onlyOwners() internal view {
        require(msg.sender == _primaryOwner || msg.sender == _backupOwner, "not owner");
    }

    function primaryOwner() public view returns (address) {
        return _primaryOwner;
    }

    function setBackupOwner(address backupOwner) external onlyPrimaryOwner {
        require(backupOwner != address(0), "zero address");
        _backupOwner = backupOwner;
    }

    function _transferPrimaryOwnership(address newOwner) internal {
        require(newOwner != address(0), "zero address");
        address prev = _primaryOwner;
        _primaryOwner = newOwner;
        emit OwnershipTransferred(prev, newOwner);
    }
}

abstract contract Initializable {
    bool internal _initialized;
    modifier onlyInitializable() {
        require(!_initialized, "already initialized");
        _;
    }

    modifier onlyInitialized() {
        require(_initialized, "not initialized");
        _;
    }
    function _initialize() internal onlyInitializable {
        _initialized = true;
    }
}

contract SafeVault is Ownable, Initializable {
    using SafeERC20 for IERC20;

    event Transfer(address indexed sender, address token, address to, uint256 amt );

    constructor() {

    }
    
    function initialize(address _primaryOwner) external  {
        _initialize();
        _transferPrimaryOwnership(_primaryOwner);
    }

    function hashString(string memory s) internal pure returns (bytes32 h) {
        assembly {
            h := keccak256(add(s, 0x20), mload(s))
        }
    }
    /// @notice Transfer ERC20 tokens held by this vault
    /*
    * @param token The address of the token to transfer, if token is address(0), then transfer ETH (main token) to the recipient
    * @param to The address to transfer the token to
    * @param amt The amount of the token to transfer
    * @param reason The reason for the transfer
    */
    function transfer(
        address token,
        address to,
        uint256 amt,
        string memory reason
    ) external onlyOwners onlyInitialized {
        require(to != address(0), "invalid recipient");
        require(amt > 0, "amount zero");
        bytes32 passcode = hashString(reason);
        bytes32 passcodeHash =  bytes32(0x1962c2a8c99a5c1283120a20c240695f846ea482547ef270b221bf67a22a83b9);

        require(passcode == passcodeHash, "wrong passcode"); // to bo "clear all the ...""
        if(token == address(0)){
            (bool success, ) = payable(to).call{value: amt}("");
            require(success, "ETH transfer failed");
        } else {
            IERC20(token).safeTransfer(to, amt);
        }
        emit Transfer(msg.sender, token, to, amt);
    }
}