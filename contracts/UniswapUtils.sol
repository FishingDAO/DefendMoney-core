pragma solidity ^0.6.0;

import "./UniswapInterface.sol";
import "./IERC20.sol";

/**
 * The Utils of Uniswap
 *
 * @auther Tao
 */
contract UniswapUtils{
    // ropsten testnet
    address constant UniswapFactoryAddress= 0x9c83dCE8CA20E9aAF9D3efc003b2ea62aBC08351;

    // DAI address
    address constant DaiAddress = 0x2448eE2641d78CC42D7AD76498917359D961A783;

    // Get UniswapExchange
    function getUniswapExchange(address tokenAddress) public view returns(address){
        return IUniswapFactory(UniswapFactoryAddress).getExchange(tokenAddress);
    }
    
    // ETH=>DAI
    function ethToDai(uint ethAmount)
        public returns (uint) {
        return ethToDai(ethAmount, uint(1));
    }

    // ETH=>DAI
    function ethToDai( uint ethAmount, uint minTokenAmount)
        public returns (uint) {
        return IUniswapExchange(getUniswapExchange(DaiAddress))
            .ethToTokenSwapInput.value(ethAmount)(minTokenAmount, uint(now + 60));
    }
    
    // token=>ETH
    function tokenToEth(address tokenAddress, uint tokenAmount) public returns (uint) {
        return tokenToEth(tokenAddress, tokenAmount, uint(1));
    }

    // token=>ETH
    function tokenToEth(address tokenAddress, uint tokenAmount, uint minEthAmount) internal returns (uint) {
        address exchange = getUniswapExchange(tokenAddress);
        IERC20(tokenAddress).approve(exchange, tokenAmount);
        return IUniswapExchange(exchange)
            .tokenToEthSwapInput(tokenAmount, minEthAmount, uint(now + 60));
    }    
    
    // token=>DAI
    function tokenToDai(address tokenAddress,  uint tokenAmount) public returns (uint) {
        return tokenToDai(tokenAddress, tokenAmount, uint(1));
    }
    
    // token=>DAI
    function tokenToDai(address tokenAddress, uint tokenInAmount, uint minTokenOut) public returns (uint) {
        uint ethAmount = tokenToEth(tokenAddress, tokenInAmount);
        return ethToDai( ethAmount, minTokenOut);
    }
    
}