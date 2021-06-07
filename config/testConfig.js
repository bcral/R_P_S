
var Data = artifacts.require("Data");
var Logic = artifacts.require("Logic");
var BigNumber = require('bignumber.js');

var Config = async function(accounts) {
    
    // These test addresses are useful when you need to add
    // multiple users in test scripts
    let testAddresses = [
        "0xcc13ACf34c10B5E2594317f6A7b5dc2dE6Bbe539", // Owner Account
        "0x2C564a478F1100ef817529b4bdfC8627e51C2dfc",
        "0xB7192cc724dd170Ffd0384a2E7D065f895a68a28",
        "0x84947A4B5cEDfB9DBF664A3Aa6d96a9A3fBF7812",
        "0xdB37A445f98b9021E0F7fa8C39f543c49CAc316A"
    ];


    let owner = accounts[0];

    let DataInst = await Data.new();
    let LogicInst = await Logic.new(DataInst.address);
    
    return {
        owner: owner,
        weiMultiple: (new BigNumber(10)).pow(18),
        testAddresses: testAddresses,
        DataInst: DataInst,
        LogicInst: LogicInst,
        logicAddy: LogicInst.address
    }
}

module.exports = {
    Config: Config
};