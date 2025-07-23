// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
 * @title MonolithicTokenFactory
 * @notice Deploys ERC20, ERC721 and ERC1155 tokens while mirroring all
 *         balances into a single ERC1155 contract. Tokens created through
 *         the factory receive unique 1155 ids so transfers stay synchronized
 *         across standards.
 */
contract MonolithicTokenFactory is ERC1155 {
    uint256 public nextId;
    mapping(uint256 => address) public tokenAddress;

    uint256 private constant _SHIFT = 128;

    event ERC20Deployed(uint256 indexed id, address token);
    event ERC721Deployed(uint256 indexed id, address token);
    event ERC1155Deployed(uint256 indexed id, address token);

    constructor(string memory uri) ERC1155(uri) {}

    /**
     * @dev Deploy a new ERC20 token. The created token will share its supply
     *      with an ERC1155 id so that balances can be tracked through either
     *      interface.
     * @param name   ERC20 name.
     * @param symbol ERC20 symbol.
     * @param initialSupply Initial amount minted to the caller.
     */
    function deployERC20(
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) external returns (uint256 id, address token) {
        id = ++nextId;
        ERC20Wrapper newToken = new ERC20Wrapper(
            name,
            symbol,
            address(this),
            id,
            msg.sender,
            initialSupply
        );
        tokenAddress[id] = address(newToken);
        emit ERC20Deployed(id, address(newToken));
        return (id, address(newToken));
    }

    function deployERC721(
        string memory name,
        string memory symbol
    ) external returns (uint256 id, address token) {
        id = ++nextId;
        ERC721Wrapper newToken = new ERC721Wrapper(
            name,
            symbol,
            address(this),
            id
        );
        tokenAddress[id] = address(newToken);
        emit ERC721Deployed(id, address(newToken));
        return (id, address(newToken));
    }

    function deployERC1155(string memory uri_)
        external
        returns (uint256 id, address token)
    {
        id = ++nextId;
        ERC1155Wrapper newToken = new ERC1155Wrapper(uri_, address(this), id);
        tokenAddress[id] = address(newToken);
        emit ERC1155Deployed(id, address(newToken));
        return (id, address(newToken));
    }

    /**
     * @dev Called by wrapper tokens to keep the ERC1155 balances in sync.
     *      Mint, burn or transfer depending on the addresses involved.
     */
    function syncERC20Transfer(
        uint256 id,
        address from,
        address to,
        uint256 amount
    ) external {
        require(tokenAddress[id] == msg.sender, "factory: unknown token");
        if (from == address(0)) {
            _mint(to, id, amount, "");
        } else if (to == address(0)) {
            _burn(from, id, amount);
        } else {
            _safeTransferFrom(from, to, id, amount, "");
        }
    }

    function syncERC721Transfer(
        uint256 baseId,
        uint256 tokenId,
        address from,
        address to
    ) external {
        require(tokenAddress[baseId] == msg.sender, "factory: unknown token");
        uint256 id1155 = (baseId << _SHIFT) | tokenId;
        if (from == address(0)) {
            _mint(to, id1155, 1, "");
        } else if (to == address(0)) {
            _burn(from, id1155, 1);
        } else {
            _safeTransferFrom(from, to, id1155, 1, "");
        }
    }

    function syncERC1155Transfer(
        uint256 baseId,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts
    ) external {
        require(tokenAddress[baseId] == msg.sender, "factory: unknown token");
        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id1155 = (baseId << _SHIFT) | ids[i];
            uint256 amount = amounts[i];
            if (from == address(0)) {
                _mint(to, id1155, amount, "");
            } else if (to == address(0)) {
                _burn(from, id1155, amount);
            } else {
                _safeTransferFrom(from, to, id1155, amount, "");
            }
        }
    }
}

/**
 * @dev ERC20 token whose transfers update the factory so balances are mirrored
 *      as ERC1155 tokens.
 */
contract ERC20Wrapper is ERC20 {
    MonolithicTokenFactory public immutable factory;
    uint256 public immutable id;

    constructor(
        string memory name,
        string memory symbol,
        address factory_,
        uint256 id_,
        address initialHolder,
        uint256 initialSupply
    ) ERC20(name, symbol) {
        factory = MonolithicTokenFactory(factory_);
        id = id_;
        _mint(initialHolder, initialSupply);
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        factory.syncERC20Transfer(id, from, to, amount);
    }
}

contract ERC721Wrapper is ERC721 {
    MonolithicTokenFactory public immutable factory;
    uint256 public immutable id;
    uint256 private _tokenCount;

    constructor(
        string memory name,
        string memory symbol,
        address factory_,
        uint256 id_
    ) ERC721(name, symbol) {
        factory = MonolithicTokenFactory(factory_);
        id = id_;
    }

    function mint(address to) external returns (uint256 tokenId) {
        tokenId = ++_tokenCount;
        _safeMint(to, tokenId);
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal override {
        factory.syncERC721Transfer(id, firstTokenId, from, to);
    }
}

contract ERC1155Wrapper is ERC1155 {
    MonolithicTokenFactory public immutable factory;
    uint256 public immutable id;

    constructor(
        string memory uri_,
        address factory_,
        uint256 id_
    ) ERC1155(uri_) {
        factory = MonolithicTokenFactory(factory_);
        id = id_;
    }

    function mint(
        address to,
        uint256 tokenId,
        uint256 amount
    ) external {
        _mint(to, tokenId, amount, "");
    }

    function burn(
        address from,
        uint256 tokenId,
        uint256 amount
    ) external {
        _burn(from, tokenId, amount);
    }

    function _afterTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override {
        factory.syncERC1155Transfer(id, from, to, ids, amounts);
    }
}

