pragma solidity 0.6.0;

import "./UniswapInterface.sol";
import "./IERC20.sol";


/**
 * @title The Utils of Uniswap
 * @author Tao
 */
contract UniswapUtils {
    // uiswap factory ropsten testnet address
    address public constant UNISWAP_FACTORY_ADDRESS = 0x9c83dCE8CA20E9aAF9D3efc003b2ea62aBC08351;
    // DAI ropsten testnet address
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
     * @param _recipient Address that receives ERC20 tokens
     * @return Amount of DAI bought
     */
    function ethToDai(_recipient) 
        public 
        payable
        returns (uint256) 
    {
        return ethToDai(1,_recipient);
    }

    /**
     * @dev ETH=>DAI
     * @param _minTokenAmount minimum DAI bought
     * @param _recipient Address that receives ERC20 tokens
     * @return Amount of DAI bought
     */
    function ethToDai( uint256 _minTokenAmount,address _recipient )
        public
        payable
        returns (uint256)
    {
        require(msg.value > 0.001 ether);
        IUniswapExchange uniswapExchange=IUniswapExchange(getUniswapExchange(DAI_ADDRESS));
        return uniswapExchange.ethToTokenTransferInput.value(msg.value)(_minTokenAmount, uint256(now + 600),_recipient);
    }
    
    
    function getPirce(uint256 eth_sold)
        public
        view
        returns(uint256)
    {
        IUniswapExchange uniswapExchange=IUniswapExchange(getUniswapExchange(DAI_ADDRESS));
        return uniswapExchange.getEthToTokenInputPrice(eth_sold);
    }
    
}
