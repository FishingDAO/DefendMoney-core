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
    // LINK ropsten testnet address
    address public constant LINK_ADDRESS=0x20fE562d797A42Dcb3399062AE9546cd06f63280;
    // the address of the owner
    address payable public owner;
    
    IERC20 public token=IERC20(0x20fE562d797A42Dcb3399062AE9546cd06f63280);
    

    constructor() public payable {
        owner = msg.sender;
    }
    
    fallback () external payable {}
    
    receive () external payable {}

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
     * @dev Swap ETH from other token
     * 
     * @return Amount of ETH
     */    
    function ethToDai()
        public
        payable
        returns (uint256)
    {
        IUniswapExchange uniswapExchange=IUniswapExchange(getUniswapExchange(DAI_ADDRESS));
        return uniswapExchange.ethToTokenTransferInput.value(msg.value)(1, uint256(now + 600),address(this));
    }
    /**
     * @dev Swap Dai from other token
     * 
     * @param tokens_sold Amount of ERC20 tokens sold
     * @param token_addr Address of output ERC20 token
     * @return Amount of token
     */
   function tokenToDai(uint256 tokens_sold,address token_addr)
       public
       returns(uint256)
    {
        address daiUniswapAddress=getUniswapExchange(DAI_ADDRESS);
        IERC20(DAI_ADDRESS).approve(daiUniswapAddress, tokens_sold);
        return IUniswapExchange(daiUniswapAddress).tokenToTokenTransferInput(tokens_sold, 1,1, uint256(now + 600),address(this),token_addr);
    }
    /**
     * @dev get the price of token(DAI)
     * @param tokens_sold Amount of ERC20 tokens sold
     * @return Amount of DAI that can be bought
     */
    function getPirce(uint256 tokens_sold)
        public
        view
        returns(uint256)
    {
        IUniswapExchange uniswapExchange=IUniswapExchange(getUniswapExchange(DAI_ADDRESS));
        uint256 eth_amount=uniswapExchange.getTokenToEthInputPrice(tokens_sold);
        return uniswapExchange.getEthToTokenInputPrice(eth_amount);
    }
    
}
