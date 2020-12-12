{"DigitalStakeToken.sol":{"content":"pragma solidity 0.4.19;\n\n\n\nimport \u0027SafeMath.sol\u0027;\n\nimport \u0027Erc20.sol\u0027;\n\n\n\ncontract DigitalStakeToken is ERC20 {\n\n  using SafeMath for uint;\n\n\n\n    string internal _name;\n\n    string internal _symbol;\n\n    uint8 internal _decimals;\n\n    uint256 internal _totalSupply;\n\n\n\n    mapping (address =\u003e uint256) internal balances;\n\n    mapping (address =\u003e mapping (address =\u003e uint256)) internal allowed;\n\n\n\n    function DigitalStakeToken(string name, string symbol, uint8 decimals, uint256 totalSupply) public {\n\n        _symbol = symbol;\n\n        _name = name;\n\n        _decimals = decimals;\n\n        _totalSupply = totalSupply;\n\n        balances[msg.sender] = totalSupply;\n\n    }\n\n\n\n    function name()\n\n        public\n\n        view\n\n        returns (string) {\n\n        return _name;\n\n    }\n\n\n\n    function symbol()\n\n        public\n\n        view\n\n        returns (string) {\n\n        return _symbol;\n\n    }\n\n\n\n    function decimals()\n\n        public\n\n        view\n\n        returns (uint8) {\n\n        return _decimals;\n\n    }\n\n\n\n    function totalSupply()\n\n        public\n\n        view\n\n        returns (uint256) {\n\n        return _totalSupply;\n\n    }\n\n\n\n   function transfer(address _to, uint256 _value) public returns (bool) {\n\n     require(_to != address(0));\n\n     require(_value \u003c= balances[msg.sender]);\n\n     balances[msg.sender] = SafeMath.sub(balances[msg.sender], _value);\n\n     balances[_to] = SafeMath.add(balances[_to], _value);\n\n     Transfer(msg.sender, _to, _value);\n\n     return true;\n\n   }\n\n\n\n  function balanceOf(address _owner) public view returns (uint256 balance) {\n\n    return balances[_owner];\n\n   }\n\n\n\n  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {\n\n    require(_to != address(0));\n\n     require(_value \u003c= balances[_from]);\n\n     require(_value \u003c= allowed[_from][msg.sender]);\n\n\n\n    balances[_from] = SafeMath.sub(balances[_from], _value);\n\n     balances[_to] = SafeMath.add(balances[_to], _value);\n\n     allowed[_from][msg.sender] = SafeMath.sub(allowed[_from][msg.sender], _value);\n\n    Transfer(_from, _to, _value);\n\n     return true;\n\n   }\n\n\n\n   function approve(address _spender, uint256 _value) public returns (bool) {\n\n     allowed[msg.sender][_spender] = _value;\n\n     Approval(msg.sender, _spender, _value);\n\n     return true;\n\n   }\n\n\n\n  function allowance(address _owner, address _spender) public view returns (uint256) {\n\n     return allowed[_owner][_spender];\n\n   }\n\n\n\n   function increaseApproval(address _spender, uint _addedValue) public returns (bool) {\n\n     allowed[msg.sender][_spender] = SafeMath.add(allowed[msg.sender][_spender], _addedValue);\n\n     Approval(msg.sender, _spender, allowed[msg.sender][_spender]);\n\n     return true;\n\n   }\n\n\n\n  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {\n\n     uint oldValue = allowed[msg.sender][_spender];\n\n     if (_subtractedValue \u003e oldValue) {\n\n       allowed[msg.sender][_spender] = 0;\n\n     } else {\n\n       allowed[msg.sender][_spender] = SafeMath.sub(oldValue, _subtractedValue);\n\n    }\n\n     Approval(msg.sender, _spender, allowed[msg.sender][_spender]);\n\n     return true;\n\n   }\n\n\n\n}\n"},"Erc20.sol":{"content":"pragma solidity 0.4.19;\n\n\n\ninterface ERC20 {\n\n  function balanceOf(address who) public view returns (uint256);\n\n  function transfer(address to, uint256 value) public returns (bool);\n\n  function allowance(address owner, address spender) public view returns (uint256);\n\n  function transferFrom(address from, address to, uint256 value) public returns (bool);\n\n  function approve(address spender, uint256 value) public returns (bool);\n\n  event Transfer(address indexed from, address indexed to, uint256 value);\n\n  event Approval(address indexed owner, address indexed spender, uint256 value);\n\n}\n"},"SafeMath.sol":{"content":"pragma solidity 0.4.19;\n\n\n\nlibrary SafeMath {\n\n  function mul(uint256 a, uint256 b) internal pure returns (uint256) {\n\n    if (a == 0) {\n\n      return 0;\n\n    }\n\n    uint256 c = a * b;\n\n    assert(c / a == b);\n\n    return c;\n\n  }\n\n\n\n  function div(uint256 a, uint256 b) internal pure returns (uint256) {\n\n    // assert(b \u003e 0); // Solidity automatically throws when dividing by 0\n\n    uint256 c = a / b;\n\n    // assert(a == b * c + a % b); // There is no case in which this doesn\u0027t hold\n\n    return c;\n\n  }\n\n\n\n  function sub(uint256 a, uint256 b) internal pure returns (uint256) {\n\n    assert(b \u003c= a);\n\n    return a - b;\n\n  }\n\n\n\n  function add(uint256 a, uint256 b) internal pure returns (uint256) {\n\n    uint256 c = a + b;\n\n    assert(c \u003e= a);\n\n    return c;\n\n  }\n\n}\n"}}