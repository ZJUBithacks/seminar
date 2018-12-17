## Simple demo code

1. Get keys of a state trie from levelDB:

   ```
   node get_keys.js --root <state_trie_root>
   ```

2. Get account infomation from levelDB:

   ```
   node get_account.js --root <state_trie_root> --account <account_address>
   ```

3. store.sol related:

   ```
   // deploy
   node store.js --deploy
   // get method
   node store.js --get --addr <contract_address>
   // set method
   node store.js --set <number> --addr <contract_address>
   ```
