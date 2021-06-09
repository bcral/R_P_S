var Test = require('../config/testConfig.js');
var BigNumber = require('bignumber.js');

contract('Rock Paper Scissors tests', async (accounts) => {

  var config;
  before('setup contract', async () => {
    config = await Test.Config(accounts);
  });

  // Reusable variable - 1 ETH in Wei
  let eth1 = 1000000000000000000;

  /****************************************************************************************/
  /* Operations and Settings                                                              */
  /****************************************************************************************/

  it(`1. setAuthLogic (logic contract control in Data contract) set and checked`, async function () {

    // variable 'logicAddy' in config file is the stored Logic contract address

    // Get operating status
    try {
      await config.DataInst.setAuthLogic(config.logicAddy, {from: config.testAddresses[0]});
    } catch(e) {console.log(e)}

    let result = await config.DataInst.getAuthLogic.call();

    assert.equal(result, config.logicAddy, "setAuthLogic should equal Logic contract address");

  });


  it(`2. First move is played`, async function () {

    // Play first move - 1
    try {
      await config.LogicInst.play(1, {from: config.testAddresses[0], gas: 9999999, value: eth1});
    } catch(e) {console.log(e)}

    let result = await config.DataInst.getBalance.call();

    assert.equal(result, eth1, "Value is stored in Data contract");

  });

  it(`3. Second move is played - resulting in a draw.`, async function () {

    // Play second move - also 1
    try {
      await config.LogicInst.play(1, {from: config.testAddresses[1], gas: 9999999, value: eth1});
    } catch(e) {console.log(e)}

    let result = await config.DataInst.getBonusPool.call();

    assert.equal(result, eth1, "Checks that value(50% of both bets) is stored in BonusPool");

  });

  it(`4. Contract is reset, and new game is played.`, async function () {

    // Play third and fourth move - 1 and 2
    try {
      await config.LogicInst.play(1, {from: config.testAddresses[0], gas: 9999999, value: eth1});
      await config.LogicInst.play(2, {from: config.testAddresses[2], gas: 9999999, value: eth1});
    } catch(e) {console.log(e)}

    let result = await config.DataInst.checkWinnings.call(config.testAddresses[0], {from: config.testAddresses[1]});
              // (pure winnings) + (bonus payout) + (draw returns)
    assert.equal(result, ((eth1 * 2) + (eth1 * 0.25) + (eth1 * 0.5)), "Value stored in player's address's winnings");

  });

  it(`5. Contract should contain all funds sent to it so far(nothing withdrawn)`, async function () {

    // Call test function to check contract's total balance
    let result = await config.DataInst.dataBalance.call();

    assert.equal(result, (eth1 * 4), "Total balance of Data contract");

  });

  it(`6. Contract is reset, and new game is played - Player 1 wins.`, async function () {

    // Play fifth and sixth moves - 2 and 0
    try {
      await config.LogicInst.play(2, {from: config.testAddresses[3], gas: 9999999, value: eth1});
      await config.LogicInst.play(0, {from: config.testAddresses[4], gas: 9999999, value: eth1});
    } catch(e) {console.log(e)}

    let result = await config.DataInst.checkWinnings.call(config.testAddresses[3], {from: config.testAddresses[1]});
              // (pure winnings) + (bonus payout - none available, pool is < 1 ETH)
    assert.equal(result, ((eth1 * 2)), "Value stored in player's address's winnings");

  });

  it(`7. Contract is reset, and new game is played - Player 2 wins`, async function () {

    // Play fifth and sixth moves - 2 and 0
    try {
      await config.LogicInst.play(0, {from: config.testAddresses[0], gas: 9999999, value: eth1});
      await config.LogicInst.play(2, {from: config.testAddresses[4], gas: 9999999, value: eth1});
    } catch(e) {console.log(e)}

    let result = await config.DataInst.checkWinnings.call(config.testAddresses[4], {from: config.testAddresses[1]});
              // (pure winnings) + (bonus payout - none available, pool is < 1 ETH)
    assert.equal(result, ((eth1 * 2)), "Value stored in player's address's winnings");

  });


});