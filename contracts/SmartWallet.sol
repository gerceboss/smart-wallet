//SPDX-License-Identifier:MIT
pragma solidity ^0.8.10;

contract SmartWallet {
    address payable owner;

    struct Guardian {
        address addr;
        uint amount;
        bool access;
    }

    Guardian[] public allowedAddress;
    // mapping(address => Guardian) public allowedMoney;
    event Transaction(uint _amount, address _from, address _to);
    event OwnerChange(address _from, address _to);

    constructor() {
        owner = payable(msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }
    modifier allowedUser() {
        require(
            (getIndex(msg.sender) != (2 ** 256 - 1)) || msg.sender == owner,
            "ask owner to allow you certain amount"
        );
        _;
    }

    function getIndex(address _addr) public view returns (uint) {
        for (uint i = 0; i < allowedAddress.length; i++) {
            if (_addr == allowedAddress[i].addr) {
                return i;
            }
        }
        return (2 ** 256 - 1);
    }

    function allowAccessAndMoney(
        uint _amount,
        address payable _addr
    ) public onlyOwner {
        if (getIndex(_addr) == (2 ** 256 - 1)) {
            Guardian memory g = Guardian(_addr, _amount, true);
            allowedAddress.push(g);
        } else {
            uint z = getIndex(_addr);
            allowedAddress[z].amount = allowedAddress[z].amount + _amount;
        }
    }

    function denyAccess(address payable _addr) public payable  onlyOwner {
        allowedAddress[getIndex(_addr)].access = false;
        uint index = getIndex(_addr);
        Guardian memory temp = allowedAddress[(allowedAddress.length - 1)];
        allowedAddress[(allowedAddress.length - 1)] = allowedAddress[index];
        allowedAddress[index] = temp;
        payable(address(this)).transfer(
            allowedAddress[(allowedAddress.length - 1)].amount
        );
        allowedAddress.pop();
    }

    function depositInWill(uint _amount) public payable allowedUser {
        payable(address(this)).transfer(_amount);
        emit Transaction(_amount, msg.sender, address(this));
    }

    function takeFromWill(uint _amount) public payable allowedUser {
        require(
            address(this).balance >= _amount,
            "not enough balance in the WILL"
        );
        if (msg.sender == owner) {
            emit Transaction(_amount, address(this), owner);
            payable(owner).transfer(_amount);
        } else {
            require(
                allowedAddress[getIndex(msg.sender)].amount >= _amount,
                "you are not allowed to take this much"
            );
            allowedAddress[getIndex(msg.sender)].amount -= _amount;
            emit Transaction(_amount, address(this), msg.sender);
            payable(msg.sender).transfer(_amount);
        }
    }

    function getGuardians() public view onlyOwner returns (Guardian[] memory) {
        return allowedAddress;
    }

    function getGuardianWithAmount(
        address payable _addr
    ) public view onlyOwner returns (Guardian memory) {
        return allowedAddress[getIndex(_addr)];
    }

    function changeOwner(address payable _owner) public onlyOwner {
        emit OwnerChange(owner, _owner);
        owner = _owner;
    }
    receive() external payable{

    }
}
