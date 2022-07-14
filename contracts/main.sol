// SPDX-License-Identifier:MIT

pragma solidity ^0.8.7;

interface ICounter {
    function list_of_All_participants()
        external
        view
        returns (address[] memory);

    function getAdmin() external view returns (address);
}

contract Main {
    event Deposit(address indexed sender, uint256 amount);
    event Submit(uint256 indexed txId);
    event Approve(address indexed owner, uint256 indexed txId);
    event Revoke(address indexed owner, uint256 indexed txId);
    event Execute(uint256 indexed txId);

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    address[] participants;
    mapping(address => bool) public isSignatory;
    uint256 required;

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
    }

    Transaction[] public transactions;
    mapping(uint256 => mapping(address => bool)) public approved;

    function getParticipants(address _admincontract)
        public
        view
        returns (address[] memory)
    {
        return ICounter(_admincontract).list_of_All_participants();
    }

    function getadmin(address _admincontract) public view returns (address) {
        return ICounter(_admincontract).getAdmin();
    }

    modifier onlyOwner() {
        require(
            isSignatory[msg.sender] == true,
            "only owner can access to this"
        );
        _;
    }

    modifier txExist(uint256 _txId) {
        require(_txId < transactions.length, "transaction id does not exist");
        _;
    }

    modifier notApproved(uint256 _txId) {
        require(!approved[_txId][msg.sender], "tx already approved");
        _;
    }

    modifier notExecuted(uint256 _txId) {
        require(
            transactions[_txId].executed,
            "transaction is already executed"
        );
        _;
    }

    constructor(address _admincontract) {
        participants = getParticipants(_admincontract);
        required = 60 * participants.length;
        required = required / 100;
        require(
            required > 0,
            "no of required candidate not satisfy minimu condition"
        );
        for (uint256 i = 0; i < participants.length; i++)
            isSignatory[participants[i]] = true;
    }

    function submit(
        address _to,
        uint256 _value,
        bytes calldata _data
    ) external onlyOwner {
        transactions.push(
            Transaction({to: _to, value: _value, data: _data, executed: false})
        );
        emit Submit(transactions.length - 1);
    }

    function approve(uint256 _txId)
        external
        onlyOwner
        txExist(_txId)
        notApproved(_txId)
        notExecuted(_txId)
    {
        approved[_txId][msg.sender] = true;
        emit Approve(msg.sender, _txId);
    }

    function countOfapproved(uint256 _txid)
        private
        view
        returns (uint256 count)
    {
        for (uint256 i; i < participants.length; i++) {
            if (approved[_txid][participants[i]]) {
                count += 1;
            }
        }
    }

    function execute(uint256 _txId) external txExist(_txId) notExecuted(_txId) {
        require(
            countOfapproved(_txId) >= required,
            "you have not require amount of approval"
        );
        Transaction storage transaction = transactions[_txId];

        transaction.executed = true;
        (bool success, ) = transaction.to.call{value: transaction.value}(
            transaction.data
        );

        require(success, "tx failed");
    }

    function revoke(uint256 _txId)
        external
        onlyOwner
        txExist(_txId)
        notApproved(_txId)
        notExecuted(_txId)
    {
        approved[_txId][msg.sender] = false;
        emit Revoke(msg.sender, _txId);
    }
}
