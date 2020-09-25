require('babel-register');
require('babel-polyfill');
const HDWalletProvider = require('@truffle/hdwallet-provider')
const mnemonic = "blind treat radio layer milk obvious vocal amateur twist balance cousin rigid";
const kovanUrl = "https://kovan.infura.io/v3/c9e496442d2e42ac9d8022e61de8414c";

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*" // Match any network id
    },
    kovan: {
      provider: () => {
        return new HDWalletProvider(mnemonic, kovanUrl)
      },
      network_id: '*',
      // ~~Necessary due to https://github.com/trufflesuite/truffle/issues/1971~~
      // Necessary due to https://github.com/trufflesuite/truffle/issues/3008
      skipDryRun: true,
    },
  },
  contracts_directory: './src/contracts/',
  contracts_build_directory: './src/abis/',
  compilers: {
    solc: {
      optimizer: {
        enabled: true,
        runs: 200
      },
      evmVersion: "petersburg",
      version: "0.6.6"
    }
  }
}
