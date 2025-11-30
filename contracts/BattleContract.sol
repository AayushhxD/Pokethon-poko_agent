// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title BattleContract
 * @dev Main battle contract for PokéAgents 3D Battle System
 * @notice Handles on-chain battle registration, result submission, and reward claiming
 */
contract BattleContract is Ownable, ReentrancyGuard {
    // Structs
    struct Battle {
        uint256 battleId;
        address player;
        uint256 playerTokenId;
        address opponent;
        uint256 opponentTokenId;
        uint256 stakeAmount;
        uint256 winnerTokenId;
        bytes32 resultHash;
        BattleStatus status;
        uint256 timestamp;
        uint256 nonce;
    }

    enum BattleStatus {
        Pending,
        Matched,
        Completed,
        Claimed
    }

    // State Variables
    mapping(uint256 => Battle) public battles;
    mapping(address => uint256) public playerNonces;
    mapping(uint256 => bool) public battleExists;
    
    address public serverAddress; // Authorized signer
    IERC20 public stakeToken;
    uint256 public totalBattles;

    // Events
    event BattleRegistered(
        uint256 indexed battleId,
        address indexed player,
        uint256 playerTokenId,
        uint256 stakeAmount,
        uint256 timestamp
    );

    event BattleMatched(
        uint256 indexed battleId,
        address indexed opponent,
        uint256 opponentTokenId,
        uint256 timestamp
    );

    event ResultSubmitted(
        uint256 indexed battleId,
        uint256 winnerTokenId,
        bytes32 resultHash,
        uint256 timestamp
    );

    event RewardClaimed(
        uint256 indexed battleId,
        address indexed winner,
        uint256 amount,
        uint256 timestamp
    );

    // Modifiers
    modifier onlyValidBattle(uint256 _battleId) {
        require(battleExists[_battleId], "Battle does not exist");
        _;
    }

    modifier onlyBattleParticipant(uint256 _battleId) {
        Battle storage battle = battles[_battleId];
        require(
            msg.sender == battle.player || msg.sender == battle.opponent,
            "Not a participant"
        );
        _;
    }

    constructor(address _stakeToken, address _serverAddress) {
        stakeToken = IERC20(_stakeToken);
        serverAddress = _serverAddress;
    }

    /**
     * @notice Register a new battle on-chain
     * @param _battleId Unique battle identifier
     * @param _playerTokenId Player's NFT token ID
     * @param _stakeAmount Amount to stake (in tokens)
     */
    function registerBattle(
        uint256 _battleId,
        uint256 _playerTokenId,
        uint256 _stakeAmount
    ) external nonReentrant {
        require(!battleExists[_battleId], "Battle already registered");
        require(_playerTokenId > 0, "Invalid token ID");

        // Transfer stake if required
        if (_stakeAmount > 0) {
            require(
                stakeToken.transferFrom(msg.sender, address(this), _stakeAmount),
                "Stake transfer failed"
            );
        }

        // Create battle record
        battles[_battleId] = Battle({
            battleId: _battleId,
            player: msg.sender,
            playerTokenId: _playerTokenId,
            opponent: address(0),
            opponentTokenId: 0,
            stakeAmount: _stakeAmount,
            winnerTokenId: 0,
            resultHash: bytes32(0),
            status: BattleStatus.Pending,
            timestamp: block.timestamp,
            nonce: playerNonces[msg.sender]++
        });

        battleExists[_battleId] = true;
        totalBattles++;

        emit BattleRegistered(
            _battleId,
            msg.sender,
            _playerTokenId,
            _stakeAmount,
            block.timestamp
        );
    }

    /**
     * @notice Match battle with opponent (off-chain matchmaking)
     * @param _battleId Battle ID to match
     * @param _opponent Opponent address
     * @param _opponentTokenId Opponent's NFT token ID
     */
    function matchBattle(
        uint256 _battleId,
        address _opponent,
        uint256 _opponentTokenId
    ) external onlyOwner onlyValidBattle(_battleId) {
        Battle storage battle = battles[_battleId];
        require(battle.status == BattleStatus.Pending, "Battle already matched");
        require(_opponent != address(0), "Invalid opponent");
        require(_opponentTokenId > 0, "Invalid opponent token ID");

        battle.opponent = _opponent;
        battle.opponentTokenId = _opponentTokenId;
        battle.status = BattleStatus.Matched;

        emit BattleMatched(_battleId, _opponent, _opponentTokenId, block.timestamp);
    }

    /**
     * @notice Submit off-chain battle result with server signature
     * @param _battleId Battle ID
     * @param _winnerTokenId Winner's token ID
     * @param _resultHash Hash of battle result
     * @param _signature Server signature
     */
    function submitOffchainResult(
        uint256 _battleId,
        uint256 _winnerTokenId,
        bytes32 _resultHash,
        bytes memory _signature
    ) external onlyValidBattle(_battleId) onlyBattleParticipant(_battleId) nonReentrant {
        Battle storage battle = battles[_battleId];
        require(battle.status == BattleStatus.Matched, "Battle not matched");
        require(_winnerTokenId > 0, "Invalid winner token ID");

        // Verify server signature
        require(
            _verifySignature(_resultHash, _signature),
            "Invalid server signature"
        );

        // Verify winner is a participant
        require(
            _winnerTokenId == battle.playerTokenId ||
                _winnerTokenId == battle.opponentTokenId,
            "Winner not a participant"
        );

        // Update battle
        battle.winnerTokenId = _winnerTokenId;
        battle.resultHash = _resultHash;
        battle.status = BattleStatus.Completed;

        emit ResultSubmitted(_battleId, _winnerTokenId, _resultHash, block.timestamp);
    }

    /**
     * @notice Claim reward after battle completion
     * @param _battleId Battle ID
     */
    function claimReward(uint256 _battleId)
        external
        onlyValidBattle(_battleId)
        nonReentrant
    {
        Battle storage battle = battles[_battleId];
        require(battle.status == BattleStatus.Completed, "Battle not completed");
        require(battle.stakeAmount > 0, "No stake to claim");

        // Determine winner address
        address winner;
        if (battle.winnerTokenId == battle.playerTokenId) {
            winner = battle.player;
        } else if (battle.winnerTokenId == battle.opponentTokenId) {
            winner = battle.opponent;
        } else {
            revert("Invalid winner");
        }

        require(msg.sender == winner, "Only winner can claim");

        // Calculate reward (2x stake)
        uint256 reward = battle.stakeAmount * 2;
        
        // Update status
        battle.status = BattleStatus.Claimed;

        // Transfer reward
        require(
            stakeToken.transfer(winner, reward),
            "Reward transfer failed"
        );

        emit RewardClaimed(_battleId, winner, reward, block.timestamp);
    }

    /**
     * @notice Verify server signature
     * @param _hash Message hash
     * @param _signature Signature bytes
     */
    function _verifySignature(bytes32 _hash, bytes memory _signature)
        private
        view
        returns (bool)
    {
        bytes32 ethSignedHash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash)
        );
        
        (bytes32 r, bytes32 s, uint8 v) = _splitSignature(_signature);
        address recovered = ecrecover(ethSignedHash, v, r, s);
        
        return recovered == serverAddress;
    }

    /**
     * @notice Split signature into r, s, v
     */
    function _splitSignature(bytes memory _sig)
        private
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(_sig.length == 65, "Invalid signature length");

        assembly {
            r := mload(add(_sig, 32))
            s := mload(add(_sig, 64))
            v := byte(0, mload(add(_sig, 96)))
        }
    }

    /**
     * @notice Update server address (governance)
     * @param _newServerAddress New server address
     */
    function updateServerAddress(address _newServerAddress) external onlyOwner {
        require(_newServerAddress != address(0), "Invalid address");
        serverAddress = _newServerAddress;
    }

    /**
     * @notice Get battle details
     * @param _battleId Battle ID
     */
    function getBattle(uint256 _battleId)
        external
        view
        onlyValidBattle(_battleId)
        returns (Battle memory)
    {
        return battles[_battleId];
    }

    /**
     * @notice Check if battle is claimable
     * @param _battleId Battle ID
     */
    function isClaimable(uint256 _battleId)
        external
        view
        onlyValidBattle(_battleId)
        returns (bool)
    {
        Battle storage battle = battles[_battleId];
        return battle.status == BattleStatus.Completed && battle.stakeAmount > 0;
    }

    /**
     * @notice Emergency withdraw (only owner)
     */
    function emergencyWithdraw(address _token, uint256 _amount)
        external
        onlyOwner
    {
        require(_amount > 0, "Invalid amount");
        require(IERC20(_token).transfer(owner(), _amount), "Transfer failed");
    }
}
