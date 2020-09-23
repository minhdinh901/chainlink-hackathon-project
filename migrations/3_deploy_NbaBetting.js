const NbaToken = artifacts.require('NbaToken');
const NbaBetting = artifacts.require('NbaBetting');

module.exports = async function(deployer, network, accounts) {
    //Deploy NbaBetting
    const nbaToken = await NbaToken.deployed();
    await deployer.deploy(NbaBetting, nbaToken.address);
    const nbaBetting = await NbaBetting.deployed();
    await nbaToken.transfer(nbaBetting.address, "1000000000000000000000000");
}