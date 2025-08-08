// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title ERC1155WithERC20
 * @dev ERC1155 token where token ID 0 also implements the ERC20 interface.
 */
contract ERC1155WithERC20 is ERC1155Supply, IERC20 {
    string public name;
    string public symbol;
    uint8 public constant decimals = 18;

    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;

    constructor(string memory name_, string memory symbol_, string memory uri_) ERC1155(uri_) {
        name = name_;
        symbol = symbol_;
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
}
