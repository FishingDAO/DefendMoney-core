pragma solidity 0.6.5;

/**
 * @title the interface of LendingPoolAddressesProvider 
 */
interface ILendingPoolAddressesProvider {
    // Lending Pool
    function getLendingPool() external view returns (address);
    function setLendingPoolImpl(address _pool) external;
    // Lending Pool Core
    function getLendingPoolCore() external view returns (address payable);
    function setLendingPoolCoreImpl(address _lendingPoolCore) external;
    // Lending Pool Configurator
    function getLendingPoolConfigurator() external view returns (address);
    function setLendingPoolConfiguratorImpl(address _configurator) external;
    // Lending Pool Data Provider
    function getLendingPoolDataProvider() external view returns (address);
    function setLendingPoolDataProviderImpl(address _provider) external;
    // Lending Pool Paramenters Provider
    function getLendingPoolParametersProvider() external view returns (address);
    function setLendingPoolParametersProviderImpl(address _parametersProvider) external;
    // Token Distributor
    function getTokenDistributor() external view returns (address);
    function setTokenDistributor(address _tokenDistributor) external;
    // Fee Provider
    function getFeeProvider() external view returns (address);
    function setFeeProviderImpl(address _feeProvider) external;
    // Lending Pool Liquidation Manager
    function getLendingPoolLiquidationManager() external view returns (address);
    function setLendingPoolLiquidationManager(address _manager) external;
    // Lending Pool Manager
    function getLendingPoolManager() external view returns (address);
    function setLendingPoolManager(address _lendingPoolManager) external;
    // Price Oracle
    function getPriceOracle() external view returns (address);
    function setPriceOracle(address _priceOracle) external;
    // Lending Rate Oracle
    function getLendingRateOracle() external view returns (address);
    function setLendingRateOracle(address _lendingRateOracle) external;
}

/**
 * @title Aave lending pool interface
 */
interface ILendingPool {
    // deposite
    function deposit(address _reserve, uint256 _amount, uint16 _referralCode)
        external;
}