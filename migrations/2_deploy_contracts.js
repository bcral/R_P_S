const Data = artifacts.require("Data");
const Logic = artifacts.require("Logic");
const fs = require('fs');

module.exports = function(deployer) {
  deployer.deploy(Data)
  .then(() => {
      return deployer.deploy(Logic, Data.address)
              .then(() => {
                  let config = {
                      localhost: {
                          url: 'http://localhost:8545',
                          dataAddress: Data.address,
                          logicAddress: Logic.address
                      }
                  }
                  fs.writeFileSync(__dirname + '/../vapp/src/contracts.json',JSON.stringify(config, null, '\t'), 'utf-8');
              });
  });
};
