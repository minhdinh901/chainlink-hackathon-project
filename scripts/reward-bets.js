const NbaBetting = artifacts.require("NbaBetting");

module.exports = async function(callback) {
  let nbaBetting = await NbaBetting.deployed();

  await nbaBetting.rewardBets(0, 1);
  console.log("Rewarded betters");
  
  callback();
};