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


  // it(`2. First move is played`, async function () {

  //   // Play first move - 1
  //   try {
  //     await config.LogicInst.play(1, {from: config.testAddresses[0], value: eth1});
  //   } catch(e) {console.log(e)}

  //   let result = await config.DataInst.getBalance.call();

  //   assert.equal(result, eth1, "Value is stored in Data contract");

  // });

  // it(`3. Second move is played - resulting in a draw.`, async function () {

  //   // Play second move - also 1
  //   try {
  //     await config.LogicInst.play(1, {from: config.testAddresses[0], value: eth1});
  //   } catch(e) {console.log(e)}

  //   let result = await config.DataInst.getBonusPool.call();

  //   assert.equal(result, eth1, "Checks that value(50% of both bets) is stored in BonusPool");

  // });

  it(`4. Contract is reset for new game`, async function () {

    // Play third move - 0
    try {
      await config.LogicInst.play(0, {from: config.testAddresses[0], value: eth1});
      await config.LogicInst.play(2, {from: config.testAddresses[1], gas: 9999999, value: eth1});
    } catch(e) {console.log(e)}

    let result = await config.DataInst.checkWinnings.call(config.testAddresses[1]);

    assert.equal(result, ((eth1 * 2) + (eth1 * 0.25)), "Value stored in player's address's winnings");

  });

  it(`5. Contract should contain all funds sent to it so far(nothing withdrawn)`, async function () {

    // Call test function to check contract's total balance
    let result = await config.DataInst.dataBalance.call();

    assert.equal(result, (eth1 * 4), "Total balance of Data contract");

  });

  it(`6. Second player should have funds ready to withdraw`, async function () {

    // Call test function to check contract's total balance
    let result = await config.DataInst.checkWinnings.call(config.testAddresses[1]);

    assert.equal(result, ((eth1 * 2) + (eth1 * 0.25)), "Value stored in player's address's winnings");

  });

});