pragma solidity ^0.8.0;

interface IStakedERC721 {
    function unstake(uint256) external;
    function setController(address) external;
    function transferOut(address, uint256) external;
    function isStakerOrOperator(address, uint256) external view returns (bool);
}