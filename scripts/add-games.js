const NbaBetting = artifacts.require("NbaBetting");

module.exports = async function(callback) {
  let nbaBetting = await NbaBetting.deployed();

  await nbaBetting.addGames([124848, 124849]);
  console.log("Added games");
  
  callback();
};