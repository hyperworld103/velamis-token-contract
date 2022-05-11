require("@nomiclabs/hardhat-waffle");
require('hardhat-deploy');
require('@nomiclabs/hardhat-ethers');
require("@nomiclabs/hardhat-etherscan");
const fs = require('fs');
const projectId = "e27fa5472f26967c3f445b1e";
const privateKey ="0000000000000000000000000000000000000000000000000000000000000000";

const apiKeyForBscscan = "5YWE9Y6JAYQJ937Y16PT4I61644FSMBZ7P";

module.exports = {
  // defaultNetwork: "rinkeby",
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      // chainId: 4 //ethereum
      chainId: 97, //Binance Smart Chain Testnet
      // chainId: 97, //ethereum
    },
    polygonmainnet: {
      url: `https://speedy-nodes-nyc.moralis.io/${projectId}/polygon/mainnet`,
      accounts: [privateKey]
    },
    mumbai: {
      url: `https://speedy-nodes-nyc.moralis.io/${projectId}/polygon/mumbai`,
      accounts: [privateKey]
    },
    ethermainnet: {
      url: `https://speedy-nodes-nyc.moralis.io/${projectId}/eth/mainnet`,
      accounts: [privateKey]
    },
    kovan: {
      url: `https://speedy-nodes-nyc.moralis.io/${projectId}/eth/kovan`,
      accounts: [privateKey]
    },
    rinkeby: {
      url: `https://speedy-nodes-nyc.moralis.io/${projectId}/eth/rinkeby`,
      accounts: [privateKey]
    },
    goerli: {
      url: `https://speedy-nodes-nyc.moralis.io/${projectId}/eth/goerli`,
      accounts: [privateKey]
    },
    bscmainnet: {
      url: `https://speedy-nodes-nyc.moralis.io/${projectId}/bsc/mainnet`,
      accounts: [privateKey]
    },
    bsctestnet: {
      url: `https://speedy-nodes-nyc.moralis.io/${projectId}/bsc/testnet`,
      accounts: [privateKey],
      gasPrice: 50000000000
    }
  },
  paths:{
    sources: "./contracts",
    artifacts: "./artifacts"
  },
  etherscan: {
    apiKey: apiKeyForBscscan
  },
  solidity: {
    compilers: [
      {
      	version: "0.8.10",
      	settings: {
      		optimizer: {
      			enabled: true,
      			runs: 200,
      		},
      	}
      },
      // {
      // 	version: "0.4.17",
      // 	settings: {
      // 		optimizer: {
      // 			enabled: true,
      // 			runs: 200,
      // 		},
      // 	}
      // },
      // {
      // 	version: "0.5.16",
      // 	settings: {
      // 		optimizer: {
      // 			enabled: true,
      // 			runs: 200,
      // 		},
      // 	}
      // },
      {
      	version: "0.8.4",
      	settings: {
      		optimizer: {
      			enabled: true,
      			runs: 200,
      		},
      	}
      },
      {
        version: "0.7.6",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        }
      },
    ],
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  // solidity: "0.7.6",
};
