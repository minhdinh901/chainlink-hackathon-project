const NbaToken = artifacts.require('NbaToken')

module.exports = async function(deployer, network, accounts) {
  await deployer.deploy(NbaToken);
}
