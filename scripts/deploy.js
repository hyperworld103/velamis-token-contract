const hre = require("hardhat");

async function main() {

  const Velamis = await hre.ethers.getContractFactory("Velamis");
  const velamisToken = await Velamis.deploy();

  await velamisToken.deployed();

  console.log("velamisToken deployed to:", velamisToken.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
