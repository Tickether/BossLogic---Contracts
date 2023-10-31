// SPDX-License-Identifier: MIT
// Code by @0xGeeLoko

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ERC721A.sol";
import "./ERC2981ContractWideRoyalties.sol";

contract DrOppenheimer is ERC721A, Ownable, ERC2981ContractWideRoyalties {
    using Strings for uint256;

    
    string public baseTokenUri;

    constructor() ERC721A("DrOppenheimer", "DrOppenheimer") {}

    mapping(address => uint256) public drops;

    modifier isOverTotal (uint256[] calldata _amount) {
        uint256 totalAmount;
        for (uint256 i; i < _amount.length; ) {
            totalAmount += _amount[i];
            unchecked {
                i++;
            }
        }
        require(totalSupply() + totalAmount <= 10000, "max supply hit");
        _;
    }

    function isDroppable (address[] calldata _to)
        internal
        view
        returns (bool)
    {
        for (uint256 i; i < _to.length; ) {
            require(drops[_to[i]] == 0, "one or more wallets already droped"); 
            unchecked {
                i++;
            }
        }
        return true;
    }

    function mintMany(address[] calldata _to, uint256[] calldata _amount) 
        external 
        onlyOwner
        isOverTotal(_amount)
    {
        require(_to.length == _amount.length, "address/amount lenght mismatch");
            if (isDroppable(_to)) {
                for (uint256 i; i < _to.length; ) {
                _mint(_to[i], _amount[i]);
                drops[_to[i]] += _amount[i];
                unchecked {
                    i++;
                }
            }
        } 
    }

    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        require(_exists(_tokenId), "ERC721Metadata: URI query for nonexistent token");
        return string(abi.encodePacked(baseTokenUri, _tokenId.toString(), ".json"));
    }

    function setBaseTokenUri(string calldata baseTokenUri_) external onlyOwner {
        baseTokenUri = baseTokenUri_;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenUri;
    }

    /// @inheritdoc	ERC165
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721A, ERC2981Base) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function setRoyalties(address recipient, uint256 value) public onlyOwner {
        _setRoyalties(recipient, value);
    }
}