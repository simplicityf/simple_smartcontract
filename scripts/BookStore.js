const {ethers, upgrades} = require("hardhat");

async function main() {
    const BookStore = await ethers.getContractFactory("BookStore");
    const bookstore = await upgrades.deployProxy(BookStore);



    await bookstore.waitForDeployment();

    const bookstoreAddress = await bookstore.getAddress()
    console.log("My contract is been deployed to ",  bookstoreAddress)


   const AdvancedBookStore = await ethers.getContractFactory("AdvancedBookStore");

   await upgrades.upgradeProxy(bookstoreAddress, AdvancedBookStore);

   console.log("AdvancedBookStore has been upgraded Successfully")
}

main();