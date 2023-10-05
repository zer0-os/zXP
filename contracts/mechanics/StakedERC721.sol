pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Wrapper.sol";
import "../interfaces/IStakedERC721.sol";

contract StakedERC721 is ERC721Wrapper, IStakedERC721 {
    constructor(IERC721 underlyingToken, string memory name, string memory symbol) 
    ERC721(name, symbol)
    ERC721Wrapper(underlyingToken){
    }
}