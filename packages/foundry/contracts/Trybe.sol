// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./Base64.sol";

contract Trybe is
    ERC1155,
    Ownable,
    ERC1155Burnable,
    ERC1155Supply,
    ERC1155URIStorage
{
    event NewTrybe(uint256 indexed tokenId, string indexed tribe);

    enum Options {
        LOW,
        MEDIUM,
        HIGH
    }

    struct Stats {
        uint pop_mod;
        string resources;
        string technology;
    }

    struct Trybes {
        string name;
        uint256 bgHue;
        uint256 textHue;
        Stats stats;
    }
    using Strings for uint256;

    mapping(uint256 => Trybes) private wordsToTokenId;
    uint private fee = 0.05 ether;

    constructor(
        address initialOwner
    ) ERC1155(unicode"Trybe 🔥") Ownable(initialOwner) {
        mint(unicode"🔥");
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function randomHue(
        uint8 _salt,
        uint _spread
    ) private view returns (uint256) {
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
            ) % _spread;
    }

    function changeTribes(uint256 _tokenId, uint256 newTribe) public {
        require(exists(newTribe), "Target Tribe not found");
        require(balanceOf(msg.sender, _tokenId) >= 1);
        _burn(msg.sender, _tokenId, 1);
        _mint(msg.sender, newTribe, 1, "");
    }

    function mint(string memory tribe) public payable {
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

        Stats memory newStats = Stats(
            randomHue(1, 42),
            returnState(randomHue(2, 3)),
            returnState(randomHue(3, 3))
        );

        Trybes memory newTrybe = Trybes(
            tribe,
            randomHue(1, 361),
            randomHue(2, 361),
            newStats
        );

        wordsToTokenId[newSupply] = newTrybe;

        _mint(msg.sender, newSupply, 1, "");
        emit NewTrybe(newSupply, tribe);
    }

    function tribeStats(
        uint256 _tokenId
    ) public view returns (string[4] memory) {
        require(
            exists(_tokenId),
            "ERC1155Metadata: URI query for nonexistent token"
        );

        string[4] memory _stats;
        Trybes memory tokenWord = wordsToTokenId[_tokenId];
        _stats[0] = tokenWord.name;
        _stats[1] = tokenWord.bgHue.toString();
        _stats[2] = tokenWord.textHue.toString();
        _stats[3] = string(
            abi.encodePacked(
                "Trybe: ",
                tokenWord.name,
                "Pop: ",
                (tokenWord.stats.pop_mod * totalSupply(_tokenId)).toString(),
                " Resources: ",
                tokenWord.stats.resources,
                " Technology: ",
                tokenWord.stats.technology
            )
        );
        return _stats;
    }

    function isMember(
        address account,
        uint256 _tokenId
    ) external view returns (bool) {
        return balanceOf(account, _tokenId) > 0;
    }

    function returnState(uint _id) public pure returns (string memory) {
        if (Options(_id) == Options.LOW) return "Low";
        if (Options(_id) == Options.MEDIUM) return "Medium";
        if (Options(_id) == Options.HIGH) return "High";
        return "";
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
        string memory _tribe,
        uint256 _bgHue,
        uint256 _textHue
    ) private pure returns (bytes memory) {
        return
            Base64.encode(
                abi.encodePacked(
                    '<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">'
                    '<rect height="100%" width="100%" y="0" x="0" fill="hsl(',
                    _bgHue.toString(),
                    ',50%,25%)"/>'
                    '<text y="50%" x="50%" text-anchor="middle" dy=".1em" fill="hsl(',
                    _textHue.toString(),
                    ',100%,80%)">',
                    _tribe,
                    "</text>"
                    "</svg>"
                )
            );
    }

    function uri(
        uint256 _tokenId
    )
        public
        view
        virtual
        override(ERC1155, ERC1155URIStorage)
        returns (string memory)
    {
        require(
            exists(_tokenId),
            "ERC1155Metadata: URI query for nonexistent token"
        );

        Trybes memory tokenWord = wordsToTokenId[_tokenId];
        return
            string(
                bytes.concat(
                    "data:application/json;base64,",
                    Base64.encode(
                        abi.encodePacked(
                            "{"
                            '"name":"',
                            tokenWord.name,
                            '",'
                            '"description":"\'',
                            bytes(tokenWord.name),
                            "' Trybe by Nerds\","
                            '"image":"data:image/svg+xml;base64,',
                            buildImage(
                                tribeStats(_tokenId)[3],
                                tokenWord.bgHue,
                                tokenWord.textHue
                            ),
                            '"'
                            "}"
                        )
                    )
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
