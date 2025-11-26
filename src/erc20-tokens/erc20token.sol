// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {IERC20} from "../erc20-interface/erc20interface.sol";

contract ERC20 is IERC20 {
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    
    string internal _name;
    string internal _symbol;
    uint8 internal _decimals;
    address internal _contractOwner;

    constructor(string memory name_, string memory symbol_, uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _contractOwner = msg.sender;
    }

    // Explicit implementations of metadata functions for ERC20 compliance
    function name() external view virtual returns (string memory) {
        return _name;
        // return "ERC20";
    }

    function symbol() external  view virtual returns (string memory) {
        return _symbol;
        // return "eth";
    }

    function decimals() external  view virtual returns (uint8) {
        return _decimals;
        // return 18;
    }

    function changeOwner(address newOwner) external {
        require(msg.sender == _contractOwner, "Not authorized");
        _contractOwner = newOwner;
    }

    

    function transfer(address recipient, uint256 amount)
        external
        returns (bool)
    {
        address owner = msg.sender;
        _transfer(owner, recipient, amount);
        
        return true;
    }

    // spender can only spend up to the amount approved, spender is usually pool contract address
    function approve(address spender, uint256 amount) external returns (bool) {
        require(spender != address(0), "invalid spender")
        
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    
    function transferFrom(address sender, address recipient, uint256 amount)
        external
        returns (bool)
    {
        address spender = msg.sender;
        _spendAllowance(sender, spender, amount);
        _transfer(sender, recipient, amount);
        return true;
    }

    function _spendAllowance(address owner, address spender, uint256 amount) internal {
        if (owner == spender) {
            return;// always approved
        }
        uint256 currentAllowance = allowance[owner][spender];
        if (currentAllowance < type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                allowance[owner][spender] = currentAllowance - amount;
            }
        }
        // else : unlimited allowance {}
    }

    
    function _transfer(address from, address to, uint256 amount) internal {
        if(from == address(0)) {
            revert ("Invalid sender address");
        } 

        if ( to == address(0)) {
            revert ("Invalid recipient address");
        }

        _updateState(from, to, amount);
    }

    function _updateState(address from, address to, uint256 amount) internal {
        if (amount == 0) {
            revert ("unnecessary transfer");
        }

        if (from == address(0)) {
            // this is mint process
            totalSupply += amount;
        }else{
            uint256 fromBalance = balanceOf[from];
            if ( fromBalance < amount) {
                revert ("Insufficient balance");
            }
            unchecked {
                balanceOf[from] -= amount;
            }
        }


        if (to == address(0)) {
            // this is burn process
            unchecked {
                totalSupply -= amount;
            }
        }else{
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);
    }


    // permission less functions, can be used from derived contracts

    function _mint(address to, uint256 amount) internal {
        if(to == address(0)) {
            revert ("Invalid recipient address");
        }
        // require(msg.sender == _owner, "Not authorized");
        _updateState(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal {
        if(from == address(0)) {
            revert ("Invalid sender address");
        }
        require(balanceOf[from] >= amount, "Insufficient balance");
        // require(msg.sender == _owner || msg.sender == from, "Not authorized");
        _updateState(from, address(0), amount);
    }


    // mint-burn functions are disabled here
    function mint(address to, uint256 amount) virtual external returns (bool) {
        // revert ("Not implemented");
        // require(msg.sender == _contractOwner, "Not authorized");
        // _mint(to, amount);
        return true;
    }

    function burn(address from, uint256 amount) virtual external returns (bool) {
        // revert ("Not implemented");
        return true;
    }


    fallback() external payable {
        
    }

    receive() external payable {
        // accept ETH
        
    }
   
}