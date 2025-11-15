// SPDX-License-Identifier: OPEN-SOURCE

pragma solidity ^0.8.26;

interface IERC20 {
    //========= event functions =========
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    //========= token functions =========
    function totalSupply() external view returns (uint256);
    
    function balanceOf(address account) external view returns (uint256);
    
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
    
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);
    
    function approve(address spender, uint256 amount) external returns (bool);
    
    function transferFrom(address sender, address recipient, uint256 amount)
        external
        returns (bool);

    //========= metadata functions =========
    function name() external view returns (string memory);
    
    function symbol() external view returns (string memory);
    
    function decimals() external view returns (uint8);

}