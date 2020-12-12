{"BitQBBQQChain.sol":{"content":" /*\r\nThis Token Contract implements the standard token functionality (https://github.com/ethereum/EIPs/issues/20) as well as the following OPTIONAL extras intended for use by humans.\r\n\r\nIn other words. This is intended for deployment in something like a Token Factory or Mist wallet, and then used by humans.\r\nImagine coins, currencies, shares, voting weight, etc.\r\nMachine-based, rapid creation of many tokens would not necessarily need these extra features or will be minted in other manners.\r\n\r\n1) Initial Finite Supply (upon creation one specifies how much is minted).\r\n2) In the absence of a token registry: Optional Decimal, Symbol \u0026 Name.\r\n3) Optional approveAndCall() functionality to notify a contract if an approval() has occurred.\r\n\r\n.*/\r\npragma solidity ^0.4.4;\r\n\r\nimport \"./StandardToken.sol\";\r\n\r\ncontract BitQBBQQChain is StandardToken {\r\n\r\n    function () {\r\n        //if ether is sent to this address, send it back.\r\n        throw;\r\n    }\r\n\r\n    /* Public variables of the token */\r\n\r\n    /*\r\n    NOTE:\r\n    The following variables are OPTIONAL vanities. One does not have to include them.\r\n    They allow one to customise the token contract \u0026 in no way influences the core functionality.\r\n    Some wallets/interfaces might not even bother to look at this information.\r\n    */\r\n    string public name;                   //token名称: MyFreeCoin \r\n    uint8 public decimals;                //小数位\r\n    string public symbol;                 //标识\r\n    string public version = \u0027v1.0\u0027;       //版本号\r\n\r\n    function BitQBBQQChain(\r\n        uint256 _initialAmount,\r\n        string _tokenName,\r\n        uint8 _decimalUnits,\r\n        string _tokenSymbol\r\n        ) {\r\n        balances[msg.sender] = _initialAmount;               // 合约发布者的余额是发行数量\r\n        totalSupply = _initialAmount;                        // 发行量\r\n        name = _tokenName;                                   // token名称\r\n        decimals = _decimalUnits;                            // token小数位\r\n        symbol = _tokenSymbol;                               // token标识\r\n    }\r\n\r\n    /* 批准然后调用接收合约 */\r\n    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {\r\n        allowed[msg.sender][_spender] = _value;\r\n        Approval(msg.sender, _spender, _value);\r\n\r\n        //调用你想要通知合约的 receiveApprovalcall 方法 ，这个方法是可以不需要包含在这个合约里的。\r\n        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)\r\n        //假设这么做是可以成功，不然应该调用vanilla approve。\r\n        if(!_spender.call(bytes4(bytes32(sha3(\"receiveApproval(address,uint256,address,bytes)\"))), msg.sender, _value, this, _extraData)) { throw; }\r\n        return true;\r\n    }\r\n}"},"StandardToken.sol":{"content":"/*\r\nThis implements ONLY the standard functions and NOTHING else.\r\nFor a token like you would want to deploy in something like Mist, see HumanStandardToken.sol.\r\n\r\nIf you deploy this, you won\u0027t have anything useful.\r\n\r\nImplements ERC 20 Token standard: https://github.com/ethereum/EIPs/issues/20\r\n\r\n实现ERC20标准\r\n.*/\r\n\r\npragma solidity ^0.4.4;\r\n\r\nimport \"./Token.sol\";\r\n\r\ncontract StandardToken is Token {\r\n\r\n    function transfer(address _to, uint256 _value) returns (bool success) {\r\n        //默认token发行量不能超过(2^256 - 1)\r\n        //如果你不设置发行量，并且随着时间的发型更多的token，需要确保没有超过最大值，使用下面的 if 语句\r\n        //if (balances[msg.sender] \u003e= _value \u0026\u0026 balances[_to] + _value \u003e balances[_to]) {\r\n        if (balances[msg.sender] \u003e= _value \u0026\u0026 _value \u003e 0) {\r\n            balances[msg.sender] -= _value;\r\n            balances[_to] += _value;\r\n            Transfer(msg.sender, _to, _value);\r\n            return true;\r\n        } else { return false; }\r\n    }\r\n\r\n    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {\r\n        //向上面的方法一样，如果你想确保发行量不超过最大值\r\n        //if (balances[_from] \u003e= _value \u0026\u0026 allowed[_from][msg.sender] \u003e= _value \u0026\u0026 balances[_to] + _value \u003e balances[_to]) {\r\n        if (balances[_from] \u003e= _value \u0026\u0026 allowed[_from][msg.sender] \u003e= _value \u0026\u0026 _value \u003e 0) {\r\n            balances[_to] += _value;\r\n            balances[_from] -= _value;\r\n            allowed[_from][msg.sender] -= _value;\r\n            Transfer(_from, _to, _value);\r\n            return true;\r\n        } else { return false; }\r\n    }\r\n\r\n    function balanceOf(address _owner) constant returns (uint256 balance) {\r\n        return balances[_owner];\r\n    }\r\n\r\n    function approve(address _spender, uint256 _value) returns (bool success) {\r\n        allowed[msg.sender][_spender] = _value;\r\n        Approval(msg.sender, _spender, _value);\r\n        return true;\r\n    }\r\n\r\n    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {\r\n      return allowed[_owner][_spender];\r\n    }\r\n\r\n    mapping (address =\u003e uint256) balances;\r\n    mapping (address =\u003e mapping (address =\u003e uint256)) allowed;\r\n    uint256 public totalSupply;\r\n}"},"Token.sol":{"content":"pragma solidity ^0.4.4;\r\n\r\ncontract Token {\r\n\r\n    /// @return 返回token的发行量\r\n    function totalSupply() constant returns (uint256 supply) {}\r\n\r\n    /// @param _owner 查询以太坊地址token余额\r\n    /// @return The balance 返回余额\r\n    function balanceOf(address _owner) constant returns (uint256 balance) {}\r\n\r\n    /// @notice msg.sender（交易发送者）发送 _value（一定数量）的 token 到 _to（接受者）  \r\n    /// @param _to 接收者的地址\r\n    /// @param _value 发送token的数量\r\n    /// @return 是否成功\r\n    function transfer(address _to, uint256 _value) returns (bool success) {}\r\n\r\n    /// @notice 发送者 发送 _value（一定数量）的 token 到 _to（接受者）  \r\n    /// @param _from 发送者的地址\r\n    /// @param _to 接收者的地址\r\n    /// @param _value 发送的数量\r\n    /// @return 是否成功\r\n    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}\r\n\r\n    /// @notice 发行方 批准 一个地址发送一定数量的token\r\n    /// @param _spender 需要发送token的地址\r\n    /// @param _value 发送token的数量\r\n    /// @return 是否成功\r\n    function approve(address _spender, uint256 _value) returns (bool success) {}\r\n\r\n    /// @param _owner 拥有token的地址\r\n    /// @param _spender 可以发送token的地址\r\n    /// @return 还允许发送的token的数量\r\n    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}\r\n\r\n    /// 发送Token事件\r\n    event Transfer(address indexed _from, address indexed _to, uint256 _value);\r\n    /// 批准事件\r\n    event Approval(address indexed _owner, address indexed _spender, uint256 _value);\r\n}"}}