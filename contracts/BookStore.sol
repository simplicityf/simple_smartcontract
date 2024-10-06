// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract BookStore is Initializable { //the contract inherit Initializable from the openzepplln
    address internal owner; //only accessible to contract calling this contract
    uint256 internal bookCount;

    struct Book {
        string title;
        string author;
        uint256 copies;
    }

    mapping(uint256 => Book) public books;

    event BookAdded(uint256 indexed bookId, string title, string author, uint256 copies);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    // we make it virtual so the AdvanceBookStore can override the function
    function initialize() public initializer virtual{ //instead of using constructor, use initialize to make the contracts compatible with the upgradeable pattern provided by OpenZeppelin,
    // the initialize also acts the same way as the constructor
        owner = msg.sender;
        bookCount = 0;
    }

    function addBook(string memory _title, string memory _author, uint256 _copies) public onlyOwner {
        bookCount++;
        books[bookCount] = Book({
            title: _title,
            author: _author,
            copies: _copies
        });
        emit BookAdded(bookCount, _title, _author, _copies);
    }

    function getBook(uint256 bookId) public view returns (string memory title, string memory author, uint256 copies) {
        require(bookId > 0 && bookId <= bookCount, "Book does not exist");
        Book memory book = books[bookId];
        return (book.title, book.author, book.copies);
    }
}
