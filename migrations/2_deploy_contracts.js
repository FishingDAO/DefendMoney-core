const DeFiSafe = artifacts.require("DeFiSafe");

module.exports = function(deployer) {
  deployer.deploy(DeFiSafe);
};
