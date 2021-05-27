pragma solidity >=0.4.22 <0.6.0;

//-----------------------------------------------------------------------------
/// @title VEED contract
/// @notice defines standard ERC-20 functionality.
//-----------------------------------------------------------------------------
contract VEED {
    //-------------------------------------------------------------------------
    /// @dev Emits when ownership of VEED changes by any mechanism. Also emits
    ///  when tokens are destroyed ('to' == 0).
    //-------------------------------------------------------------------------
    event Transfer (address indexed _from, address indexed _to, uint _tokens);

    //-------------------------------------------------------------------------
    /// @dev Emits when an approved spender is changed or reaffirmed, or if
    ///  the allowance amount changes. The zero address indicates there is no
    ///  approved address.
    //-------------------------------------------------------------------------
    event Approval (
        address indexed _tokenOwner, 
        address indexed _spender, 
        uint _tokens
    );

    // Name of the token
    string constant public name = "VEED";

    // Ticker string for this token
    string constant public symbol = "VEED";

    // number of decimal places tracked by this token
    uint8 constant public decimals = 18;
    
    // total number of tokens in circulation.
    //  Burning tokens reduces this amount
    uint public totalSupply = (10 ** 11) * (10 ** uint(decimals));    // one hundred billion
    
    // the token balances of all token holders
    mapping (address => uint) public balanceOf;
    
    // approved spenders and allowances of all token holders
    mapping (address => mapping (address => uint)) public allowance;

    constructor() public {
        balanceOf[msg.sender] = totalSupply;
    }
    
    //-------------------------------------------------------------------------
    /// @dev Throws if tokenOwner has insufficient VEED balance
    //-------------------------------------------------------------------------
    modifier sufficientFunds(address tokenOwner, uint tokens) {
        require (balanceOf[tokenOwner] >= tokens, "Insufficient balance");
        _;
    }

    //-------------------------------------------------------------------------
    /// @notice Send `(tokens/1000000000000000000).fixed(0,18)` VEED to `to`.
    /// @dev Throws if `msg.sender` has insufficient balance for transfer.
    /// @param _to The address to where VEED is being sent.
    /// @param _tokens The number of tokens to send.
    /// @return True upon successful transfer. Will throw if unsuccessful.
    //-------------------------------------------------------------------------
    function transfer(address _to, uint _tokens) 
        public
        sufficientFunds(msg.sender, _tokens)
        returns(bool) 
    {
        // subtract amount from sender
        balanceOf[msg.sender] -= _tokens;

        if (_to != address(0)) {
            // add amount to token receiver
            balanceOf[_to] += _tokens;
        }
        else {
            // burn amount
            totalSupply -= _tokens;
        }

        // emit transfer event
        emit Transfer(msg.sender, _to, _tokens);
        
        return true;
    }

    //-------------------------------------------------------------------------
    /// @notice Send `(tokens/1000000000000000000).fixed(0,18)` VEED from
    ///  `from` to `to`.
    /// @dev Throws if `msg.sender` has insufficient allowance for transfer.
    ///  Throws if `from` has insufficient balance for transfer.
    /// @param _from The address from where VEED is being sent. Sender must be
    ///  an approved spender.
    /// @param _to The token owner whose VEED is being sent.
    /// @param _tokens The number of tokens to send.
    /// @return True upon successful transfer. Will throw if unsuccessful.
    //-------------------------------------------------------------------------
    function transferFrom(address _from, address _to, uint _tokens) 
        public
        sufficientFunds(_from, _tokens)
        returns(bool) 
    {
        require (
            allowance[_from][msg.sender] >= _tokens, 
            "Insufficient allowance"
        );
        // subtract amount from sender's allowance
        allowance[_from][msg.sender] -= _tokens;
        // subtract amount from token owner
        balanceOf[_from] -= _tokens;

        if (_to != address(0)) {
            // add amount to token receiver
            balanceOf[_to] += _tokens;
        }
        else {
            // burn amount
            totalSupply -= _tokens;
        }
        // emit transfer event
        emit Transfer(_from, _to, _tokens);

        return true;
    }

    //-------------------------------------------------------------------------
    /// @notice Allow `_spender` to withdraw from your account, multiple times,
    ///  up to `(tokens/1000000000000000000).fixed(0,18)` VEED. Calling this
    ///  function overwrites the previous allowance of spender.
    /// @dev Emits approval event
    /// @param _spender The address to authorize as a spender
    /// @param _tokens The new token allowance of spender (in wei).
    //-------------------------------------------------------------------------
    function approve(address _spender, uint _tokens) external returns(bool) {
        // set the spender's allowance to token amount
        allowance[msg.sender][_spender] = _tokens;
        // emit approval event
        emit Approval(msg.sender, _spender, _tokens);

        return true;
    }
}
