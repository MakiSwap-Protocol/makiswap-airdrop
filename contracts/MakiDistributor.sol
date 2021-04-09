// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.6.11;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/cryptography/MerkleProof.sol";
import "./interfaces/IMakiDistributor.sol";

contract MakiDistributor is IMakiDistributor {
    using SafeMath for uint256;
    address public immutable override token;
    bytes32 public immutable override merkleRoot;
    address deployer;

    // This is a packed array of booleans.
    mapping(uint256 => uint256) private claimedBitMap;

    // Time-Variables
    uint256 public immutable startTime;
    uint256 public immutable endTime;

    constructor(address token_, bytes32 merkleRoot_, uint256 startTime_, uint256 endTime_) public {
        token = token_;
        merkleRoot = merkleRoot_;
        deployer = msg.sender;
        startTime = startTime_;
        endTime = endTime_;
    }

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
        require(!isClaimed(index), 'MakiDistributor: Drop already claimed.');

        // VERIFY MERKLE ROOT
        bytes32 node = keccak256(abi.encodePacked(index, account, amount));
        require(MerkleProof.verify(merkleProof, merkleRoot, node), 'MakiDistributor: Invalid proof.');

        // CLAIM AND SEND
        _setClaimed(index); // sets claimed
        require(block.timestamp >= startTime, 'MakiDistributor: Too soon'); // blocks early claims
        require(block.timestamp <= endTime, 'MakiDistributor: Too late'); // blocks late claims
        require(IERC20(token).transfer(account, amount), 'MakiDistributor: Transfer failed.'); // transfers tokens

        emit Claimed(index, account, amount);
    }

    // REMOVE ACCIDENTAL SENDS
    function collectDust(address _token, uint256 _amount) external {
      require(msg.sender == deployer, '!deployer');
      require(_token != token, '!token');
        if (_token == address(0)) { // token address(0) = ETH
            payable(deployer).transfer(_amount);
        } else {
        IERC20(_token).transfer(deployer, _amount);
        }
    }

    // COLLECT UNCLAIMED TOKENS
    function collectUnclaimed(uint256 amount) external{
      require(msg.sender == deployer, 'MakiDistributor: not deployer');
      require(IERC20(token).transfer(deployer, amount), 'MakiDistributor: collectUnclaimed failed.');
    }

    // UPDATE DEV ADDRESS
    function dev(address _deployer) public {
        require(msg.sender == deployer, "dev: wut?");
        deployer = _deployer;
    }

}
