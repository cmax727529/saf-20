// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract SafProxyContract{
    // Storage slots (constant)
    bytes32 internal constant IMPLEMENTATION_SLOT = keccak256("saf.proxy.implementation");
    bytes32 internal constant ADMIN_SLOT = keccak256("saf.proxy.admin");
    
    // Constructor: set implementation and owner
    constructor(address _implementation, address _admin, bytes memory initData) {
        require(_admin != address(0), "Invalid admin");
        _setImplementation(_implementation);
         
         if (initData.length > 0 && _implementation != address(0)) {
            (bool success, ) = _implementation.delegatecall(initData);
            // require(success, "init failed");
        }
        _setAdmin(_admin);
    }

    // Events
    event Upgraded(address indexed newImplementation);
    event AdminChanged(address indexed previousAdmin, address indexed newAdmin);

    // Modifier
    modifier onlyProxyAdmin() {
        _onlyProxyAdmin();
        _;
    }
    function _onlyProxyAdmin() internal view{
        require(msg.sender == _getAdmin(), "SafProxy: not admin");
    }


    // Upgrade
    function upgradeImplTo(address _newImplementation) external onlyProxyAdmin {
        // require(_newImplementation != address(0), "Zero address"); // zero allowed to unset implementation for a while
        _setImplementation(_newImplementation);
        emit Upgraded(_newImplementation);
    }

    // Ownership transfer
    function transferProxyAdmin(address _newAdmin) external onlyProxyAdmin {
        require(_newAdmin != address(0), "Zero address");
        emit AdminChanged(_getAdmin(), _newAdmin);
        _setAdmin(_newAdmin);
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

    function _getAdmin() internal view returns (address _admin) {
        bytes32 slot = ADMIN_SLOT;
        assembly { _admin := sload(slot) }
    }

    function _setAdmin(address _admin) internal {
        bytes32 slot = ADMIN_SLOT;
        assembly { sstore(slot, _admin) }
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