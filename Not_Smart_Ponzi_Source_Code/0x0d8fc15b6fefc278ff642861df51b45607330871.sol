from vyper.interfaces import ERC20

implements: ERC20

Transfer: event({_from: indexed(address), _to: indexed(address), _value: uint256})
Approval: event({_owner: indexed(address), _spender: indexed(address), _value: uint256})
Blacklisted: event({_to: indexed(address)})
Appointed: event({_to: indexed(address)})

name: public(string[64])
symbol: public(string[32])
decimals: public(uint256)

# NOTE: By declaring `balanceOf` as public, vyper automatically generates a 'balanceOf()' getter
#       method to allow access to account balances.
#       The _KeyType will become a required parameter for the getter and it will return _ValueType.
#       See: https://vyper.readthedocs.io/en/v0.1.0-beta.8/types.html?highlight=getter#mappings
balanceOf: public(map(address, uint256))
allowances: map(address, map(address, uint256))
total_supply: uint256
minter: address
isFrozen: bool
blacklisted: public(map(address, bool))
issuers: map(address, bool)

@public
def __init__(_name: string[64], _symbol: string[32], _decimals: uint256, _supply: uint256, _frozen: bool):
    init_supply: uint256 = _supply * 10 ** _decimals
    self.name = _name
    self.symbol = _symbol
    self.decimals = _decimals
    self.balanceOf[msg.sender] = init_supply
    self.total_supply = init_supply
    self.minter = msg.sender
    self.isFrozen = _frozen
    log.Transfer(ZERO_ADDRESS, msg.sender, init_supply)


@public
@constant
def totalSupply() -> uint256:
    """
    @dev Total number of tokens in existence.
    """
    
    return self.total_supply

@public
@constant
def contractFrozen() -> bool:
    """
    @dev Check if transactions are frozen
    """
    
    return self.isFrozen

@public
def isIssuer(_address : address) -> bool:
    """
    @dev Check if address is an authorized issuer
    @param _address queried address
    """
    
    return self.issuers[_address]
    
@public
def setIssuer(_to : address, _value : bool) -> bool:
    """
    @dev set new authorized issuer addresses
    only minter can append addresses
    @param new issuer address
    """
    
    assert msg.sender == self.minter
    assert self.issuers[_to] != _value
    self.issuers[_to] = _value
    log.Appointed(_to)
    
    return True


@public
@constant
def allowance(_owner : address, _spender : address) -> uint256:
    """
    @dev Function to check the amount of tokens that an owner allowed to a spender.
    @param _owner The address which owns the funds.
    @param _spender The address which will spend the funds.
    @return An uint256 specifying the amount of tokens still available for the spender.
    """
    return self.allowances[_owner][_spender]

@private
def _blacklist(_to : address) -> bool:
    """
    @dev Private function to blacklist an address
    @param _to The address to blacklist 
    """
    assert _to != ZERO_ADDRESS
    self.blacklisted[_to] = True
    log.Blacklisted(_to)
    return True

@public
def blacklist(_to : address):
    """
    @dev Blacklist an address, disallow from sending transactions
    @param _to The address to blacklist
    """
    assert msg.sender == self.minter
    self._blacklist(_to)

@public 
def freezeContract(_value : bool) -> bool:
    """
    @dev Freezes contract from all transactions
    @param _value boolean to regarding status of contract freeze 
    """
    assert msg.sender == self.minter
    self.isFrozen = _value
    
    return _value

@public
def transfer(_to : address, _value : uint256) -> bool:
    """
    @dev Transfer token for a specified address
    @param _to The address to transfer to.
    @param _value The amount to be transferred.
    """
    # NOTE: vyper does not allow underflows
    #       so the following subtraction would revert on insufficient balance
    assert self.blacklisted[msg.sender] != True
    assert self.isFrozen != True
    self.balanceOf[msg.sender] -= _value
    self.balanceOf[_to] += _value
    log.Transfer(msg.sender, _to, _value)
    
    return True


@public
def transferFrom(_from : address, _to : address, _value : uint256) -> bool:
    """
     @dev Transfer tokens from one address to another.
          Note that while this function emits a Transfer event, this is not required as per the specification,
          and other compliant implementations may not emit the event.
     @param _from address The address which you want to send tokens from
     @param _to address The address which you want to transfer to
     @param _value uint256 the amount of tokens to be transferred
    """
    assert self.blacklisted[msg.sender] != True
    assert self.isFrozen != True
    # NOTE: vyper does not allow underflows
    #       so the following subtraction would revert on insufficient balance
    self.balanceOf[_from] -= _value
    self.balanceOf[_to] += _value
    # NOTE: vyper does not allow underflows
    #      so the following subtraction would revert on insufficient allowance
    self.allowances[_from][msg.sender] -= _value
    log.Transfer(_from, _to, _value)
    
    return True


@public
def approve(_spender : address, _value : uint256) -> bool:
    """
    @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
         Beware that changing an allowance with this method brings the risk that someone may use both the old
         and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
         race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
         https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    @param _spender The address which will spend the funds.
    @param _value The amount of tokens to be spent.
    """
    assert self.blacklisted[msg.sender] != True
    assert self.isFrozen != True
    
    self.allowances[msg.sender][_spender] = _value
    log.Approval(msg.sender, _spender, _value)
    return True


@public
def mint(_to: address, _value: uint256):
    """
    @dev Mint an amount of the token and assigns it to an account. 
         This encapsulates the modification of balances such that the
         proper events are emitted.
    @param _to The account that will receive the created tokens.
    @param _value The amount that will be created.
    """
    assert self.issuers[msg.sender] == True
    assert _to != ZERO_ADDRESS
    self.total_supply += _value
    self.balanceOf[_to] += _value
    log.Transfer(ZERO_ADDRESS, _to, _value)


@private
def _burn(_to: address, _value: uint256):
    """
    @dev Internal function that burns an amount of the token of a given
         account.
    @param _to The account whose tokens will be burned.
    @param _value The amount that will be burned.
    """
    assert _to != ZERO_ADDRESS
    self.total_supply -= _value
    self.balanceOf[_to] -= _value
    log.Transfer(_to, ZERO_ADDRESS, _value)


@public
def redeem(_value: uint256):
    """
    @dev Burn an amount of the token of msg.sender.
    @param _value The amount that will be burned.
    """
    assert self.issuers[msg.sender] == True
    self._burn(msg.sender, _value)


@public
def burnFrom(_to: address, _value: uint256):
    """
    @dev Burn an amount of the token from a given account.
    @param _to The account whose tokens will be burned.
    @param _value The amount that will be burned.
    """
    assert self.issuers[msg.sender] == True
    self._burn(_to, _value)