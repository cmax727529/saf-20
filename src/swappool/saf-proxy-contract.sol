// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract SafProxyContract{
    // Storage slots (constant)
    bytes32 internal constant IMPLEMENTATION_SLOT = keccak256("saf.proxy.implementation");
    bytes32 internal constant OWNER_SLOT = keccak256("saf.proxy.owner");

    // Events
    event Upgraded(address indexed newImplementation);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // Modifier
    modifier onlyOwner() {
        require(msg.sender == _getOwner(), "CustomProxy: not owner");
        _;
    }

    // Constructor: set implementation and owner
    constructor(address _implementation, address _owner) {
        require(_implementation != address(0) && _owner != address(0), "Invalid addresses");
        _setImplementation(_implementation);
        _setOwner(_owner);
    }

    // Upgrade
    function upgradeTo(address _newImplementation) external onlyOwner {
        require(_newImplementation != address(0), "Zero address");
        _setImplementation(_newImplementation);
        emit Upgraded(_newImplementation);
    }

    // Ownership transfer
    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "Zero address");
        emit OwnershipTransferred(_getOwner(), _newOwner);
        _setOwner(_newOwner);
    }

    // Fallback
    fallback() external payable {
        _delegate(_getImplementation());
    }

    receive() external payable {
        _delegate(_getImplementation());
    }

    // --- Internal storage access functions ---
    function _getImplementation() internal view returns (address impl) {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly { impl := sload(slot) }
    }

    function _setImplementation(address impl) internal {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly { sstore(slot, impl) }
    }

    function _getOwner() internal view returns (address _owner) {
        bytes32 slot = OWNER_SLOT;
        assembly { _owner := sload(slot) }
    }

    function _setOwner(address _owner) internal {
        bytes32 slot = OWNER_SLOT;
        assembly { sstore(slot, _owner) }
    }

    // Delegatecall logic
    function _delegate(address _impl) internal {
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), _impl, 0, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(0, 0, size)
            switch result
            case 0 { revert(0, size) }
            default { return(0, size) }
        }
    }
}