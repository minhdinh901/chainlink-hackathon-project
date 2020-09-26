const NbaToken = artifacts.require("NbaToken");
const NbaBetting = artifacts.require("NbaBetting");

module.exports = async function(deployer, network, accounts) {
  const nbaToken = await NbaToken.deployed();
  await deployer.deploy(NbaBetting, nbaToken.address);
  const nbaBetting = await NbaBetting.deployed();
  await nbaToken.transfer(nbaBetting.address, "999999999999999999999900");
  await nbaToken.transfer(accounts[1], "100");
};
