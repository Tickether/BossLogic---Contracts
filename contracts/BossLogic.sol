// SPDX-License-Identifier: MIT
// Code by @0xGeeLoko

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ERC721A.sol";
import "./ERC2981ContractWideRoyalties.sol";

contract BossLogic is ERC721A, Ownable, ERC2981ContractWideRoyalties {
    using Strings for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private supply;
    
    string public baseTokenUri = "";
    string public uriSuffix = ".json";
    //string public hiddenMetadataUri;

    bool public revealed = false;
    constructor() ERC721A("Boss Logic", "BLU") {}

    function mint(address receiver, uint256 amount) public onlyOwner {
        for (uint256 i; i < amount; ) {
            _mint(receiver, amount);

            unchecked {
                i++;
            }
        }
    }

    function mintMany(address[] calldata _to, uint256[] calldata _amount) external onlyOwner {
        for (uint256 i; i < _to.length; ) {
            _mint(_to[i], _amount[i]);

            unchecked {
                i++;
            }
        }
    }

    function walletOfOwner(address _owner) public view returns (uint256[] memory) {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory ownedTokenIds = new uint256[](ownerTokenCount);
        uint256 currentTokenId = 1;
        uint256 ownedTokenIndex = 0;

        while (ownedTokenIndex < ownerTokenCount && currentTokenId <= totalSupply()) {
            address currentTokenOwner = ownerOf(currentTokenId);

            if (currentTokenOwner == _owner) {
                ownedTokenIds[ownedTokenIndex] = currentTokenId;

                ownedTokenIndex++;
            }

            currentTokenId++;
        }

        return ownedTokenIds;
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