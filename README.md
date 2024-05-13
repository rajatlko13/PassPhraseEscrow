<h1>Test Flow</h1>

Once the contract is deployed, perform these steps -

1. Call function getDigestHash() with passphrase param - "hey". It will return the hashed paraphrase.
2. Now execute depositEth() with this hashed paraphrase and specifying the eth amount to lock
3. Switch to another account. Create signature with the hashed paraphrase
4. Execute firstTxn() with the signature obtained
5. Finally execute secondTxn() with passphrase param - "hey". This will release the locked eth amount. Only the original signer can execcute this function.
