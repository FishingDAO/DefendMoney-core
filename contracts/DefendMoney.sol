pragma solidity 0.6.0;
import "./ABDKMathQuad.sol";
import './UniswapUtils.sol';
import "testKyberSwap.sol";
import "ERC20Interface.sol";

contract DefendMoney {
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

    //TokenID protocol
    mapping(uint=>address) public tokenIDProtocol;
    
    // Token total
    uint256 public tokenTotal;

    //Token Pool management
    mapping(uint256 => TokenPool) tokenPools;

    // Insurance Pool
    InsurePool public insurePool;

    //TODO Contract address
    address payable _Ower;
    
    //Test use
    address constant KyberNetworkProxyAddress = 0x818E6FECD516Ecc3849DAf6845e3EC868087B755;
    KyberNetworkProxy public kyberManger;
    UniswapUtils public uniswapManger;
    
    //
    constructor() public {
         address[7] memory erc20Address = [ address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE),//ethe
                                            address(0x7B2810576aa1cce68F2B118CeF1F36467c648F92),//knc
                                            address(0xb4f7332ed719Eb4839f091EDDB2A3bA309739521),//link
                                            address(0x4BFBa4a8F28755Cb2061c413459EE562c6B9c51b),//omg
                                            address(0xDb0040451F373949A4Be60dcd7b6B8D6E42658B6),//bat
                                            address(0x72fd6C7C1397040A66F33C2ecC83A0F71Ee46D5c),//mama
                                            address(0xaD6D458402F60fD3Bd25163575031ACDce07538D)//dai
                                ];
        tokenTotal = 7;
        for (uint256 i = 0; i < tokenTotal; i++) {
                tokenPools[100 + i] = TokenPool({
                tokenID: 100 + i,
                tokenAmount: 0,
                userAmount: 0
            });
            tokenIDProtocol[100+i] = erc20Address[i];
        }
        insurePool = InsurePool({depositAmount: 0, surplusFundAmount: 0});
        _Ower = msg.sender;
        kyberManger = KyberNetworkProxy(KyberNetworkProxyAddress);
        uniswapManger = UniswapUtils(msg.sender);
    }

    // Input Asset
    function inputAsset(address name, uint256 tokenType, uint256 amount)
        public payable
    {
        require(tokenType >= 100 && tokenType <= 106, "not Token!");
        require(amount > 0, "Too few assets");
        if(tokenType == 100){
            _Ower.transfer(amount);
        }else{
            address tokeAddress = tokenIDProtocol[tokenType];
            IERC20 tokenManager = IERC20(tokeAddress);
            tokenManager.transfer(_Ower,amount);
        }
    }

    function startAccountBook(address name, uint256 tokenType, uint256 amount) 
        public payable
    {
        require(msg.sender == _Ower, "not _Ower");
        //Match Route
        TokenPool storage pool = matchRoute(tokenType);
        //Entry Token Pool
        entryTokenPool(pool, name, tokenType, amount);
    }

    // Match Route
    function matchRoute(uint256 tokenType) 
        internal 
        returns (TokenPool storage) 
    {
        return tokenPools[tokenType];
    }

    // Entry Token Pool
    function entryTokenPool(
        TokenPool storage pool,
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
        user.price = uniswapManger.getPirce(amount,tokenIDProtocol[tokenType]);
        //distribute Token
        entryInsurancePool(swapDai(tokenType, mulDiv(amount,5,100)));
        entryAAVE(tokenType,mulDiv(amount,95,100));
    }
    
    
    function testUniswapPrice(uint256 tokenType,uint256 amount) public  returns(uint256){
        return uniswapManger.getPirce(amount,tokenIDProtocol[tokenType]);
    }
    
    function testUniswapSwap(uint256 tokenType,uint256 amount) public returns(uint256){
        return swapDai(tokenType,amount);
    }
    
    function testKyberPrice(uint256 srcTokenType,uint256 desTokenType,uint256 amount) public view returns(uint,uint){
        ERC20 srcToken = ERC20(tokenIDProtocol[srcTokenType]);
        ERC20 desToken = ERC20(tokenIDProtocol[desTokenType]);
        return kyberManger.getExpectedRate(srcToken,desToken,amount);
    }

    // Swap Dai from uniswap
    function swapDai(uint256 tokenType, uint256 amount)
        public
        returns (uint256)
    {
        return uniswapManger.swapDai(amount,_Ower,tokenIDProtocol[tokenType]);
    }

    //Entry Insurance Pool
    function entryInsurancePool(uint256 amount) 
        internal 
    {
        insurePool.depositAmount += amount;
        entryAAVE(100+6,amount);
    }

    
    //entry AAVE
    function entryAAVE(uint256 tokenType,uint256 amount) internal{
        //TODO add liquid
        //Assets do not flow into AAVE temporarily, which will be realized later
    }

    //out AAVE,assets to users
    function outAAVE(address name,uint256 tokenType,uint256 amount) public payable{
        //TODO Take out the asset and return it to the user
        if(msg.sender == _Ower){
            address tokeAddress = tokenIDProtocol[tokenType];
            IERC20 tokenManager = IERC20(tokeAddress);
            tokenManager.transfer(name,amount);
            //Assets do not flow into AAVE temporarily, which will be realized later
        }
    }

    //Withdraw asset
    function withdrawAssets(address name,uint256 tokenType) 
        public
    {
        require(tokenType >= 100 && tokenType <= 106, "not Token!");
        //Match Route
        TokenPool storage pool = matchRoute(tokenType);
        //Out Token Pool
        outTakenPool(pool,name,tokenType);
    }

    //Out Token Pool
    function outTakenPool(
        TokenPool storage pool,
        address    name,
        uint256    tokenType
    ) internal {
        //update Token Pool
        User storage user = pool.users[name];
        require(user.amount > 0,"No assets");
        uint256 newTokenPrice = uniswapManger.getPirce(user.amount,tokenIDProtocol[tokenType]);
        uint256 oldTokenPrice = user.price;
        if(newTokenPrice >= oldTokenPrice){
            //No loss
            outAAVE(user.name,tokenType,mulDiv(user.amount,95,100));
            profitInsurancePool((mulDiv(user.amount,5,100))*oldTokenPrice);
        }else{
            //loss
            uint256 lossMoney = mulDiv(user.amount,95,100)*(oldTokenPrice-newTokenPrice);
            outAAVE(user.name,tokenType,mulDiv(user.amount,95,100));
            lossInsurancePool(user.name,mulDiv(user.amount,5,100)*oldTokenPrice,lossMoney);
        }
        //Update ledger
        pool.tokenAmount -= user.amount;
        pool.userAmount -= 1;
        user.amount = 0;
        user.price = 0;
    }


    //Profit from settlement of insurance pool
    function profitInsurancePool(uint256 deposit) 
        internal 
    {
        insurePool.depositAmount -= deposit;
        insurePool.surplusFundAmount += deposit;
    }

    //Loss on settlement of insurance pool
    function lossInsurancePool(address name,uint256 deposit,uint256 loss) 
        internal 
    {
        if(deposit>=loss){
            uint256 surplusFund = deposit-loss;
            insurePool.depositAmount -= deposit;
            outAAVE(name,100+6,loss);
            require(surplusFund>0);
            insurePool.surplusFundAmount += surplusFund;
        }else{
            uint256 compensation = deposit;
            insurePool.depositAmount -= deposit;
            if (insurePool.surplusFundAmount > 0) {
                //Existing problems: how to express the scale?
                compensation += insurePool.surplusFundAmount * (deposit/insurePool.depositAmount);
                insurePool.surplusFundAmount -= insurePool.surplusFundAmount * (deposit/insurePool.depositAmount);
                if(compensation > loss){
                    compensation = loss;
                    insurePool.surplusFundAmount += (compensation-loss);
                }
            }
            outAAVE(name,100+6,compensation);
        }
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
    
    function checkTokenPoolForUser(address name,uint256 tokenType)
        public
        view
        returns(uint256)
    {
        TokenPool storage pool = tokenPools[tokenType];
         User storage user = pool.users[name];
         return user.amount;
    }


    function mulDiv (uint x, uint y, uint z) public pure returns (uint) {
        return ABDKMathQuad.toUInt (ABDKMathQuad.div (
                ABDKMathQuad.mul (
                ABDKMathQuad.fromUInt (x),
                ABDKMathQuad.fromUInt (y)
                ),
                ABDKMathQuad.fromUInt (z)
            )
        );
    }

}
