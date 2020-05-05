pragma solidity >=0.5.0 <0.7.0;

contract DeFiSafe {

    /*
    协议规则-tokenID:
    100+0 -> Eth
    100+1 -> Link
    100+2 -> Knc
    100+3 -> Zrx
    100+4 -> Snx
    100+5 -> Lend
    */

    //用户
    struct User {
        address     name;
        uint        tokenID;
        uint256     amount;
        uint        price;
    }

    //token池
    struct TokenPool {
        uint        tokenID;
        uint256     tokenAmount;
        uint        userAmount;
        mapping(address => User) users;
    }

    //token池管理
    mapping (uint => TokenPool) tokenPools;
    uint public tokenTotal;

    //投保池定义
    struct InsurePool {
        //投保金总额
        uint    depositAmount;
        //盈余资金总额
        uint    surplusFundAmount;
    }
    InsurePool public insurePool;

    constructor() public {
        tokenTotal = 6;
        for (uint i = 0; i < tokenTotal; i++) {
                tokenPools[100+i] = TokenPool({
                tokenID: 100+i,
                tokenAmount: 0,
                userAmount: 0
            });
        }
        insurePool = InsurePool({
            depositAmount: 0,
            surplusFundAmount: 0
        });
    }

    /*
    输入函数
    作用：读取用户资产。
    参数：
    1. 地址
    2. 类型
    3. 数量
    */
    function inputAsset(address name,uint tokenType,uint amount) public  {
        require(tokenType>=100 && tokenType <= 106,"not Token!");
        require(amount > 0,"Too few assets");
        //匹配路由
        TokenPool storage pool = matchRoute(tokenType);
        //资产入账
        assetEntryBook(pool,name,tokenType,amount);
    }

    /*
    获取token池资产信息函数
    作用：前端展示信息调用
    参数：
    1. 类型
    返回值：
    1. 数量
    */
    function checkTokenPoolInfo(uint tokenType) public view returns (uint256) {
        TokenPool storage pool = tokenPools[tokenType];
        return pool.tokenAmount;
    }
    
    /*
    资产匹配路由函数
    作用：结合输入函数中的信息，匹配到对应的token资金池，输入到对应的token资金池
    参数：
    1. 类型
    */
    function matchRoute(uint tokenType) internal returns (TokenPool memory){
        return tokenPools[tokenType];
    }

    /*
    token资金池
    作用：记账本的作用，记录当前对应token的总量，以及用户信息，以及对应用户的资产价格快照
    参数：
    1. 对应的token记账本
    1. 地址
    2. 类型
    3. 数量
    */
    function assetEntryBook(TokenPool pool,address name,uint tokenType,uint amount) internal {
        //记账
        pool.tokenAmount += amount;
        pool.userAmount += 1;
        User storage user = pool.users[name];
        user.name = name;
        user.tokenID = tokenType;
        user.amount = amount;
        user.price = getTokenPrice(tokenType);
        //开始分配资产
        assetsEnterInsurancePool(swapDai(tokenType,amount*0.05));
        assetsEnterUniSwap(tokenType,amount*0.95);
    }

    /*
    uniswap
    作用：用户资产95%流入uniswap
    参数：
    1. 类型
    2. 数量
    */
    function assetsEnterUniSwap(uint tokenType,uint amount) internal {
        //uniswap 添加流动性
    }


     /*
    投保池
    作用：盈余资金的记录与存储
    参数：
    1. 数量
    */
    function assetsEnterInsurancePool(uint amount) internal{
        insurePool.depositAmount += amount;
        assetsEnterAAVE(amount);
    }

    /*
    AAVE添加流动性
    作用：AAVE添加流动性
    参数：
    1. 数量(Dai)
    */
    function assetsEnterAAVE(uint amount) {
        //调取外部接口
    }

    /*
    获取快照数据（数据来源ChainLink）
    作用：获取当前对应Token的市场价格
    参数：
    1. 类型
    */
    function getTokenPrice(uint tokenType) public returns(uint){
        //调取外部接口
        return 10;//测试数据
    }

    /*
    代币交换 token-Dai
    作用：转换成稳定币
    参数：
    1. 类型
    2. 数量
    */
    function swapDai(uint tokenType,uint amount) public returns(uint){
        //调取外部接口
        return 10;//测试数据
    }


    /*
    输出函数
    作用：用户结算
    参数：
    1. 地址
    2. 类型
    */
    

    /*
    获取当前盈余资金函数
    作用：内部使用，不对外展示
    返回值：
    1. 数量(Dai )
    */

}