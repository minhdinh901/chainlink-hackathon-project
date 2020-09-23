const NbaToken = artifacts.require('NbaToken');

module.exports = async function(deployer, network, accounts) {
  //Deploy NbaToken
  await deployer.deploy(NbaToken);
  const nbaToken = await NbaToken.deployed();
}