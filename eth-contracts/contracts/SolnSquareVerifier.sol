pragma solidity >=0.4.21 <0.6.0;

import "./ERC721MintableComplete.sol";

contract SolnSquareVerifier is ERC721MintableComplete {
    Verifier private verifierContract;

    struct Solution {
        uint256 solIndex;
        address solAddress;
        bool minted;
    }

    uint256 solutionNum = 0;
    mapping(bytes32 => Solution) solutions;

    event SolutionAdded(uint256 solIndex, address indexed solAddress);

    constructor(address verifierAddress) ERC721MintableComplete() public {
        verifierContract = Verifier(verifierAddress);
    }

    function addSolution(
        uint[2] memory A,
        uint[2] memory A_p,
        uint[2][2] memory B,
        uint[2] memory B_p,
        uint[2] memory C,
        uint[2] memory C_p,
        uint[2] memory H,
        uint[2] memory K,
        uint[2] memory input
    ) 
        public 
    {
        bytes32 solutionHash = keccak256(abi.encodePacked(input[0], input[1]));
        require(solutions[solutionHash].solAddress == address(0), "Solution exists already");
        
        bool verified = verifierContract.verifyTx(A, A_p, B, B_p, C, C_p, H, K, input);
        require(verified, "Solution could not be verified");

        solutions[solutionHash] = Solution(solutionNum, msg.sender, false);
        emit SolutionAdded(solutionNum, msg.sender);
        solutionNum++;
    }

    function mintNewNFT(uint a, uint b, address to) public
    {
        bytes32 solutionHash = keccak256(abi.encodePacked(a, b));
        require(solutions[solutionHash].solAddress != address(0), "Solution does not exist");
        require(solutions[solutionHash].minted == false, "Token already minted for this solution");
        require(solutions[solutionHash].solAddress == msg.sender, "Only solution address can use it to mint a token");
        super.mint(to, solutions[solutionHash].solIndex);
        solutions[solutionHash].minted = true;
    }
}

contract Verifier {
    function verifyTx(
        uint[2] memory A,
        uint[2] memory A_p,
        uint[2][2] memory B,
        uint[2] memory B_p,
        uint[2] memory C,
        uint[2] memory C_p,
        uint[2] memory H,
        uint[2] memory K,
        uint[2] memory input
    )
    public
    returns
    (bool r);
}



























