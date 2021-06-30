// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/cryptography/MerkleProof.sol";
import "./interfaces/IMakiDistributor.sol";

contract MakiDistributor is IMakiDistributor, Ownable {
    using SafeMath for uint256;

    // MAKI TOKEN && (VERIFIABLE) MERKLE ROOT
    IERC20 public immutable override maki = IERC20(0x5FaD6fBBA4BbA686bA9B8052Cf0bd51699f38B93);
    bytes32 public immutable override merkleRoot = 0xfd714b930f3af79fe23209c290b5d4801276126e350bb2652141250ee270dddf;

    // PACKED ARRAY OF BOOLEANS
    mapping(uint256 => uint256) private claimedBitMap;

    // TIME VARIABLES
    uint256 public immutable startTime = block.timestamp;
    uint256 public immutable endTime = block.timestamp + 180 days;

    // CLAIM VIEW
    function isClaimed(uint256 index) public view override returns (bool) {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        uint256 claimedWord = claimedBitMap[claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask == mask;
    }

    function _setClaimed(uint256 index) private {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        claimedBitMap[claimedWordIndex] = claimedBitMap[claimedWordIndex] | (1 << claimedBitIndex);
    }

    function claim(uint256 index, address account, uint256 amount, bytes32[] calldata merkleProof) external override {
        require(!isClaimed(index), 'claim: already claimed.');

        // VERIFY MERKLE ROOT
        bytes32 node = keccak256(abi.encodePacked(index, account, amount));
        require(MerkleProof.verify(merkleProof, merkleRoot, node), 'claim: invalid proof.');

        // CLAIM AND SEND
        _setClaimed(index); // sets claimed
        require(block.timestamp >= startTime, '_setClaimed: too soon'); // blocks early claims
        require(block.timestamp <= endTime, '_setClaimed: too late'); // blocks late claims
        require(maki.transfer(account, amount), '_setClaimed: transfer failed'); // transfers tokens

        emit Claimed(index, account, amount);
    }

    // COLLECT UNCLAIMED TOKENS
    function collectUnclaimed(uint256 amount) public onlyOwner {
        require(block.timestamp >= endTime, 'collectUnclaimed: too soon');
        require(maki.transfer(owner(), amount), 'collectUnclaimed: transfer failed');
    }

}
