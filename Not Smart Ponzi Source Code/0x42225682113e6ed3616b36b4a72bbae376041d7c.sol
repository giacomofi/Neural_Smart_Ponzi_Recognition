{"BetDeEx.sol":{"content":"pragma solidity ^0.5.10;\n\nimport \u0027./ESContract.sol\u0027; /// @dev also contains safeMath\n\n/// @title BetDeEx Smart Contract - The Decentralized Prediction Platform of Era Swap Ecosystem\n/// @author The EraSwap Team\n/// @notice This contract is used by manager to deploy new Bet contracts\n/// @dev This contract also acts as treasurer\ncontract BetDeEx {\n    using SafeMath for uint256;\n\n    address[] public bets; /// @dev Stores addresses of bets\n    address public superManager; /// @dev Required to be public because ES needs to be sent transaparently.\n\n    EraswapToken esTokenContract;\n\n    mapping(address =\u003e uint256) public betBalanceInExaEs; /// @dev All ES tokens are transfered to main BetDeEx address for common allowance in ERC20 so this mapping stores total ES tokens betted in each bet.\n    mapping(address =\u003e bool) public isBetValid; /// @dev Stores authentic bet contracts (only deployed through this contract)\n    mapping(address =\u003e bool) public isManager; /// @dev Stores addresses who are given manager privileges by superManager\n\n    event NewBetContract (\n        address indexed _deployer,\n        address _contractAddress,\n        uint8 indexed _category,\n        uint8 indexed _subCategory,\n        string _description\n    );\n\n    event NewBetting (\n        address indexed _betAddress,\n        address indexed _bettorAddress,\n        uint8 indexed _choice,\n        uint256 _betTokensInExaEs\n    );\n\n    event EndBetContract (\n        address indexed _ender,\n        address indexed _contractAddress,\n        uint8 _result,\n        uint256 _prizePool,\n        uint256 _platformFee\n    );\n\n    /// @dev This event is for indexing ES withdrawl transactions to winner bettors from this contract\n    event TransferES (\n        address indexed _betContract,\n        address indexed _to,\n        uint256 _tokensInExaEs\n    );\n\n    modifier onlySuperManager() {\n        require(msg.sender == superManager, \"only superManager can call\");\n        _;\n    }\n\n    modifier onlyManager() {\n        require(isManager[msg.sender], \"only manager can call\");\n        _;\n    }\n\n    modifier onlyBetContract() {\n        require(isBetValid[msg.sender], \"only bet contract can call\");\n        _;\n    }\n\n    /// @notice Sets up BetDeEx smart contract when deployed\n    /// @param _esTokenContractAddress is EraSwap contract address\n    constructor(address _esTokenContractAddress) public {\n        superManager = msg.sender;\n        isManager[msg.sender] = true;\n        esTokenContract = EraswapToken(_esTokenContractAddress);\n    }\n\n    /// @notice This function is used to deploy a new bet\n    /// @param _description is the question of Bet in plain English, bettors have to understand the bet description and later choose to bet on yes no or draw according to their preference\n    /// @param _category is the broad category for example Sports. Purpose of this is only to filter bets and show in UI, hence the name of the category is not stored in smart contract and category is repressented by a number (0, 1, 2, 3...)\n    /// @param _subCategory is a specific category for example Football. Each category will have sub categories represented by a number (0, 1, 2, 3...)\n    /// @param _minimumBetInExaEs is the least amount of ExaES that can be betted, any bet participant (bettor) will have to bet this amount or higher. Betting higher amount gives more share of winning amount\n    /// @param _prizePercentPerThousand is a form of representation of platform fee. It is a number less than or equal to 1000. For eg 2% is to be collected as platform fee then this value would be 980. If 0.2% then 998.\n    /// @param _isDrawPossible is functionality for allowing a draw option\n    /// @param _pauseTimestamp Bet will be open for betting until this timestamp, after this timestamp, any user will not be able to place bet. and manager can only end bet after this time\n    /// @return address of newly deployed bet contract. This is for UI of Admin panel.\n    function createBet(\n        string memory _description,\n        uint8 _category,\n        uint8 _subCategory,\n        uint256 _minimumBetInExaEs,\n        uint256 _prizePercentPerThousand,\n        bool _isDrawPossible,\n        uint256 _pauseTimestamp\n    ) public onlyManager returns (address) {\n        Bet _newBet = new Bet(\n          _description,\n          _category,\n          _subCategory,\n          _minimumBetInExaEs,\n          _prizePercentPerThousand,\n          _isDrawPossible,\n          _pauseTimestamp\n        );\n        bets.push(address(_newBet));\n        isBetValid[address(_newBet)] = true;\n\n        emit NewBetContract(\n          msg.sender,\n          address(_newBet),\n          _category,\n          _subCategory,\n          _description\n        );\n\n        return address(_newBet);\n    }\n\n    /// @notice this function is used for getting total number of bets\n    /// @return number of Bet contracts deployed by BetDeEx\n    function getNumberOfBets() public view returns (uint256) {\n        return bets.length;\n    }\n\n\n\n\n\n\n\n    /// @notice this is for giving access to multiple accounts to manage BetDeEx\n    /// @param _manager is address of new manager\n    function addManager(address _manager) public onlySuperManager {\n        isManager[_manager] = true;\n    }\n\n    /// @notice this is for revoking access of a manager to manage BetDeEx\n    /// @param _manager is address of manager who is to be converted into a former manager\n    function removeManager(address _manager) public onlySuperManager {\n        isManager[_manager] = false;\n    }\n\n    /// @notice this is an internal functionality that is only for bet contracts to emit a event when a new bet is placed so that front end can get the information by subscribing to  contract\n    function emitNewBettingEvent(address _bettorAddress, uint8 _choice, uint256 _betTokensInExaEs) public onlyBetContract {\n        emit NewBetting(msg.sender, _bettorAddress, _choice, _betTokensInExaEs);\n    }\n\n    /// @notice this is an internal functionality that is only for bet contracts to emit event when a bet is ended so that front end can get the information by subscribing to  contract\n    function emitEndEvent(address _ender, uint8 _result, uint256 _gasFee) public onlyBetContract {\n        emit EndBetContract(_ender, msg.sender, _result, betBalanceInExaEs[msg.sender], _gasFee);\n    }\n\n    /// @notice this is an internal functionality that is used to transfer tokens from bettor wallet to BetDeEx contract\n    function collectBettorTokens(address _from, uint256 _betTokensInExaEs) public onlyBetContract returns (bool) {\n        require(esTokenContract.transferFrom(_from, address(this), _betTokensInExaEs), \"tokens should be collected from user\");\n        betBalanceInExaEs[msg.sender] = betBalanceInExaEs[msg.sender].add(_betTokensInExaEs);\n        return true;\n    }\n\n    /// @notice this is an internal functionality that is used to transfer prizes to winners\n    function sendTokensToAddress(address _to, uint256 _tokensInExaEs) public onlyBetContract returns (bool) {\n        betBalanceInExaEs[msg.sender] = betBalanceInExaEs[msg.sender].sub(_tokensInExaEs);\n        require(esTokenContract.transfer(_to, _tokensInExaEs), \"tokens should be sent\");\n\n        emit TransferES(msg.sender, _to, _tokensInExaEs);\n        return true;\n    }\n\n    /// @notice this is an internal functionality that is used to collect platform fee\n    function collectPlatformFee(uint256 _platformFee) public onlyBetContract returns (bool) {\n        require(esTokenContract.transfer(superManager, _platformFee), \"platform fee should be collected\");\n        return true;\n    }\n\n}\n\n/// @title Bet Smart Contract\n/// @author The EraSwap Team\n/// @notice This contract is governs bettors and is deployed by BetDeEx Smart Contract\ncontract Bet {\n    using SafeMath for uint256;\n\n    BetDeEx betDeEx;\n\n    string public description; /// @dev question text of the bet\n    bool public isDrawPossible; /// @dev if false then user cannot bet on draw choice\n    uint8 public category; /// @dev sports, movies\n    uint8 public subCategory; /// @dev cricket, football\n\n    uint8 public finalResult; /// @dev given a value when manager ends bet\n    address public endedBy; /// @dev address of manager who enters the correct choice while ending the bet\n\n    uint256 public creationTimestamp; /// @dev set during bet creation\n    uint256 public pauseTimestamp; /// @dev set as an argument by deployer\n    uint256 public endTimestamp; /// @dev set when a manager ends bet and prizes are distributed\n\n    uint256 public minimumBetInExaEs; /// @dev minimum amount required to enter bet\n    uint256 public prizePercentPerThousand; /// @dev percentage of bet balance which will be dristributed to winners and rest is platform fee\n    uint256[3] public totalBetTokensInExaEsByChoice = [0, 0, 0]; /// @dev array of total bet value of no, yes, draw voters\n    uint256[3] public getNumberOfChoiceBettors = [0, 0, 0]; /// @dev stores number of bettors in a choice\n\n    uint256 public totalPrize; /// @dev this is the prize (platform fee is already excluded)\n\n    mapping(address =\u003e uint256[3]) public bettorBetAmountInExaEsByChoice; /// @dev mapps addresses to array of betAmount by choice\n    mapping(address =\u003e bool) public bettorHasClaimed; /// @dev set to true when bettor claims the prize\n\n    modifier onlyManager() {\n        require(betDeEx.isManager(msg.sender), \"only manager can call\");\n        _;\n    }\n\n    /// @notice this sets up Bet contract\n    /// @param _description is the question of Bet in plain English, bettors have to understand the bet description and later choose to bet on yes no or draw according to their preference\n    /// @param _category is the broad category for example Sports. Purpose of this is only to filter bets and show in UI, hence the name of the category is not stored in smart contract and category is repressented by a number (0, 1, 2, 3...)\n    /// @param _subCategory is a specific category for example Football. Each category will have sub categories represented by a number (0, 1, 2, 3...)\n    /// @param _minimumBetInExaEs is the least amount of ExaES that can be betted, any bet participant (bettor) will have to bet this amount or higher. Betting higher amount gives more share of winning amount\n    /// @param _prizePercentPerThousand is a form of representation of platform fee. It is a number less than or equal to 1000. For eg 2% is to be collected as platform fee then this value would be 980. If 0.2% then 998.\n    /// @param _isDrawPossible is functionality for allowing a draw option\n    /// @param _pauseTimestamp Bet will be open for betting until this timestamp, after this timestamp, any user will not be able to place bet. and manager can only end bet after this time\n    constructor(string memory _description, uint8 _category, uint8 _subCategory, uint256 _minimumBetInExaEs, uint256 _prizePercentPerThousand, bool _isDrawPossible, uint256 _pauseTimestamp) public {\n        description = _description;\n        isDrawPossible = _isDrawPossible;\n        category = _category;\n        subCategory = _subCategory;\n        minimumBetInExaEs = _minimumBetInExaEs;\n        prizePercentPerThousand = _prizePercentPerThousand;\n        betDeEx = BetDeEx(msg.sender);\n        creationTimestamp = now;\n        pauseTimestamp = _pauseTimestamp;\n    }\n\n    /// @notice this function gives amount of ExaEs that is total betted on this bet\n    function betBalanceInExaEs() public view returns (uint256) {\n        return betDeEx.betBalanceInExaEs(address(this));\n    }\n\n    /// @notice this function is used to place a bet on available choice\n    /// @param _choice should be 0, 1, 2; no =\u003e 0, yes =\u003e 1, draw =\u003e 2\n    /// @param _betTokensInExaEs is amount of bet\n    function enterBet(uint8 _choice, uint256 _betTokensInExaEs) public {\n        require(now \u003c pauseTimestamp, \"cannot enter after pause time\");\n        require(_betTokensInExaEs \u003e= minimumBetInExaEs, \"betting tokens should be more than minimum\");\n\n        /// @dev betDeEx contract transfers the tokens to it self\n        require(betDeEx.collectBettorTokens(msg.sender, _betTokensInExaEs), \"betting tokens should be collected\");\n\n        // @dev _choice can be 0 or 1 and it can be 2 only if isDrawPossible is true\n        if (_choice \u003e 2 || (_choice == 2 \u0026\u0026 !isDrawPossible) ) {\n            require(false, \"this choice is not available\");\n        }\n\n        getNumberOfChoiceBettors[_choice] = getNumberOfChoiceBettors[_choice].add(1);\n        totalBetTokensInExaEsByChoice[_choice] = totalBetTokensInExaEsByChoice[_choice].add(_betTokensInExaEs);\n\n        bettorBetAmountInExaEsByChoice[msg.sender][_choice] = bettorBetAmountInExaEsByChoice[msg.sender][_choice].add(_betTokensInExaEs);\n\n        betDeEx.emitNewBettingEvent(msg.sender, _choice, _betTokensInExaEs);\n    }\n\n    /// @notice this function is used by manager to load correct answer\n    /// @param _choice is the correct choice\n    function endBet(uint8 _choice) public onlyManager {\n        require(now \u003e= pauseTimestamp, \"cannot end bet before pause time\");\n        require(endedBy == address(0), \"Bet Already Ended\");\n\n        // @dev _choice can be 0 or 1 and it can be 2 only if isDrawPossible is true\n        if(_choice \u003c 2  || (_choice == 2 \u0026\u0026 isDrawPossible)) {\n            finalResult = _choice;\n        } else {\n            require(false, \"this choice is not available\");\n        }\n\n        endedBy = msg.sender;\n        endTimestamp = now;\n\n        /// @dev the platform fee is excluded from entire bet balance and this is the amount to be distributed\n        totalPrize = betBalanceInExaEs().mul(prizePercentPerThousand).div(1000);\n\n        /// @dev this is the left platform fee according to the totalPrize variable above\n        uint256 _platformFee = betBalanceInExaEs().sub(totalPrize);\n\n        /// @dev sending plaftrom fee to the super manager\n        require(betDeEx.collectPlatformFee(_platformFee), \"platform fee should be collected\");\n\n        betDeEx.emitEndEvent(endedBy, _choice, _platformFee);\n    }\n\n    /// @notice this function can be called by anyone to see how much winners are getting\n    /// @param _bettorAddress is address whose prize we want to see\n    /// @return winner prize of input address\n    function seeWinnerPrize(address _bettorAddress) public view returns (uint256) {\n        require(endTimestamp \u003e 0, \"cannot see prize before bet ends\");\n\n        return bettorBetAmountInExaEsByChoice[_bettorAddress][finalResult].mul(totalPrize).div(totalBetTokensInExaEsByChoice[finalResult]);\n    }\n\n    /// @notice this function will be called after bet ends and winner bettors can withdraw their prize share\n    function withdrawPrize() public {\n        require(endTimestamp \u003e 0, \"cannot withdraw before end time\");\n        require(!bettorHasClaimed[msg.sender], \"cannot claim again\");\n        require(bettorBetAmountInExaEsByChoice[msg.sender][finalResult] \u003e minimumBetInExaEs, \"caller should have a betting\"); /// @dev to keep out option 0\n        uint256 _winningAmount = bettorBetAmountInExaEsByChoice[msg.sender][finalResult].mul(totalPrize).div(totalBetTokensInExaEsByChoice[finalResult]);\n        bettorHasClaimed[msg.sender] = true;\n        betDeEx.sendTokensToAddress(\n            msg.sender,\n            _winningAmount\n        );\n    }\n}\n"},"ESContract.sol":{"content":"// EraswapToken is pasted below for Interface requirement from https://github.com/KMPARDS/EraSwapSmartContracts/blob/master/Eraswap/contracts/EraswapToken/EraswapToken.sol\n\npragma solidity ^0.5.9;\n\ncontract ERC20Basic {\n  function totalSupply() public view returns (uint256);\n  function balanceOf(address _who) public view returns (uint256);\n  function transfer(address _to, uint256 _value) public returns (bool);\n  event Transfer(address indexed from, address indexed to, uint256 value);\n}\n\ncontract BasicToken is ERC20Basic {\n  using SafeMath for uint256;\n\n  mapping(address =\u003e uint256) internal balances;\n\n  uint256 internal totalSupply_;\n\n  /**\n  * @dev Total number of tokens in existence\n  */\n  function totalSupply() public view returns (uint256) {\n    return totalSupply_;\n  }\n\n  /**\n  * @dev Transfer token for a specified address\n  * @param _to The address to transfer to.\n  * @param _value The amount to be transferred.\n  */\n  function transfer(address _to, uint256 _value) public returns (bool) {\n    require(_value \u003c= balances[msg.sender]);\n    require(_to != address(0));\n\n    balances[msg.sender] = balances[msg.sender].sub(_value);\n    balances[_to] = balances[_to].add(_value);\n    emit Transfer(msg.sender, _to, _value);\n    return true;\n  }\n\n  /**\n  * @dev Gets the balance of the specified address.\n  * @param _owner The address to query the the balance of.\n  * @return An uint256 representing the amount owned by the passed address.\n  */\n  function balanceOf(address _owner) public view returns (uint256) {\n    return balances[_owner];\n  }\n\n}\n\ncontract BurnableToken is BasicToken {\n\n  event Burn(address indexed burner, uint256 value);\n\n  /**\n   * @dev Burns a specific amount of tokens.\n   * @param _value The amount of token to be burned.\n   */\n  function burn(uint256 _value) public {\n    _burn(msg.sender, _value);\n  }\n\n  function _burn(address _who, uint256 _value) internal {\n    require(_value \u003c= balances[_who]);\n    // no need to require value \u003c= totalSupply, since that would imply the\n    // sender\u0027s balance is greater than the totalSupply, which *should* be an assertion failure\n\n    balances[_who] = balances[_who].sub(_value);\n    totalSupply_ = totalSupply_.sub(_value);\n    emit Burn(_who, _value);\n    emit Transfer(_who, address(0), _value);\n  }\n}\n\ncontract ERC20 is ERC20Basic {\n  function allowance(address _owner, address _spender)\n    public view returns (uint256);\n\n  function transferFrom(address _from, address _to, uint256 _value)\n    public returns (bool);\n\n  function approve(address _spender, uint256 _value) public returns (bool);\n  event Approval(\n    address indexed owner,\n    address indexed spender,\n    uint256 value\n  );\n}\n\ncontract DetailedERC20 is ERC20 {\n  string public name;\n  string public symbol;\n  uint8 public decimals;\n\n  constructor(string memory _name, string memory _symbol, uint8 _decimals) public {\n    name = _name;\n    symbol = _symbol;\n    decimals = _decimals;\n  }\n}\n\ncontract Ownable {\n  address public owner;\n\n\n  event OwnershipRenounced(address indexed previousOwner);\n  event OwnershipTransferred(\n    address indexed previousOwner,\n    address indexed newOwner\n  );\n\n\n  /**\n   * @dev The Ownable constructor sets the original `owner` of the contract to the sender\n   * account.\n   */\n  constructor() public {\n    owner = msg.sender;\n  }\n\n  /**\n   * @dev Throws if called by any account other than the owner.\n   */\n  modifier onlyOwner() {\n    require(msg.sender == owner);\n    _;\n  }\n\n  /**\n   * @dev Allows the current owner to relinquish control of the contract.\n   * @notice Renouncing to ownership will leave the contract without an owner.\n   * It will not be possible to call the functions with the `onlyOwner`\n   * modifier anymore.\n   */\n  function renounceOwnership() public onlyOwner {\n    emit OwnershipRenounced(owner);\n    owner = address(0);\n  }\n\n  /**\n   * @dev Allows the current owner to transfer control of the contract to a newOwner.\n   * @param _newOwner The address to transfer ownership to.\n   */\n  function transferOwnership(address _newOwner) public onlyOwner {\n    _transferOwnership(_newOwner);\n  }\n\n  /**\n   * @dev Transfers control of the contract to a newOwner.\n   * @param _newOwner The address to transfer ownership to.\n   */\n  function _transferOwnership(address _newOwner) internal {\n    require(_newOwner != address(0));\n    emit OwnershipTransferred(owner, _newOwner);\n    owner = _newOwner;\n  }\n}\n\nlibrary SafeMath {\n\n  /**\n  * @dev Multiplies two numbers, throws on overflow.\n  */\n  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {\n    // Gas optimization: this is cheaper than asserting \u0027a\u0027 not being zero, but the\n    // benefit is lost if \u0027b\u0027 is also tested.\n    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522\n    if (_a == 0) {\n      return 0;\n    }\n\n    c = _a * _b;\n    assert(c / _a == _b);\n    return c;\n  }\n\n  /**\n  * @dev Integer division of two numbers, truncating the quotient.\n  */\n  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {\n    // assert(_b \u003e 0); // Solidity automatically throws when dividing by 0\n    // uint256 c = _a / _b;\n    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn\u0027t hold\n    return _a / _b;\n  }\n\n  /**\n  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).\n  */\n  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {\n    assert(_b \u003c= _a);\n    return _a - _b;\n  }\n\n  /**\n  * @dev Adds two numbers, throws on overflow.\n  */\n  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {\n    c = _a + _b;\n    assert(c \u003e= _a);\n    return c;\n  }\n}\n\ncontract StandardToken is ERC20, BasicToken {\n\n  mapping (address =\u003e mapping (address =\u003e uint256)) internal allowed;\n\n\n  /**\n   * @dev Transfer tokens from one address to another\n   * @param _from address The address which you want to send tokens from\n   * @param _to address The address which you want to transfer to\n   * @param _value uint256 the amount of tokens to be transferred\n   */\n  function transferFrom(\n    address _from,\n    address _to,\n    uint256 _value\n  )\n    public\n    returns (bool)\n  {\n    require(_value \u003c= balances[_from]);\n    require(_value \u003c= allowed[_from][msg.sender]);\n    require(_to != address(0));\n\n    balances[_from] = balances[_from].sub(_value);\n    balances[_to] = balances[_to].add(_value);\n    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);\n    emit Transfer(_from, _to, _value);\n    return true;\n  }\n\n  /**\n   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.\n   * Beware that changing an allowance with this method brings the risk that someone may use both the old\n   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this\n   * race condition is to first reduce the spender\u0027s allowance to 0 and set the desired value afterwards:\n   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n   * @param _spender The address which will spend the funds.\n   * @param _value The amount of tokens to be spent.\n   */\n  function approve(address _spender, uint256 _value) public returns (bool) {\n    allowed[msg.sender][_spender] = _value;\n    emit Approval(msg.sender, _spender, _value);\n    return true;\n  }\n\n  /**\n   * @dev Function to check the amount of tokens that an owner allowed to a spender.\n   * @param _owner address The address which owns the funds.\n   * @param _spender address The address which will spend the funds.\n   * @return A uint256 specifying the amount of tokens still available for the spender.\n   */\n  function allowance(\n    address _owner,\n    address _spender\n   )\n    public\n    view\n    returns (uint256)\n  {\n    return allowed[_owner][_spender];\n  }\n\n  /**\n   * @dev Increase the amount of tokens that an owner allowed to a spender.\n   * approve should be called when allowed[_spender] == 0. To increment\n   * allowed value is better to use this function to avoid 2 calls (and wait until\n   * the first transaction is mined)\n   * From MonolithDAO Token.sol\n   * @param _spender The address which will spend the funds.\n   * @param _addedValue The amount of tokens to increase the allowance by.\n   */\n  function increaseApproval(\n    address _spender,\n    uint256 _addedValue\n  )\n    public\n    returns (bool)\n  {\n    allowed[msg.sender][_spender] = (\n      allowed[msg.sender][_spender].add(_addedValue));\n    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);\n    return true;\n  }\n\n  /**\n   * @dev Decrease the amount of tokens that an owner allowed to a spender.\n   * approve should be called when allowed[_spender] == 0. To decrement\n   * allowed value is better to use this function to avoid 2 calls (and wait until\n   * the first transaction is mined)\n   * From MonolithDAO Token.sol\n   * @param _spender The address which will spend the funds.\n   * @param _subtractedValue The amount of tokens to decrease the allowance by.\n   */\n  function decreaseApproval(\n    address _spender,\n    uint256 _subtractedValue\n  )\n    public\n    returns (bool)\n  {\n    uint256 oldValue = allowed[msg.sender][_spender];\n    if (_subtractedValue \u003e= oldValue) {\n      allowed[msg.sender][_spender] = 0;\n    } else {\n      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);\n    }\n    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);\n    return true;\n  }\n\n}\n\ncontract MintableToken is StandardToken, Ownable {\n  event Mint(address indexed to, uint256 amount);\n  event MintFinished();\n\n  bool public mintingFinished = false;\n\n\n  modifier canMint() {\n    require(!mintingFinished);\n    _;\n  }\n\n  modifier hasMintPermission() {\n    require(msg.sender == owner);\n    _;\n  }\n\n  /**\n   * @dev Function to mint tokens\n   * @param _to The address that will receive the minted tokens.\n   * @param _amount The amount of tokens to mint.\n   * @return A boolean that indicates if the operation was successful.\n   */\n  function mint(\n    address _to,\n    uint256 _amount\n  )\n    public\n    hasMintPermission\n    canMint\n    returns (bool)\n  {\n    totalSupply_ = totalSupply_.add(_amount);\n    balances[_to] = balances[_to].add(_amount);\n    emit Mint(_to, _amount);\n    emit Transfer(address(0), _to, _amount);\n    return true;\n  }\n\n  /**\n   * @dev Function to stop minting new tokens.\n   * @return True if the operation was successful.\n   */\n  function finishMinting() public onlyOwner canMint returns (bool) {\n    mintingFinished = true;\n    emit MintFinished();\n    return true;\n  }\n}\n\ncontract CappedToken is MintableToken {\n\n  uint256 public cap;\n\n  constructor(uint256 _cap) public {\n    require(_cap \u003e 0);\n    cap = _cap;\n  }\n\n  /**\n   * @dev Function to mint tokens\n   * @param _to The address that will receive the minted tokens.\n   * @param _amount The amount of tokens to mint.\n   * @return A boolean that indicates if the operation was successful.\n   */\n  function mint(\n    address _to,\n    uint256 _amount\n  )\n    public\n    returns (bool)\n  {\n    require(totalSupply_.add(_amount) \u003c= cap);\n\n    return super.mint(_to, _amount);\n  }\n\n}\n\ncontract EraswapERC20 is DetailedERC20, BurnableToken, CappedToken {\n  string private name = \"Eraswap\";\n  string private symbol = \"EST\";\n  uint8 private decimals = 18;\n  uint256 private cap = 9100000000000000000000000000;\n\n  /**\n  * @dev Constructor\n  */\n\n  constructor() internal DetailedERC20(\"Eraswap\", \"EST\", 18) CappedToken(cap){\n    mint(msg.sender, 910000000000000000000000000);\n  }\n\n}\n\ncontract NRTManager is Ownable, EraswapERC20{\n\n  using SafeMath for uint256;\n\n  uint256 public LastNRTRelease;              // variable to store last release date\n  uint256 public MonthlyNRTAmount;            // variable to store Monthly NRT amount to be released\n  uint256 public AnnualNRTAmount;             // variable to store Annual NRT amount to be released\n  uint256 public MonthCount;                  // variable to store the count of months from the intial date\n  uint256 public luckPoolBal;                 // Luckpool Balance\n  uint256 public burnTokenBal;                // tokens to be burned\n\n  // different pool address\n  address public newTalentsAndPartnerships;\n  address public platformMaintenance;\n  address public marketingAndRNR;\n  address public kmPards;\n  address public contingencyFunds;\n  address public researchAndDevelopment;\n  address public buzzCafe;\n  address public timeSwappers;                 // which include powerToken , curators ,timeTraders , daySwappers\n  address public TimeAlly;                     //address of TimeAlly Contract\n\n  uint256 public newTalentsAndPartnershipsBal; // variable to store last NRT released to the address;\n  uint256 public platformMaintenanceBal;       // variable to store last NRT released to the address;\n  uint256 public marketingAndRNRBal;           // variable to store last NRT released to the address;\n  uint256 public kmPardsBal;                   // variable to store last NRT released to the address;\n  uint256 public contingencyFundsBal;          // variable to store last NRT released to the address;\n  uint256 public researchAndDevelopmentBal;    // variable to store last NRT released to the address;\n  uint256 public buzzCafeNRT;                  // variable to store last NRT released to the address;\n  uint256 public TimeAllyNRT;                   // variable to store last NRT released to the address;\n  uint256 public timeSwappersNRT;              // variable to store last NRT released to the address;\n\n\n    // Event to watch NRT distribution\n    // @param NRTReleased The amount of NRT released in the month\n    event NRTDistributed(uint256 NRTReleased);\n\n    /**\n    * Event to watch Transfer of NRT to different Pool\n    * @param pool - The pool name\n    * @param sendAddress - The address of pool\n    * @param value - The value of NRT released\n    **/\n    event NRTTransfer(string pool, address sendAddress, uint256 value);\n\n\n    // Event to watch Tokens Burned\n    // @param amount The amount burned\n    event TokensBurned(uint256 amount);\n\n\n\n    /**\n    * @dev Should burn tokens according to the total circulation\n    * @return true if success\n    */\n\n    function burnTokens() internal returns (bool){\n      if(burnTokenBal == 0){\n        return true;\n      }\n      else{\n        uint MaxAmount = ((totalSupply()).mul(2)).div(100);   // max amount permitted to burn in a month\n        if(MaxAmount \u003e= burnTokenBal ){\n          burn(burnTokenBal);\n          burnTokenBal = 0;\n        }\n        else{\n          burnTokenBal = burnTokenBal.sub(MaxAmount);\n          burn(MaxAmount);\n        }\n        return true;\n      }\n    }\n\n    /**\n    * @dev To invoke monthly release\n    * @return true if success\n    */\n\n    function MonthlyNRTRelease() external returns (bool) {\n      require(now.sub(LastNRTRelease)\u003e 2592000);\n      uint256 NRTBal = MonthlyNRTAmount.add(luckPoolBal);        // Total NRT available.\n\n      // Calculating NRT to be released to each of the pools\n      newTalentsAndPartnershipsBal = (NRTBal.mul(5)).div(100);\n      platformMaintenanceBal = (NRTBal.mul(10)).div(100);\n      marketingAndRNRBal = (NRTBal.mul(10)).div(100);\n      kmPardsBal = (NRTBal.mul(10)).div(100);\n      contingencyFundsBal = (NRTBal.mul(10)).div(100);\n      researchAndDevelopmentBal = (NRTBal.mul(5)).div(100);\n      buzzCafeNRT = (NRTBal.mul(25)).div(1000);\n      TimeAllyNRT = (NRTBal.mul(15)).div(100);\n      timeSwappersNRT = (NRTBal.mul(325)).div(1000);\n\n      // sending tokens to respective wallets and emitting events\n      mint(newTalentsAndPartnerships,newTalentsAndPartnershipsBal);\n      emit NRTTransfer(\"newTalentsAndPartnerships\", newTalentsAndPartnerships, newTalentsAndPartnershipsBal);\n      mint(platformMaintenance,platformMaintenanceBal);\n      emit NRTTransfer(\"platformMaintenance\", platformMaintenance, platformMaintenanceBal);\n      mint(marketingAndRNR,marketingAndRNRBal);\n      emit NRTTransfer(\"marketingAndRNR\", marketingAndRNR, marketingAndRNRBal);\n      mint(kmPards,kmPardsBal);\n      emit NRTTransfer(\"kmPards\", kmPards, kmPardsBal);\n      mint(contingencyFunds,contingencyFundsBal);\n      emit NRTTransfer(\"contingencyFunds\", contingencyFunds, contingencyFundsBal);\n      mint(researchAndDevelopment,researchAndDevelopmentBal);\n      emit NRTTransfer(\"researchAndDevelopment\", researchAndDevelopment, researchAndDevelopmentBal);\n      mint(buzzCafe,buzzCafeNRT);\n      emit NRTTransfer(\"buzzCafe\", buzzCafe, buzzCafeNRT);\n      mint(TimeAlly,TimeAllyNRT);\n      emit NRTTransfer(\"stakingContract\", TimeAlly, TimeAllyNRT);\n      mint(timeSwappers,timeSwappersNRT);\n      emit NRTTransfer(\"timeSwappers\", timeSwappers, timeSwappersNRT);\n\n      // Reseting NRT\n      emit NRTDistributed(NRTBal);\n      luckPoolBal = 0;\n      LastNRTRelease = LastNRTRelease.add(30 days); // resetting release date again\n      burnTokens();                                 // burning burnTokenBal\n      emit TokensBurned(burnTokenBal);\n\n\n      if(MonthCount == 11){\n        MonthCount = 0;\n        AnnualNRTAmount = (AnnualNRTAmount.mul(9)).div(10);\n        MonthlyNRTAmount = MonthlyNRTAmount.div(12);\n      }\n      else{\n        MonthCount = MonthCount.add(1);\n      }\n      return true;\n    }\n\n\n  /**\n  * @dev Constructor\n  */\n\n  constructor() public{\n    LastNRTRelease = now;\n    AnnualNRTAmount = 819000000000000000000000000;\n    MonthlyNRTAmount = AnnualNRTAmount.div(uint256(12));\n    MonthCount = 0;\n  }\n\n}\n\ncontract PausableEraswap is NRTManager {\n\n  /**\n   * @dev Modifier to make a function callable only when the contract is not paused.\n   */\n  modifier whenNotPaused() {\n    require((now.sub(LastNRTRelease))\u003c 2592000);\n    _;\n  }\n\n\n  function transfer(\n    address _to,\n    uint256 _value\n  )\n    public\n    whenNotPaused\n    returns (bool)\n  {\n    return super.transfer(_to, _value);\n  }\n\n  function transferFrom(\n    address _from,\n    address _to,\n    uint256 _value\n  )\n    public\n    whenNotPaused\n    returns (bool)\n  {\n    return super.transferFrom(_from, _to, _value);\n  }\n\n  function approve(\n    address _spender,\n    uint256 _value\n  )\n    public\n    whenNotPaused\n    returns (bool)\n  {\n    return super.approve(_spender, _value);\n  }\n\n  function increaseApproval(\n    address _spender,\n    uint _addedValue\n  )\n    public\n    whenNotPaused\n    returns (bool success)\n  {\n    return super.increaseApproval(_spender, _addedValue);\n  }\n\n  function decreaseApproval(\n    address _spender,\n    uint _subtractedValue\n  )\n    public\n    whenNotPaused\n    returns (bool success)\n  {\n    return super.decreaseApproval(_spender, _subtractedValue);\n  }\n}\n\ncontract EraswapToken is PausableEraswap {\n\n\n    /**\n    * Event to watch the addition of pool address\n    * @param pool - The pool name\n    * @param sendAddress - The address of pool\n    **/\n    event PoolAddressAdded(string pool, address sendAddress);\n\n    // Event to watch LuckPool Updation\n    // @param luckPoolBal The current luckPoolBal\n    event LuckPoolUpdated(uint256 luckPoolBal);\n\n    // Event to watch BurnTokenBal Updation\n    // @param burnTokenBal The current burnTokenBal\n    event BurnTokenBalUpdated(uint256 burnTokenBal);\n\n    /**\n    * @dev Throws if caller is not TimeAlly\n    */\n    modifier OnlyTimeAlly() {\n      require(msg.sender == TimeAlly);\n      _;\n    }\n\n\n    /**\n    * @dev To update pool addresses\n    * @param  pool - A List of pool addresses\n    * Updates if pool address is not already set and if given address is not zero\n    * @return true if success\n    */\n\n    function UpdateAddresses (address[] memory pool) onlyOwner public returns(bool){\n\n      if((pool[0] != address(0)) \u0026\u0026 (newTalentsAndPartnerships == address(0))){\n        newTalentsAndPartnerships = pool[0];\n        emit PoolAddressAdded( \"NewTalentsAndPartnerships\", newTalentsAndPartnerships);\n      }\n      if((pool[1] != address(0)) \u0026\u0026 (platformMaintenance == address(0))){\n        platformMaintenance = pool[1];\n        emit PoolAddressAdded( \"PlatformMaintenance\", platformMaintenance);\n      }\n      if((pool[2] != address(0)) \u0026\u0026 (marketingAndRNR == address(0))){\n        marketingAndRNR = pool[2];\n        emit PoolAddressAdded( \"MarketingAndRNR\", marketingAndRNR);\n      }\n      if((pool[3] != address(0)) \u0026\u0026 (kmPards == address(0))){\n        kmPards = pool[3];\n        emit PoolAddressAdded( \"KmPards\", kmPards);\n      }\n      if((pool[4] != address(0)) \u0026\u0026 (contingencyFunds == address(0))){\n        contingencyFunds = pool[4];\n        emit PoolAddressAdded( \"ContingencyFunds\", contingencyFunds);\n      }\n      if((pool[5] != address(0)) \u0026\u0026 (researchAndDevelopment == address(0))){\n        researchAndDevelopment = pool[5];\n        emit PoolAddressAdded( \"ResearchAndDevelopment\", researchAndDevelopment);\n      }\n      if((pool[6] != address(0)) \u0026\u0026 (buzzCafe == address(0))){\n        buzzCafe = pool[6];\n        emit PoolAddressAdded( \"BuzzCafe\", buzzCafe);\n      }\n      if((pool[7] != address(0)) \u0026\u0026 (timeSwappers == address(0))){\n        timeSwappers = pool[7];\n        emit PoolAddressAdded( \"TimeSwapper\", timeSwappers);\n      }\n      if((pool[8] != address(0)) \u0026\u0026 (TimeAlly == address(0))){\n        TimeAlly = pool[8];\n        emit PoolAddressAdded( \"TimeAlly\", TimeAlly);\n      }\n\n      return true;\n    }\n\n\n    /**\n    * @dev Function to update luckpool balance\n    * @param amount Amount to be updated\n    */\n    function UpdateLuckpool(uint256 amount) OnlyTimeAlly external returns(bool){\n      require(allowance(msg.sender, address(this)) \u003e= amount);\n      require(transferFrom(msg.sender,address(this), amount));\n      luckPoolBal = luckPoolBal.add(amount);\n      emit LuckPoolUpdated(luckPoolBal);\n      return true;\n    }\n\n    /**\n    * @dev Function to trigger to update  for burning of tokens\n    * @param amount Amount to be updated\n    */\n    function UpdateBurnBal(uint256 amount) OnlyTimeAlly external returns(bool){\n      require(allowance(msg.sender, address(this)) \u003e= amount);\n      require(transferFrom(msg.sender,address(this), amount));\n      burnTokenBal = burnTokenBal.add(amount);\n      emit BurnTokenBalUpdated(burnTokenBal);\n      return true;\n    }\n\n    /**\n    * @dev Function to trigger balance update of a list of users\n    * @param TokenTransferList - List of user addresses\n    * @param TokenTransferBalance - Amount of token to be sent\n    */\n    function UpdateBalance(address[100] calldata TokenTransferList, uint256[100] calldata TokenTransferBalance) OnlyTimeAlly external returns(bool){\n        for (uint256 i = 0; i \u003c TokenTransferList.length; i++) {\n      require(allowance(msg.sender, address(this)) \u003e= TokenTransferBalance[i]);\n      require(transferFrom(msg.sender, TokenTransferList[i], TokenTransferBalance[i]));\n      }\n      return true;\n    }\n\n\n\n\n}\n"}}