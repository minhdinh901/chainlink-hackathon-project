const NbaToken = artifacts.require('NbaToken');
const NbaBetting = artifacts.require('NbaBetting');

module.exports = async function(deployer) {
  //Deploy NbaToken
  await deployer.deploy(NbaToken);
  const nbaToken = await NbaToken.deployed();
  //Deploy NbaBetting
  await deployer.deploy(NbaBetting, nbaToken.address);
  const nbaBetting = await NbaBetting.deployed();
  await nbaToken.transfer(nbaBetting.address, "1000000000000000000000000");
}