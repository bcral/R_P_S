import dataAddress from './contracts.json'
import logicAddress from './contracts.json'

const options = {
  web3: {
    block: false,
    fallback: {
      type: 'ws',
      url: 'ws://127.0.0.1:9545'
    }
  },
  contracts: [dataAddress, logicAddress],
  events: {

  },
  polls: {
    accounts: 10
  }
}

export default options
