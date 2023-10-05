// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC721, IERC721, ERC721Wrapper} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Wrapper.sol";
import {IStakedERC721} from "./interfaces/IStakedERC721.sol";

contract StakedERC721 is ERC721Wrapper, IStakedERC721 {
    constructor(
        IERC721 underlyingToken,
        string memory name,
        string memory symbol
    ) ERC721(name, symbol) ERC721Wrapper(underlyingToken) {}
}
