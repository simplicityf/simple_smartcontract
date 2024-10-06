const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

describe("BookStore and AdvancedBookStore", function () { //deploying our 2 contracts
  let bookstore; //first contract
  let advancedBookstore; //second contract
  let owner; // the owner

  beforeEach(async () => {
    [owner] = await ethers.getSigners(); //The beforeEach hook deploys a new instance of BookStore before each test, ensuring a clean state
    
    // Deploy BookStore
    const BookStore = await ethers.getContractFactory("BookStore");
    bookstore = await upgrades.deployProxy(BookStore);
    await bookstore.waitForDeployment();
  });

  it("should deploy BookStore correctly", async () => {
    expect(await bookstore.owner()).to.equal(owner.address);
    expect(await bookstore.bookCount()).to.equal(0);
  });

  it("should add a book", async () => {
    await bookstore.addBook("Structs", "Ethereum", 5);
    
    const book = await bookstore.getBook(1);
    expect(book.title).to.equal("Structs");
    expect(book.author).to.equal("Ethereum");
    expect(book.copies).to.equal(5);
  });

  it("should upgrade to AdvancedBookStore", async () => {
    const AdvancedBookStore = await ethers.getContractFactory("AdvancedBookStore");
    const bookstoreAddress = await bookstore.getAddress()
    // Upgrade the proxy to AdvancedBookStore
    advancedBookstore = await upgrades.upgradeProxy(bookstoreAddress, AdvancedBookStore);
    await advancedBookstore.waitForDeployment();

    // Check if the requestCount is initialized correctly
    expect(await advancedBookstore.requestCount()).to.equal(0);
  });

  it("should request a book", async () => {
    /// First, add a book
    await bookstore.addBook("Enums", "Solidity", 3);

    // Upgrade to AdvancedBookStore before requesting
    const AdvancedBookStore = await ethers.getContractFactory("AdvancedBookStore");

    const bookstoreAddress = await bookstore.getAddress()

    advancedBookstore = await upgrades.upgradeProxy(bookstoreAddress, AdvancedBookStore);
    await advancedBookstore.waitForDeployment();

    // Request the book
    await advancedBookstore.requestBook(1); // requesting the book with ID 1

    // Check if the request was successful
    const request = await advancedBookstore.getRequest(1);
    expect(request.bookId).to.equal(1);
    expect(request.student).to.equal(owner.address);
  });

  it("should fail to request a non-existent book", async () => {
    await expect(advancedBookstore.requestBook(9)).to.be.revertedWith("Book does not exist");
  });
});
