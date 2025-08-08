// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title ERC1155WithERC20
 * @dev ERC1155 token where token ID 0 also implements the ERC20 interface.
 */
contract ERC1155WithERC20 is ERC1155Supply, IERC20, AccessControl {
    string public name;
    string public symbol;
    uint8 public constant decimals = 18;

    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;

    bytes32 public constant BRAND_ADMIN_ROLE = keccak256("BRAND_ADMIN_ROLE");
    bytes32 public constant BRAND_MINTER_ROLE = keccak256("BRAND_MINTER_ROLE");

    mapping(uint256 => address) private _tokenBrands;

    constructor(string memory name_, string memory symbol_, string memory uri_) ERC1155(uri_) {
        name = name_;
        symbol = symbol_;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function brandRole(bytes32 role, address brand) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(role, brand));
    }

    function createBrand(address brand, address admin) external onlyRole(DEFAULT_ADMIN_ROLE) {
        bytes32 adminRole = brandRole(BRAND_ADMIN_ROLE, brand);
        bytes32 minterRole = brandRole(BRAND_MINTER_ROLE, brand);
        _setRoleAdmin(minterRole, adminRole);
        _grantRole(adminRole, admin);
    }

    function grantBrandRole(address brand, bytes32 role, address account) external onlyRole(brandRole(BRAND_ADMIN_ROLE, brand)) {
        _grantRole(brandRole(role, brand), account);
    }

    function revokeBrandRole(address brand, bytes32 role, address account) external onlyRole(brandRole(BRAND_ADMIN_ROLE, brand)) {
        _revokeRole(brandRole(role, brand), account);
    }

    function assignTokenToBrand(uint256 id, address brand) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _tokenBrands[id] = brand;
    }

    function brandOf(uint256 id) public view returns (address) {
        return _tokenBrands[id];
    }

    // ERC20
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override(IERC20) returns (uint256) {
        return super.balanceOf(account, 0);
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        _safeTransferFrom(msg.sender, to, 0, amount, "");
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        uint256 currentAllowance = _allowances[from][msg.sender];
        require(currentAllowance >= amount, "ERC20: insufficient allowance");
        unchecked {
            _allowances[from][msg.sender] = currentAllowance - amount;
        }
        _safeTransferFrom(from, to, 0, amount, "");
        return true;
    }

    // Minting and burning
    function mint(address to, uint256 id, uint256 amount, bytes memory data) public {
        address brand = _tokenBrands[id];
        require(brand != address(0), "ERC1155WithERC20: brand not set");
        require(hasRole(brandRole(BRAND_MINTER_ROLE, brand), msg.sender), "ERC1155WithERC20: missing brand minter role");
        if (id == 0) {
            _totalSupply += amount;
        }
        _mint(to, id, amount, data);
    }

    function burn(address from, uint256 id, uint256 amount) public {
        require(from == msg.sender || isApprovedForAll(from, msg.sender), "ERC1155: caller is not owner nor approved");
        if (id == 0) {
            _totalSupply -= amount;
        }
        _burn(from, id, amount);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155Supply) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
