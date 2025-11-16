// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title PokeAgent
 * @dev ERC721 NFT contract for PokéAgents
 * Deploy to Base Sepolia testnet or Base mainnet
 */
contract PokeAgent is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    // Minting fee (0.001 ETH)
    uint256 public mintFee = 0.001 ether;

    // Maximum supply
    uint256 public constant MAX_SUPPLY = 10000;

    // Agent metadata
    struct AgentMetadata {
        string name;
        string agentType;
        uint256 xp;
        uint8 evolutionStage;
        uint256 mintedAt;
    }

    mapping(uint256 => AgentMetadata) public agentData;

    event AgentMinted(
        uint256 indexed tokenId,
        address indexed owner,
        string name,
        string agentType
    );

    event AgentEvolved(
        uint256 indexed tokenId,
        uint8 newStage,
        uint256 newXP
    );

    constructor() ERC721("PokeAgent", "POKE") Ownable(msg.sender) {}

    /**
     * @dev Mint a new PokéAgent NFT
     * @param to Address to mint to
     * @param name Agent name
     * @param agentType Agent type (Fire, Water, etc.)
     * @param tokenURI IPFS URI for metadata
     */
    function mint(
        address to,
        string memory name,
        string memory agentType,
        string memory tokenURI
    ) public payable returns (uint256) {
        require(_tokenIdCounter.current() < MAX_SUPPLY, "Max supply reached");
        require(msg.value >= mintFee, "Insufficient mint fee");

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();

        _safeMint(to, tokenId);
        _setTokenURI(tokenId, tokenURI);

        agentData[tokenId] = AgentMetadata({
            name: name,
            agentType: agentType,
            xp: 0,
            evolutionStage: 1,
            mintedAt: block.timestamp
        });

        emit AgentMinted(tokenId, to, name, agentType);

        return tokenId;
    }

    /**
     * @dev Update agent XP and evolution stage
     * @param tokenId Token ID
     * @param newXP New XP value
     * @param newStage New evolution stage
     */
    function updateAgent(
        uint256 tokenId,
        uint256 newXP,
        uint8 newStage
    ) public {
        require(ownerOf(tokenId) == msg.sender, "Not token owner");
        require(newStage <= 3, "Invalid evolution stage");

        agentData[tokenId].xp = newXP;
        agentData[tokenId].evolutionStage = newStage;

        emit AgentEvolved(tokenId, newStage, newXP);
    }

    /**
     * @dev Get agent metadata
     */
    function getAgent(uint256 tokenId)
        public
        view
        returns (AgentMetadata memory)
    {
        require(_exists(tokenId), "Token does not exist");
        return agentData[tokenId];
    }

    /**
     * @dev Get all token IDs owned by an address
     */
    function tokensOfOwner(address owner)
        public
        view
        returns (uint256[] memory)
    {
        uint256 balance = balanceOf(owner);
        uint256[] memory tokens = new uint256[](balance);
        uint256 index = 0;

        for (uint256 i = 0; i < _tokenIdCounter.current(); i++) {
            if (_exists(i) && ownerOf(i) == owner) {
                tokens[index] = i;
                index++;
            }
        }

        return tokens;
    }

    /**
     * @dev Update mint fee (owner only)
     */
    function setMintFee(uint256 newFee) public onlyOwner {
        mintFee = newFee;
    }

    /**
     * @dev Withdraw contract balance (owner only)
     */
    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
    }

    /**
     * @dev Check if token exists
     */
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }

    /**
     * @dev Get total supply
     */
    function totalSupply() public view returns (uint256) {
        return _tokenIdCounter.current();
    }
}
