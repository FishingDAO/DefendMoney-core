pragma solidity ^0.6.0;

import "./UniswapInterface.sol";
import "./IERC20.sol";


/**
 * @title The Utils of Uniswap
 * @author Tao
 */
contract UniswapUtils {
    // ropsten testnet
    address public constant UNISWAP_FACTORY_ADDRESS = 0x9c83dCE8CA20E9aAF9D3efc003b2ea62aBC08351;

    // DAI address
    address public constant DAI_ADDRESS = 0xaD6D458402F60fD3Bd25163575031ACDce07538D;
    

    /**
     * @dev Get UniswapExchange
     * @param _tokenAddress the address token contract
     * @return the address of UniswapExchange
     */ 
    function getUniswapExchange(address _tokenAddress)
        public
        view
        returns (address)
    {
        return
            IUniswapFactory(UNISWAP_FACTORY_ADDRESS).getExchange(_tokenAddress);
    }

    /**
     * @dev ETH=>DAI
     * @param _ethAmount amount of ETH sold
     * @return Amount of DAI bought
     */
    function ethToDai(uint256 _ethAmount) public returns (uint256) {
        return ethToDai(_ethAmount, uint256(1));
    }

    /**
     * @dev ETH=>DAI
     * @param _ethAmount amount of ETH sold
     * @param _minTokenAmount minimum DAI bought
     * @return Amount of DAI bought
     */
    function ethToDai(uint256 _ethAmount, uint256 _minTokenAmount)
        public
        returns (uint256)
    {
        return
            IUniswapExchange(getUniswapExchange(DAI_ADDRESS))
                .ethToTokenSwapInput
                .value(_ethAmount)(_minTokenAmount, uint256(now + 60));
    }

    /**
     * @dev token=>ETH
     * @param _tokenAddress the address of Token contract
     * @param _tokenAmount amount of ERC20 tokens sold
     * @return amount of ETH bought
     */ 
    function tokenToEth(address _tokenAddress, uint256 _tokenAmount)
        public
        returns (uint256)
    {
        return tokenToEth(_tokenAddress, _tokenAmount, uint256(1));
    }

    /**
     * @dev token=>ETH
     * @param _tokenAddress the address of Token contract
     * @param _tokenAmount amount of ERC20 tokens sold
     * @param _minEthAmount minimum ETH bought
     * @return amount of ETH bought
     */ 
    function tokenToEth(
        address _tokenAddress,
        uint256 _tokenAmount,
        uint256 _minEthAmount
    ) internal returns (uint256) {
        address exchange = getUniswapExchange(_tokenAddress);
        IERC20(_tokenAddress).approve(exchange, _tokenAmount);
        return
            IUniswapExchange(exchange).tokenToEthSwapInput(
                _tokenAmount,
                _minEthAmount,
                uint256(now + 60)
            );
    }

    /**
     * @dev token=>DAI
     * @param _tokenAddress the address of Token contract
     * @param _tokenAmount amount of DAI sold
     * @return amount of DAI bought
     */ 
    function tokenToDai(address _tokenAddress, uint256 _tokenAmount)
        public
        returns (uint256)
    {
        return tokenToDai(_tokenAddress, _tokenAmount, uint256(1));
    }

    /**
     * @dev token=>DAI
     * @param _tokenAddress the address of Token contract
     * @param _tokenAmount amount of ERC20 tokens sold
     * @param _minTokenOut minimum ETH bought
     * @return amount of DAI bought
     */ 
    function tokenToDai(
        address _tokenAddress,
        uint256 _tokenAmount,
        uint256 _minTokenOut
    ) public returns (uint256) {
        uint256 ethAmount = tokenToEth(_tokenAddress, _tokenAmount);
        return ethToDai(ethAmount, _minTokenOut);
    }
}
