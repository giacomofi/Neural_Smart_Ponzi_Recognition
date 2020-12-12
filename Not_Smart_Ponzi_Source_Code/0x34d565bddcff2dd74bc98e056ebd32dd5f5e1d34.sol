{"Artifaqt.sol":{"content":"pragma solidity 0.4.24;\n\nimport \"./EIP721.sol\";\n\n\ncontract Artifaqt is EIP721 {\n    address public admin;\n\n    // Bool to pause transfers\n    bool transferResumed = false;\n\n    // Array holding the sin hashes\n    bytes32[] private sins;\n\n    // Mapping from token ID to token type\n    mapping(uint256 =\u003e uint256) internal typeOfToken;\n\n    // Cutoff minting time\n    uint256 cutoffMintingTime = 1541116800;\n\n    /// @notice Contract constructor\n    /// @dev Generates the keccak256 hashes of each sin that will be used\n    /// when claiming tokens. Saves the admin. Sets a name and symbol.\n    constructor() public {\n        // Limbo\n        sins.push(keccak256(\"Those who were never baptised.\"));\n        // Lust\n        sins.push(keccak256(\"Those who gave into pleasure.\"));\n        // Gluttony\n        sins.push(keccak256(\"Those who indulged in excess.\"));\n        // Avarice\n        sins.push(keccak256(\"Those who hoard and spend wastefully.\"));\n        // Wrath\n        sins.push(keccak256(\"Those consumed by anger and hatred.\"));\n        // Heresy\n        sins.push(keccak256(\"Those who worshipped false idols.\"));\n        // Violence\n        sins.push(keccak256(\"Those violent against others, one’s self, and God.\"));\n        // Fraud\n        sins.push(keccak256(\"Those who used lies and deception for personal gain.\"));\n        // Treachery\n        sins.push(keccak256(\"Those who have betrayed their loved ones.\"));\n\n        // Set owner\n        admin = msg.sender;\n\n        // Default name and symbol\n        name = \"Artifaqt\";\n        symbol = \"ATQ\";\n    }\n\n    /// @notice Claim tokens by providing the sin payload\n    /// @dev Reverts unless the payload was correctly created. Reverts after the party is over and no more tokens should be created.\n    /// @param _sinPayload = keccak256(keccak256(sin) + playerAddress)\n    /// sin must be one of strings hashed in the constructor that the player will find scattered across the DevCon4 conference\n    function claimToken(\n        bytes32 _sinPayload\n    ) external mintingAllowed {\n        // Make sure it\u0027s the correct sin\n        uint256 tokenType;\n        bool found = false;\n        for(uint256 i = 0; i \u003c 9; i++) {\n            if (_sinPayload == keccak256(abi.encodePacked(sins[i], msg.sender))) {\n                tokenType = i;\n                found = true;\n                break;\n            }\n        }\n        require(found == true);\n\n        // Make sure the user does not have this type of token\n        require(ownerHasTokenType(msg.sender, tokenType) == false);\n\n        // Create and add token\n        uint256 tokenId = totalSupply();\n        addToken(msg.sender, tokenId, tokenType);\n\n        // Emit create event\n        emit Transfer(0x0, msg.sender, tokenId);\n    }\n\n    /// @notice The admin can generate tokens for players\n    /// @dev Reverts unless the user already has the token type. Reverts unless the minting happens withing the minting allowed time period.\n    /// @param _to The player\u0027s address\n    /// @param _tokenType A number from 0 to 8 representing the sin type\n    function mintToken(\n        address _to,\n        uint256 _tokenType\n    ) external onlyAdmin mintingAllowed {\n        // Create and add token\n        uint256 tokenId = totalSupply();\n        addToken(_to, tokenId, _tokenType);\n\n        // Emit create event\n        emit Transfer(0x0, _to, tokenId);\n    }\n\n    /// @notice Returns the token id, owner and type\n    /// @dev Throws unless _tokenId exists\n    /// @param _tokenId The token by id\n    /// @return\n    /// - token index\n    /// - owner of token\n    /// - type of token\n    function getToken(\n        uint256 _tokenId\n    ) external view returns (uint256, address, uint256) {\n        return (\n            allTokensIndex[_tokenId],\n            ownerOfToken[_tokenId],\n            typeOfToken[_tokenId]\n        );\n    }\n\n    /// @notice Returns the claimed tokens for player\n    /// @dev Returns an empty array if player does not have any claimed tokens\n    /// @param _player The player\u0027s address\n    function getTokenTypes(\n        address _player\n    ) external view returns (uint256[]) {\n        uint256[] memory claimedTokens = new uint256[](ownedTokens[_player].length);\n\n        for (uint256 i = 0; i \u003c ownedTokens[_player].length; i++) {\n            claimedTokens[i] = typeOfToken[ownedTokens[_player][i]];\n        }\n\n        return claimedTokens;\n    }\n\n    // TODO: Do not allow any kind of transfers if transfer is paused\n    /// @notice Transfers the ownership of a token\n    /// @dev Calls the parent function if transfers are not paused\n    /// @param _from The current owner of the NFT\n    /// @param _to The new owner\n    /// @param _tokenId The NFT to transfer\n    /// @param data Additional data with no specified format, sent in call to `_to`\n    function safeTransferFrom(\n        address _from, \n        address _to, \n        uint256 _tokenId, \n        bytes data\n    ) public payable transferAllowed {\n        super.safeTransferFrom(_from, _to, _tokenId, data);\n    }\n\n    /// @notice Transfers the ownership of an NFT from one address to another address\n    /// @dev Calls the parent function if transfers are not paused\n    /// @param _from The current owner of the NFT\n    /// @param _to The new owner\n    /// @param _tokenId The NFT to transfer\n    function safeTransferFrom(\n        address _from, \n        address _to, \n        uint256 _tokenId\n    ) public payable transferAllowed {\n        super.safeTransferFrom(_from, _to, _tokenId);\n    }\n\n    /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE\n    ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE\n    ///  THEY MAY BE PERMANENTLY LOST\n    /// @dev Calls the parent function if transfers are not paused\n    /// @param _from The current owner of the NFT\n    /// @param _to The new owner\n    /// @param _tokenId The NFT to transfer\n    function transferFrom(\n        address _from, \n        address _to, \n        uint256 _tokenId\n    ) public payable transferAllowed {\n        super.transferFrom(_from, _to, _tokenId);\n    }\n\n    /// @notice Enables or disables transfers\n    /// @dev Set to `true` to enable transfers or `false` to disable transfers. \n    /// If it is set to `false` all functions that transfer tokens are paused and will revert.\n    /// Functions that approve transfers (`approve()` and `setTransferForAll()`) still work \n    /// because they do not transfer tokens immediately.\n    /// @param _resume This should be set to `true` if transfers should be enabled, `false` otherwise\n    function allowTransfer(bool _resume) public onlyAdmin {\n        transferResumed = _resume;\n    }\n\n    /// @notice Returns true of the `_player` has the requested `_tokenType`\n    /// @dev\n    /// @param _player The player\u0027s address\n    /// @param _tokenType A number from 0 to 8 representing the sin type\n    function ownerHasTokenType(\n        address _player,\n        uint256 _tokenType\n    ) internal view returns (bool) {\n        for (uint256 i = 0; i \u003c ownedTokens[_player].length; i++) {\n            if (typeOfToken[ownedTokens[_player][i]] == _tokenType) {\n                return true;\n            }\n        }\n        return false;\n    }\n\n    /// @notice Adds a token for the player\n    /// @dev Calls the `super.addToken(address _to, uint256 _tokenId)` method and\n    /// saves the token type also. The `_tokenId` must not already exist.\n    /// @param _to The player\u0027s address\n    /// @param _tokenId The new token id\n    /// @param _tokenType A number from 0 to 8 representing the sin type\n    function addToken(\n        address _to,\n        uint256 _tokenId,\n        uint256 _tokenType\n    ) internal {\n        super.addToken(_to, _tokenId);\n\n        // Save token type\n        typeOfToken[_tokenId] = _tokenType;\n    }\n\n    modifier onlyAdmin() {\n        require(msg.sender == admin);\n        _;\n    }\n\n    modifier mintingAllowed() {\n        require(block.timestamp \u003c= cutoffMintingTime);\n        _;\n    }\n\n    modifier transferAllowed() {\n        require(transferResumed);\n        _;\n    }\n}"},"EIP721.sol":{"content":"pragma solidity ^0.4.24;\nimport \"./EIP721Interface.sol\";\nimport \"./EIP721MetadataInterface.sol\";\nimport \"./EIP721EnumerableInterface.sol\";\nimport \"./EIP721TokenReceiverInterface.sol\";\n\n/*\nThis is a full implementation of all ERC721\u0027s features.\nInfluenced by OpenZeppelin\u0027s implementation with some stylistic changes.\nhttps://github.com/OpenZeppelin/zeppelin-solidity/tree/master/contracts/token/ERC721\n*/\n\ncontract EIP721 is EIP721Interface, EIP721MetadataInterface, EIP721EnumerableInterface, ERC165Interface {\n    string public name;\n    string public symbol;\n\n    // all tokens\n    uint256[] internal allTokens;\n    // mapping of token IDs to its index in all Tokens array.\n    mapping(uint256 =\u003e uint256) internal allTokensIndex;\n    // Array of tokens owned by a specific owner\n    mapping(address =\u003e uint256[]) internal ownedTokens;\n    // Mapping from token ID to owner\n    mapping(uint256 =\u003e address) internal ownerOfToken;\n    // Mapping of the token ID to where it is in the owner\u0027s array.\n    mapping(uint256 =\u003e uint256) internal ownedTokensIndex;\n\n    // Mapping of a token to a specifically approved owner.\n    mapping(uint256 =\u003e address) internal approvedOwnerOfToken;\n\n    // An operator is allowed to manage all assets of another owner.\n    mapping(address =\u003e mapping (address =\u003e bool)) internal operators;\n\n    mapping(uint256 =\u003e string) internal tokenURIs;\n\n    bytes4 internal constant ERC721_BASE_INTERFACE_SIGNATURE = 0x80ac58cd;\n    bytes4 internal constant ERC721_METADATA_INTERFACE_SIGNATURE = 0x5b5e139f;\n    bytes4 internal constant ERC721_ENUMERABLE_INTERFACE_SIGNATURE = 0x780e9d63;\n    bytes4 internal constant ONERC721RECEIVED_FUNCTION_SIGNATURE = 0x150b7a02;\n\n    /* Modifiers */\n    modifier tokenExists(uint256 _tokenId) {\n        require(ownerOfToken[_tokenId] != 0);\n        _;\n    }\n\n    // checks: is the owner of the token == msg.sender?\n    // OR has the owner of the token granted msg.sender access to operate?\n    modifier allowedToOperate(uint256 _tokenId) {\n        require(checkIfAllowedToOperate(_tokenId));\n        _;\n    }\n\n    modifier allowedToTransfer(address _from, address _to, uint256 _tokenId) {\n        require(checkIfAllowedToOperate(_tokenId) || approvedOwnerOfToken[_tokenId] == msg.sender);\n        require(ownerOfToken[_tokenId] == _from);\n        require(_to != 0); //not allowed to burn in transfer method\n        _;\n    }\n\n    /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE\n    ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE\n    ///  THEY MAY BE PERMANENTLY LOST\n    /// @dev Throws unless `msg.sender` is the current owner, an authorized\n    ///  operator, or the approved address for this NFT. Throws if `_from` is\n    ///  not the current owner. Throws if `_to` is the zero address. Throws if\n    ///  `_tokenId` is not a valid NFT.\n    /// @param _from The current owner of the NFT\n    /// @param _to The new owner\n    /// @param _tokenId The NFT to transfer\n    function transferFrom(address _from, address _to, uint256 _tokenId) public payable\n    tokenExists(_tokenId)\n    allowedToTransfer(_from, _to, _tokenId) {\n        //transfer token\n        settleTransfer(_from, _to, _tokenId);\n    }\n\n    /// @notice Transfers the ownership of an NFT from one address to another address\n    /// @dev Throws unless `msg.sender` is the current owner, an authorized\n    ///  operator, or the approved address for this NFT. Throws if `_from` is\n    ///  not the current owner. Throws if `_to` is the zero address. Throws if\n    ///  `_tokenId` is not a valid NFT. When transfer is complete, this function\n    ///  checks if `_to` is a smart contract (code size \u003e 0). If so, it calls\n    ///  `onERC721Received` on `_to` and throws if the return value is not\n    ///  `bytes4(keccak256(\"onERC721Received(address,address,uint256,bytes)\"))`.\n    /// @param _from The current owner of the NFT\n    /// @param _to The new owner\n    /// @param _tokenId The NFT to transfer\n    /// @param data Additional data with no specified format, sent in call to `_to`\n    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) public payable\n    tokenExists(_tokenId)\n    allowedToTransfer(_from, _to, _tokenId) {\n        settleTransfer(_from, _to, _tokenId);\n\n        // check if a smart contract\n        uint256 size;\n        assembly { size := extcodesize(_to) }  // solhint-disable-line no-inline-assembly\n        if (size \u003e 0) {\n            // call on onERC721Received.\n            require(EIP721TokenReceiverInterface(_to).onERC721Received(msg.sender, _from, _tokenId, data) == ONERC721RECEIVED_FUNCTION_SIGNATURE);\n        }\n    }\n\n    /// @notice Transfers the ownership of an NFT from one address to another address\n    /// @dev This works identically to the other function with an extra data parameter,\n    ///  except this function just sets data to \"\"\n    /// @param _from The current owner of the NFT\n    /// @param _to The new owner\n    /// @param _tokenId The NFT to transfer\n    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public payable\n    tokenExists(_tokenId)\n    allowedToTransfer(_from, _to, _tokenId) {\n        settleTransfer(_from, _to, _tokenId);\n\n        // check if a smart contract\n        uint256 size;\n        assembly { size := extcodesize(_to) }  // solhint-disable-line no-inline-assembly\n        if (size \u003e 0) {\n            // call on onERC721Received.\n            require(EIP721TokenReceiverInterface(_to).onERC721Received(msg.sender, _from, _tokenId, \"\") == ONERC721RECEIVED_FUNCTION_SIGNATURE);\n        }\n    }\n\n    /// @notice Change or reaffirm the approved address for an NFT.\n    /// @dev The zero address indicates there is no approved address.\n    ///  Throws unless `msg.sender` is the current NFT owner, or an authorized\n    ///  operator of the current owner.\n    /// @param _approved The new approved NFT controller\n    /// @param _tokenId The NFT to approve\n    function approve(address _approved, uint256 _tokenId) external payable\n    tokenExists(_tokenId)\n    allowedToOperate(_tokenId) {\n        address owner = ownerOfToken[_tokenId];\n        internalApprove(owner, _approved, _tokenId);\n    }\n\n    /// @notice Enable or disable approval for a third party (\"operator\") to manage\n    ///  all of `msg.sender`\u0027s assets.\n    /// @dev Emits the ApprovalForAll event. The contract MUST allow\n    ///  multiple operators per owner.\n    /// @param _operator Address to add to the set of authorized operators.\n    /// @param _approved True if the operator is approved, false to revoke approval\n    function setApprovalForAll(address _operator, bool _approved) external {\n        require(_operator != msg.sender); // can\u0027t make oneself an operator\n        operators[msg.sender][_operator] = _approved;\n        emit ApprovalForAll(msg.sender, _operator, _approved);\n    }\n\n    /* public View Functions */\n    /// @notice Count NFTs tracked by this contract\n    /// @return A count of valid NFTs tracked by this contract, where each one of\n    ///  them has an assigned and queryable owner not equal to the zero address\n    function totalSupply() public view returns (uint256) {\n        return allTokens.length;\n    }\n\n    /// @notice Find the owner of an NFT\n    /// @param _tokenId The identifier for an NFT\n    /// @dev NFTs assigned to zero address are considered invalid, and queries\n    ///  about them do throw.\n    /// @return The address of the owner of the NFT\n    function ownerOf(uint256 _tokenId) external view\n    tokenExists(_tokenId) returns (address) {\n        return ownerOfToken[_tokenId];\n    }\n\n    /// @notice Enumerate valid NFTs\n    /// @dev Throws if `_index` \u003e= `totalSupply()`.\n    /// @param _index A counter less than `totalSupply()`\n    /// @return The token identifier for the `_index`th NFT,\n    ///  (sort order not specified)\n    function tokenByIndex(uint256 _index) external view returns (uint256) {\n        require(_index \u003c allTokens.length);\n        return allTokens[_index];\n    }\n\n    /// @notice Enumerate NFTs assigned to an owner\n    /// @dev Throws if `_index` \u003e= `balanceOf(_owner)` or if\n    ///  `_owner` is the zero address, representing invalid NFTs.\n    /// @param _owner An address where we are interested in NFTs owned by them\n    /// @param _index A counter less than `balanceOf(_owner)`\n    /// @return The token identifier for the `_index`th NFT assigned to `_owner`,\n    ///   (sort order not specified)\n    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view\n    tokenExists(_tokenId) returns (uint256 _tokenId) {\n        require(_index \u003c ownedTokens[_owner].length);\n        return ownedTokens[_owner][_index];\n    }\n\n    /// @notice Count all NFTs assigned to an owner\n    /// @dev NFTs assigned to the zero address are considered invalid, and this\n    ///  function throws for queries about the zero address.\n    /// @param _owner An address for whom to query the balance\n    /// @return The number of NFTs owned by `_owner`, possibly zero\n    function balanceOf(address _owner) external view returns (uint256) {\n        require(_owner != 0);\n        return ownedTokens[_owner].length;\n    }\n\n    /// @notice Get the approved address for a single NFT\n    /// @dev Throws if `_tokenId` is not a valid NFT\n    /// @param _tokenId The NFT to find the approved address for\n    // todo: The approved address for this NFT, or the zero address if there is none\n    function getApproved(uint256 _tokenId) external view\n    tokenExists(_tokenId) returns (address) {\n        return approvedOwnerOfToken[_tokenId];\n    }\n\n    /// @notice Query if an address is an authorized operator for another address\n    /// @param _owner The address that owns the NFTs\n    /// @param _operator The address that acts on behalf of the owner\n    /// @return True if `_operator` is an approved operator for `_owner`, false otherwise\n    function isApprovedForAll(address _owner, address _operator) external view returns (bool) {\n        return operators[_owner][_operator];\n    }\n\n    /// @notice A distinct Uniform Resource Identifier (URI) for a given asset.\n    /// @dev Throws if `_tokenId` is not a valid NFT. URIs are defined in RFC\n    ///  3986. The URI may point to a JSON file that conforms to the \"ERC721\n    ///  Metadata JSON Schema\".\n    function tokenURI(uint256 _tokenId) external view returns (string) {\n        return tokenURIs[_tokenId];\n    }\n\n    /// @notice Query if a contract implements an interface\n    /// @param interfaceID The interface identifier, as specified in ERC-165\n    /// @dev Interface identification is specified in ERC-165. This function\n    ///  uses less than 30,000 gas.\n    /// @return `true` if the contract implements `interfaceID` and\n    /// `interfaceID` is not 0xffffffff, `false` otherwise\n    function supportsInterface(bytes4 interfaceID) external view returns (bool) {\n\n        if (interfaceID == ERC721_BASE_INTERFACE_SIGNATURE ||\n        interfaceID == ERC721_METADATA_INTERFACE_SIGNATURE ||\n        interfaceID == ERC721_ENUMERABLE_INTERFACE_SIGNATURE) {\n            return true;\n        } else { return false; }\n    }\n\n    /* -- Internal Functions -- */\n    function checkIfAllowedToOperate(uint256 _tokenId) internal view returns (bool) {\n        return ownerOfToken[_tokenId] == msg.sender || operators[ownerOfToken[_tokenId]][msg.sender];\n    }\n\n    function internalApprove(address _owner, address _approved, uint256 _tokenId) internal {\n        require(_approved != _owner); //can\u0027t approve to owner to itself\n\n        // Note: the following code is equivalent to: require(getApproved(_tokenId) != 0) || _approved != 0);\n        // However: I found the following easier to read \u0026 understand.\n        if (approvedOwnerOfToken[_tokenId] == 0 \u0026\u0026 _approved == 0) {\n            revert(); // add reason for revert?\n        } else {\n            approvedOwnerOfToken[_tokenId] = _approved;\n            emit Approval(_owner, _approved, _tokenId);\n        }\n    }\n\n    function settleTransfer(address _from, address _to, uint256 _tokenId) internal {\n        //clear pending approvals if there are any\n        if (approvedOwnerOfToken[_tokenId] != 0) {\n            internalApprove(_from, 0, _tokenId);\n        }\n\n        removeToken(_from, _tokenId);\n        addToken(_to, _tokenId);\n\n        emit Transfer(_from, _to, _tokenId);\n    }\n\n    function addToken(address _to, uint256 _tokenId) internal {\n        // add new token to all tokens\n        allTokens.push(_tokenId);\n        // add new token to index of all tokens.\n        allTokensIndex[_tokenId] = allTokens.length-1;\n\n        // set token to be owned by address _to\n        ownerOfToken[_tokenId] = _to;\n        // add that token to an array keeping track of tokens owned by that address\n        ownedTokens[_to].push(_tokenId);\n        // add newly pushed to index.\n        ownedTokensIndex[_tokenId] = ownedTokens[_to].length-1;\n    }\n\n    function removeToken(address _from, uint256 _tokenId) internal {\n\n        // remove token from allTokens array.\n        uint256 allIndex = allTokensIndex[_tokenId];\n        uint256 allTokensLength = allTokens.length;\n        //1) Put last tokenID into index of tokenID to be removed.\n        allTokens[allIndex] = allTokens[allTokensLength - 1];\n        //2) Take last tokenID that has been moved to the removed token \u0026 update its new index\n        allTokensIndex[allTokens[allTokensLength-1]] = allIndex;\n        //3) delete last item (since it\u0027s now a duplicate)\n        delete allTokens[allTokensLength-1];\n        //4) reduce length of array\n        allTokens.length -= 1;\n\n        // remove token from owner array.\n        // get the index of where this token is in the owner\u0027s array\n        uint256 ownerIndex = ownedTokensIndex[_tokenId];\n        uint256 ownerLength = ownedTokens[_from].length;\n        /* Remove Token From Index */\n        //1) Put last tokenID into index of token to be removed.\n        ownedTokens[_from][ownerIndex] = ownedTokens[_from][ownerLength-1];\n        //2) Take last item that has been moved to the removed token \u0026 update its index\n        ownedTokensIndex[ownedTokens[_from][ownerLength-1]] = ownerIndex;\n        //3) delete last item (since it\u0027s now a duplicate)\n        delete ownedTokens[_from][ownerLength-1];\n        //4) reduce length of array\n        ownedTokens[_from].length -= 1;\n\n        delete ownerOfToken[_tokenId];\n    }\n}\n"},"EIP721EnumerableInterface.sol":{"content":"pragma solidity ^0.4.24;\n\n\n/// @title ERC-721 Non-Fungible Token Standard, optional enumeration extension\n/// @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md\n///  Note: the ERC-165 identifier for this interface is 0x780e9d63\ninterface EIP721EnumerableInterface {\n    /// @notice Count NFTs tracked by this contract\n    /// @return A count of valid NFTs tracked by this contract, where each one of\n    ///  them has an assigned and queryable owner not equal to the zero address\n    function totalSupply() external view returns (uint256);\n\n    /// @notice Enumerate valid NFTs\n    /// @dev Throws if `_index` \u003e= `totalSupply()`.\n    /// @param _index A counter less than `totalSupply()`\n    /// @return The token identifier for the `_index`th NFT,\n    ///  (sort order not specified)\n    function tokenByIndex(uint256 _index) external view returns (uint256);\n\n    /// @notice Enumerate NFTs assigned to an owner\n    /// @dev Throws if `_index` \u003e= `balanceOf(_owner)` or if\n    ///  `_owner` is the zero address, representing invalid NFTs.\n    /// @param _owner An address where we are interested in NFTs owned by them\n    /// @param _index A counter less than `balanceOf(_owner)`\n    /// @return The token identifier for the `_index`th NFT assigned to `_owner`,\n    ///   (sort order not specified)\n    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256 _tokenId);\n}\n"},"EIP721Interface.sol":{"content":"pragma solidity ^0.4.24;\n\n\n/// @title ERC-721 Non-Fungible Token Standard\n/// @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md\n///  Note: the ERC-165 identifier for this interface is 0x6466353c\ninterface EIP721Interface {\n\n    /// @dev This emits when ownership of any NFT changes by any mechanism.\n    ///  This event emits when NFTs are created (`from` == 0) and destroyed\n    ///  (`to` == 0). Exception: during contract creation, any number of NFTs\n    ///  may be created and assigned without emitting Transfer. At the time of\n    ///  any transfer, the approved address for that NFT (if any) is reset to none.\n    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);\n\n    /// @dev This emits when the approved address for an NFT is changed or\n    ///  reaffirmed. The zero address indicates there is no approved address.\n    ///  When a Transfer event emits, this also indicates that the approved\n    ///  address for that NFT (if any) is reset to none.\n    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);\n\n    /// @dev This emits when an operator is enabled or disabled for an owner.\n    ///  The operator can manage all NFTs of the owner.\n    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);\n\n    /// @notice Transfers the ownership of an NFT from one address to another address\n    /// @dev Throws unless `msg.sender` is the current owner, an authorized\n    ///  operator, or the approved address for this NFT. Throws if `_from` is\n    ///  not the current owner. Throws if `_to` is the zero address. Throws if\n    ///  `_tokenId` is not a valid NFT. When transfer is complete, this function\n    ///  checks if `_to` is a smart contract (code size \u003e 0). If so, it calls\n    ///  `onERC721Received` on `_to` and throws if the return value is not\n    ///  `bytes4(keccak256(\"onERC721Received(address,address,uint256,bytes)\"))`.\n    /// @param _from The current owner of the NFT\n    /// @param _to The new owner\n    /// @param _tokenId The NFT to transfer\n    /// @param data Additional data with no specified format, sent in call to `_to`\n    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) public payable;\n\n    /// @notice Transfers the ownership of an NFT from one address to another address\n    /// @dev This works identically to the other function with an extra data parameter,\n    ///  except this function just sets data to \"\"\n    /// @param _from The current owner of the NFT\n    /// @param _to The new owner\n    /// @param _tokenId The NFT to transfer\n    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public payable;\n\n    /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE\n    ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE\n    ///  THEY MAY BE PERMANENTLY LOST\n    /// @dev Throws unless `msg.sender` is the current owner, an authorized\n    ///  operator, or the approved address for this NFT. Throws if `_from` is\n    ///  not the current owner. Throws if `_to` is the zero address. Throws if\n    ///  `_tokenId` is not a valid NFT.\n    /// @param _from The current owner of the NFT\n    /// @param _to The new owner\n    /// @param _tokenId The NFT to transfer\n    function transferFrom(address _from, address _to, uint256 _tokenId) public payable;\n\n    /// @notice Change or reaffirm the approved address for an NFT.\n    /// @dev The zero address indicates there is no approved address.\n    ///  Throws unless `msg.sender` is the current NFT owner, or an authorized\n    ///  operator of the current owner.\n    /// @param _approved The new approved NFT controller\n    /// @param _tokenId The NFT to approve\n    function approve(address _approved, uint256 _tokenId) external payable;\n\n    /// @notice Enable or disable approval for a third party (\"operator\") to manage\n    ///  all of `msg.sender`\u0027s assets.\n    /// @dev Emits the ApprovalForAll event. The contract MUST allow\n    ///  multiple operators per owner.\n    /// @param _operator Address to add to the set of authorized operators.\n    /// @param _approved True if the operator is approved, false to revoke approval\n    function setApprovalForAll(address _operator, bool _approved) external;\n\n    /// @notice Get the approved address for a single NFT\n    /// @dev Throws if `_tokenId` is not a valid NFT\n    /// @param _tokenId The NFT to find the approved address for\n    /// @return The approved address for this NFT, or the zero address if there is none\n    function getApproved(uint256 _tokenId) external view returns (address);\n\n    /// @notice Query if an address is an authorized operator for another address\n    /// @param _owner The address that owns the NFTs\n    /// @param _operator The address that acts on behalf of the owner\n    /// @return True if `_operator` is an approved operator for `_owner`, false otherwise\n    function isApprovedForAll(address _owner, address _operator) external view returns (bool);\n\n    /// @notice Count all NFTs assigned to an owner\n    /// @dev NFTs assigned to the zero address are considered invalid, and this\n    ///  function throws for queries about the zero address.\n    /// @param _owner An address for whom to query the balance\n    /// @return The number of NFTs owned by `_owner`, possibly zero\n    function balanceOf(address _owner) external view returns (uint256);\n\n    /// @notice Find the owner of an NFT\n    /// @param _tokenId The identifier for an NFT\n    /// @dev NFTs assigned to zero address are considered invalid, and queries\n    ///  about them do throw.\n    /// @return The address of the owner of the NFT\n    function ownerOf(uint256 _tokenId) external view returns (address);\n\n}\n\n\ninterface ERC165Interface {\n    /// @notice Query if a contract implements an interface\n    /// @param interfaceID The interface identifier, as specified in ERC-165\n    /// @dev Interface identification is specified in ERC-165. This function\n    ///  uses less than 30,000 gas.\n    /// @return `true` if the contract implements `interfaceID` and\n    ///  `interfaceID` is not 0xffffffff, `false` otherwise\n    function supportsInterface(bytes4 interfaceID) external view returns (bool);\n}\n"},"EIP721MetadataInterface.sol":{"content":"pragma solidity ^0.4.24;\n\n\n/// @title ERC-721 Non-Fungible Token Standard, optional metadata extension\n/// @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md\n///  Note: the ERC-165 identifier for this interface is 0x5b5e139f\ninterface EIP721MetadataInterface {\n    /// @notice A descriptive name for a collection of NFTs in this contract\n    // function name() external view returns (string _name);\n\n    /// @notice An abbreviated name for NFTs in this contract\n    // function symbol() external view returns (string _symbol);\n\n    /// @notice A distinct Uniform Resource Identifier (URI) for a given asset.\n    /// @dev Throws if `_tokenId` is not a valid NFT. URIs are defined in RFC\n    ///  3986. The URI may point to a JSON file that conforms to the \"ERC721\n    ///  Metadata JSON Schema\".\n    function tokenURI(uint256 _tokenId) external view returns (string);\n}\n"},"EIP721TokenReceiverInterface.sol":{"content":"pragma solidity ^0.4.24;\n\n\n/// @dev Note: the ERC-165 identifier for this interface is 0x150b7a02.\ninterface EIP721TokenReceiverInterface {\n    /// @notice Handle the receipt of an NFT\n    /// Note: the application will get the prior owner of the token\n    ///  after a `transfer`. This function MAY throw to revert and reject the\n    ///  transfer. Return of other than the magic value MUST result in the\n    ///  transaction being reverted.\n    ///  Note: the contract address is always the message sender.\n    /// @param _operator The address which called `safeTransferFrom` function\n    /// @param _from The address which previously owned the token\n    /// @param _tokenId The NFT identifier which is being transferred\n    /// @param _data Additional data with no specified format\n    /// @return `bytes4(keccak256(\"onERC721Received(address,address,uint256,bytes)\"))`\n    ///  unless throwing\n    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data) external returns(bytes4);\n}\n"}}