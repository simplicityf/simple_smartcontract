// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract BookStore {   
    address public owner;  // address of the owner
    uint256 public bookCount; // numbers of book in store
    uint256 public requestCount; //numbers of requests

    // Added event when books are added
    event BookAdded(uint256 indexed bookId, string title, string author, uint256 copies);
    // Event when books are updated
    event BookUpdated(uint256 indexed bookId, string title, string author, uint256 copies);
    // Events when book are requested
    event BookRequested(uint256 indexed requestId, uint256 indexed bookId, address student);
    //Event when owner update the request status, either pending, approved or declined
    event RequestStatusUpdated(uint256 indexed requestId, string status);

    struct Book { // structuref of how books will be added
        string title;
        string author;
        uint256 copies;
    }

    struct BookRequest { //structure of how books will be requested
        uint256 bookId;
        address student;
        RequestStatus status; //enums for request status
    }

    enum RequestStatus {//This is for the request status
        Pending,
        Approved,
        Rejected
    }

    mapping(uint256 => Book) public books; //mapping book id to get access to books
    mapping(uint256 => BookRequest) public bookRequests; //mapping request id to view requests

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action"); //only owners can add book and update book and request status
        _;
    }

    constructor() {
        owner = msg.sender;
        bookCount = 0;
        requestCount = 0;
    }

    function addBook(string memory _title, string memory _author, uint256 _copies) public onlyOwner {
        bookCount++;
        books[bookCount] = Book({ title: _title, author: _author, copies: _copies });
        emit BookAdded(bookCount, _title, _author, _copies); //emit an event when books are added
    }

    function updateBook(uint256 bookId, string memory _title, string memory _author, uint256 _copies) public onlyOwner {
        require(bookId > 0 && bookId <= bookCount, "Book does not exist"); //throw an error if book id is not among the list of books
        books[bookId] = Book({ title: _title, author: _author, copies: _copies });
        emit BookUpdated(bookId, _title, _author, _copies);
    }

    function getBook(uint256 bookId) public view returns (string memory title, string memory author, uint256 copies) {
        require(bookId > 0 && bookId <= bookCount, "Book does not exist");
        Book memory book = books[bookId];
        return (book.title, book.author, book.copies);
    }

    function requestBook(uint256 bookId) public {
        require(bookId > 0 && bookId <= bookCount, "Book does not exist");
        require(books[bookId].copies > 0, "No copies available");

        requestCount++;
        bookRequests[requestCount] = BookRequest({
            bookId: bookId,
            student: msg.sender,
            status: RequestStatus.Pending
        });

        emit BookRequested(requestCount, bookId, msg.sender);
    }

    function updateRequestStatus(uint256 requestId, RequestStatus status) public onlyOwner { 
        require(requestId > 0 && requestId <= requestCount, "Request does not exist");
        bookRequests[requestId].status = status;
        emit RequestStatusUpdated(requestId, status == RequestStatus.Approved ? "Approved" : "Rejected");
    }

    function getRequest(uint256 requestId) public view returns (uint256 bookId, address student, RequestStatus status) { 
        require(requestId > 0 && requestId <= requestCount, "Request does not exist"); //if not request is input
        BookRequest memory req = bookRequests[requestId];
        return (req.bookId, req.student, req.status); //returns the list of books requested. To check the list of books requested you have to access them by there id
    }

    function getAllBooks() public view returns (string[] memory titles, string[] memory authors) { // returns an array that holds all titles and authors from books, you can access them by their id
        titles = new string[](bookCount);
        authors = new string[](bookCount);
        for (uint256 i = 1; i <= bookCount; i++) { // 1 because we need to start with 1 (1 + 1 +...)
            titles[i - 1] = books[i].title;
            authors[i - 1] = books[i].author; 
        }
    }
}
