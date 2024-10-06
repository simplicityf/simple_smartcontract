// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "./BookStore.sol"; // Import the BookStore contract

contract AdvancedBookStore is BookStore {
    uint256 internal requestCount; // incase another contract wants to call this contract.

    struct BookRequest {
        uint256 bookId;
        address student;
    }

    mapping(uint256 => BookRequest) public bookRequests;

    event BookRequested(uint256 indexed requestId, uint256 indexed bookId, address student);

    function initialize() public initializer override{ // it will override the BookStore Contract
        BookStore.initialize(); // Initialize the parent contract
        requestCount = 0; // Initialize request count
    }

    function requestBook(uint256 bookId) public {
        require(bookId > 0 && bookId <= bookCount, "Book does not exist");
        require(books[bookId].copies > 0, "No copies available");

        requestCount++;
        bookRequests[requestCount] = BookRequest({
            bookId: bookId,
            student: msg.sender
        });

        emit BookRequested(requestCount, bookId, msg.sender);
    }

    function getRequest(uint256 requestId) public view returns (uint256 bookId, address student) {
        require(requestId > 0 && requestId <= requestCount, "Request does not exist");
        BookRequest memory req = bookRequests[requestId];
        return (req.bookId, req.student);
    }
}
