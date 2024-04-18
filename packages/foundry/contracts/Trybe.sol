// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./Base64.sol";

contract Trybe is ERC1155, Ownable, ERC1155Burnable, ERC1155Supply {
    using Strings for uint256;

    mapping(uint256 => Word) private wordsToTokenId;
    uint private fee = 0.05 ether;

    struct Word {
        string text;
        string tribe;
        uint256 bgHue;
        uint256 textHue;
    }

    constructor(
        address initialOwner
    ) ERC1155(unicode"Tribe 🔥") Ownable(initialOwner) {
        mint(unicode"🔥", unicode"🔥");
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function randomHue(uint8 _salt) private view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.number,
                        false,
                        totalSupply(),
                        false,
                        _salt
                    )
                )
            ) % 361;
    }

    function changeTribes(uint256 _tokenId, uint256 newTribe) public {
        require(exists(newTribe), "Target Tribe not found");
        require(balanceOf(msg.sender, _tokenId) >= 1);
        _burn(msg.sender, _tokenId, 1);
        _mint(msg.sender, newTribe, 1, "");
    }

    function mint(string memory _userText, string memory tribe) public payable {
        require(bytes(_userText).length <= 120, "Text is too long");
        require(bytes(tribe).length <= 30, "Tribe is too long");

        if (msg.sender != owner()) {
            require(
                msg.value >= fee,
                string(
                    abi.encodePacked("Missing fee of ", fee.toString(), " wei")
                )
            );
        }

        uint256 newSupply = totalSupply() + 1;

        Word memory newWord = Word(
            _userText,
            tribe,
            randomHue(1),
            randomHue(2)
        );

        wordsToTokenId[newSupply] = newWord;

        _mint(msg.sender, newSupply, 1, "");
    }

    function tribeName(uint256 _tokenId) public view returns (string memory) {
        require(
            exists(_tokenId),
            "ERC1155Metadata: URI query for nonexistent token"
        );
        return string(wordsToTokenId[_tokenId].tribe);
    }

    function mintNew(uint256 _tokenId) public payable {
        require(
            exists(_tokenId),
            "ERC1155Metadata: URI query for nonexistent token"
        );
        if (msg.sender != owner()) {
            require(
                msg.value >= fee,
                string(
                    abi.encodePacked("Missing fee of ", fee.toString(), " wei")
                )
            );
        }
        _mint(msg.sender, _tokenId, 1, "");
    }

    function buildImage(
        string memory _userText,
        string memory tribe,
        uint256 _bgHue,
        uint256 _textHue,
        uint256 pop
    ) private pure returns (bytes memory) {
        return
            Base64.encode(
                abi.encodePacked(
                    '<svg viewBox="0 0 250 250" xmlns="http://www.w3.org/2000/svg">'
                    '<rect height="100%" width="100%" y="0" x="0" fill="hsl(',
                    _bgHue.toString(),
                    ',50%,25%)"/>'
                    '<text y="50%" x="50%" text-anchor="middle" dy=".3em" fill="hsl(',
                    _textHue.toString(),
                    ',100%,80%)">',
                    _userText,
                    "</text>"
                    '<text y="90%" x="50%" text-anchor="middle" dy=".1em" fill="hsl(',
                    _textHue.toString(),
                    ',100%,80%)">',
                    "tribe ",
                    tribe,
                    "population: ",
                    pop.toString(),
                    "</text>"
                    "</svg>"
                )
            );
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public onlyOwner {
        _mintBatch(to, ids, amounts, data);
    }

    function getFee() public view returns (uint) {
        return fee;
    }

    function setFee(uint _newFee) public onlyOwner {
        fee = _newFee;
    }

    function withdraw() public payable onlyOwner {
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success);
    }

    // The following functions are overrides required by Solidity.

    function _update(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values
    ) internal override(ERC1155, ERC1155Supply) {
        super._update(from, to, ids, values);
    }
}
