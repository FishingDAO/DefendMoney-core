pragma solidity >=0.5.0 <0.7.0;


contract DeFiSafe {
    //User Structure
    struct User {
        address name;
        uint256 tokenID;
        uint256 amount;
        uint256 price;
    }

    //Token pool Structure
    struct TokenPool {
        uint256 tokenID;
        uint256 tokenAmount;
        uint256 userAmount;
        mapping(address => User) users;
    }

    //Insurance Pool Structure
    struct InsurePool {
        uint256 depositAmount;
        uint256 surplusFundAmount;
    }

    //TODO define TokenID protocol

    // Token total
    uint256 public tokenTotal;

    //Token Pool management
    mapping(uint256 => TokenPool) tokenPools;

    // Insurance Pool
    InsurePool public insurePool;

    //
    constructor() public {
        tokenTotal = 6;
        for (uint256 i = 0; i < tokenTotal; i++) {
            tokenPools[100 + i] = TokenPool({
                tokenID: 100 + i,
                tokenAmount: 0,
                userAmount: 0
            });
        }
        insurePool = InsurePool({depositAmount: 0, surplusFundAmount: 0});
    }

    // Input Asset
    function inputAsset(address name, uint256 tokenType, uint256 amount)
        public
    {
        require(tokenType >= 100 && tokenType <= 106, "not Token!");
        require(amount > 0, "Too few assets");
        //Match Route
        TokenPool storage pool = matchRoute(tokenType);
        //Entry Token Pool
        entryTokenPool(pool, name, tokenType, amount);
    }

    // Check Token Pool
    function checkTokenPool(uint256 tokenType)
        public
        view
        returns (uint256)
    {
        TokenPool storage pool = tokenPools[tokenType];
        return pool.tokenAmount;
    }

    // Match Route
    function matchRoute(uint256 tokenType) 
        internal 
        returns (TokenPool memory) 
    {
        return tokenPools[tokenType];
    }

    // Entry Token Pool
    function entryTokenPool(
        TokenPool pool,
        address name,
        uint256 tokenType,
        uint256 amount
    ) internal {
        //update Token Pool
        pool.tokenAmount += amount;
        pool.userAmount += 1;
        User storage user = pool.users[name];
        user.name = name;
        user.tokenID = tokenType;
        user.amount = amount;
        user.price = getTokenPrice(tokenType);
        // distribute Token
        entryInsurancePool(swapDai(tokenType, amount * 0.05));
        entryUniSwap(tokenType, amount * 0.95);
    }


    //Entry Insurance Pool
    function entryInsurancePool(uint256 amount) 
        internal 
    {
        insurePool.depositAmount += amount;
        entryUniSwap(amount);
    }

    //entry Uniswap
    function entryUniSwap(uint256 tokenType, uint256 amount) 
        internal 
    {
        //TODO add liquid
    }

    //entry AAVE
    function entryAAVE(uint256 amount) {
        //TODO add liquid
    }

    // get Token price
    function getTokenPrice(uint256 tokenType) 
        public 
        returns (uint256) 
    {
        uint256 price=10
        // TODO get token price from Chainlink
        return price;
    }

    // swap Dai from uniswap
    function swapDai(uint256 tokenType, uint256 amount)
        public
        returns (uint256)
    {
        //TODO swap Dai from uniswap
    }
}
