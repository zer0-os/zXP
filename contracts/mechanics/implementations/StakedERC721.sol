pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "../interfaces/IStakedERC721.sol";

contract StakedERC721 is IStakedERC721, ERC721URIStorage, IERC721Receiver {
    error NotStaker(address player, uint256 tokenId, address stakedBy);
    error Unstaking(uint256 tokenId, uint256 unstakeTime);
    error Locked(uint256 tokenId, uint256 lockTime);
    error NotAuthorized(address caller);

    /// NFT Contract address
    IERC721 public nftContractAddress;

    /// Admin
    address public admin;

    /// Contract that is allowed to transfer staked tokens
    address public controller;

    /// Mapping from tokenId to holder address
    mapping(uint256 tokenId => address staker) public stakedBy;

    constructor(
        string memory tokenName,
        string memory tokenSymbol,
        address _admin,
        IERC721 _nftContractAddress
    ) ERC721(tokenName, tokenSymbol) {
        admin = _admin;
        nftContractAddress = _nftContractAddress;
    }

    modifier _isStakerOrOperator(address stakerOperator, uint256 tokenId) {
        if (!isStakerOrOperator(stakerOperator, tokenId)) {
            revert NotStaker(stakerOperator, tokenId, stakedBy[tokenId]);
        }
        _;
    }

    modifier onlyAdmin(address a) {
        if (a != admin) {
            revert NotAuthorized(msg.sender);
        }
        _;
    }

    modifier onlyController(address c) {
        if (c != controller) {
            revert NotAuthorized(msg.sender);
        }
        _;
    }
    /**
     * @dev Transfers the token back to the stakedBy address.
     *
     * Requirements:
     * - There must be an unstakeRequest
     * - The current time must be after the delay
     *
     * After successful execution:
     * - The stakedBy state is deleted
     * - The unstakeRequest time is deleted
     * - The staked wheel token is burned
     */
    function unstake(
        uint256 tokenId
    ) public override _isStakerOrOperator(msg.sender, tokenId) {
        delete stakedBy[tokenId];
        _burn(tokenId);
        nftContractAddress.safeTransferFrom(address(this), msg.sender, tokenId);
    }

    function setController(address newController) public override onlyAdmin(msg.sender) {
        require(newController != address(0), "WR: missing newController");
        controller = newController;
    }

    ///Ability to return NFTs mistakenly sent with transferFrom instead of safeTransferFrom
    function transferOut(
        address to,
        uint256 tokenId
    ) public override onlyAdmin(msg.sender) {
        require(stakedBy[tokenId] == address(0));
        nftContractAddress.safeTransferFrom(address(this), to, tokenId);
    }

    /**
     * @dev Fails if the transferred token is not from nftContractAddress.
     *      On successful receive it stakes the Wheel,
     *      mints the StakedERC721 token to the transferer,
     *      and sets the token URI of the StakedERC721 to the same as the Wheel.
     *
     *      Operators can transfer in, but the StakedERC721 token goes to the token owner.
     * @param from The players EOA
     * @param tokenId  The nft token
     */
    function onERC721Received(
        address,
        address from,
        uint256 tokenId,
        bytes calldata
    ) public override returns (bytes4) {
        require(msg.sender == address(nftContractAddress), "Sent unsupported NFT");
        stakedBy[tokenId] = from;

        IERC721Metadata token = IERC721Metadata(msg.sender);

        string memory incomingTokenURI = token.tokenURI(tokenId);

        _mint(from, tokenId);
        _setTokenURI(tokenId, incomingTokenURI);

        return this.onERC721Received.selector;
    }

    function isStakerOrOperator(
        address stakerOperator,
        uint256 tokenId
    ) public view override returns (bool) {
        if (
            stakedBy[tokenId] == stakerOperator ||
            nftContractAddress.getApproved(tokenId) == stakerOperator
        ) {
            return true;
        }
        return false;
    }

    /// Overriding transfer function, token is soulbound
    function transferFrom(
        address from,
        address to,
        uint256 id
    ) public override onlyController(msg.sender) {
        _transfer(from, to, id);
    }

    /// Overriding transfer function, token is soulbound
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes memory data
    ) public override onlyController(msg.sender) {
        _safeTransfer(from, to, id, data);
    }

    function _transfer(
        address from,
        address to,
        uint256 id
    ) internal virtual override {
        stakedBy[id] = to;
        super._transfer(from, to, id);
    }
}