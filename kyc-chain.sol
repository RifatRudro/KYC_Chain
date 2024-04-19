pragma solidity ^0.8.0;

contract ThreeBankSystem {
    address public publicBank;
    address public privateBank;
    address public centralBank;

    struct Transaction {
        address from;
        address to;
        uint256 amount;
        uint256 date;
        address fromBank;
        address toBank;
    }

    mapping(address => Transaction[]) public accountTransactions; // Updated mapping to store transactions for each account

    struct Account {
        uint256 balance;
        bool exists;
    }

    mapping(address => mapping(address => Account)) public accounts;
    mapping(address => address[]) public bankAccounts;

    event AccountCreated(address bank, address accountAddress);
    event Transfer(address from, address to, uint256 amount);
    event Deposit(address account, uint256 amount);

    constructor(address _privateBank, address _centralBank) {
        publicBank = msg.sender;
        privateBank = _privateBank;
        centralBank = _centralBank;
    }

    modifier onlyPublicBank() {
        require(msg.sender == publicBank, "Only the public bank can call this function.");
        _;
    }

    modifier onlyPrivateBank() {
        require(msg.sender == privateBank, "Only the private bank can call this function.");
        _;
    }

    modifier onlyCentralBank() {
        require(msg.sender == centralBank, "Only the central bank can call this function.");
        _;
    }

    function createAccount(address bank, address accountAddress) public {
        require(bank == publicBank || bank == privateBank, "Invalid bank address.");

        require(!accounts[bank][accountAddress].exists, "Account already exists.");

        accounts[bank][accountAddress] = Account(0, true);
        bankAccounts[bank].push(accountAddress);

        emit AccountCreated(bank, accountAddress);
    }

    function deposit(address bank, uint256 amount) public {
        require(accounts[bank][msg.sender].exists, "Account does not exist.");

        accounts[bank][msg.sender].balance += amount;

        emit Deposit(msg.sender, amount);
    }
function transfer(address fromBank, address toBank, address to, uint256 amount) public {
    require(accounts[fromBank][msg.sender].balance >= amount, "Insufficient balance.");

    // Check if total amount of transactions exceeds 3000
    (, , uint256 totalAmount, ) = getTransactionsForAccount(msg.sender);
    require(totalAmount + amount <= 3000, "Total amount of transactions exceeds limit.");

    accounts[fromBank][msg.sender].balance -= amount;
    accounts[toBank][to].balance += amount;

    emit Transfer(msg.sender, to, amount);
    
    // Record transaction details for sender's account
    accountTransactions[msg.sender].push(Transaction(msg.sender, to, amount, block.timestamp, fromBank, toBank));
}


    function getBalance(address bank, address accountAddress) public view returns (uint256) {
        require(accounts[bank][accountAddress].exists, "Account does not exist.");

        return accounts[bank][accountAddress].balance;
    }

    function getAccountsUnderBank(address bank) public view returns (address[] memory) {
        return bankAccounts[bank];
    }

function getTransactionsForAccount(address accountAddress) public view returns (
    uint256 count,
    Transaction[] memory ,
    uint256 totalAmount,
    uint256 numLargeTransactions
) {
    Transaction[] memory allTransactions = accountTransactions[accountAddress];
    uint256 transactionCount = allTransactions.length;
    uint256 largeTransactionCount = 0;
    uint256 totalAmountTransactions = 0;

    // Loop through all transactions
    for (uint256 i = 0; i < transactionCount; i++) {
        Transaction memory transaction = allTransactions[i];

        // Add transaction amount to total amount
        totalAmountTransactions += transaction.amount;

        // Check if transaction amount exceeds 500
        if (transaction.amount > 500) {
            largeTransactionCount++;
        }
    }

    return (transactionCount, allTransactions, totalAmountTransactions, largeTransactionCount);
}


}
