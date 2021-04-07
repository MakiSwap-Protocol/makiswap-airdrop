# makiswap-airdrop
Repository containing the airdrop smart contract for UniLayer holders to claim their MAKI.

MakiDistributor Test Output

#token
    ✓ returns the token address (95ms)

#merkleRoot
    ✓ returns the zero merkle root (74ms)

#claim
    ✓ fails for empty proof (90ms)
    ✓ fails for invalid index (84ms)
    two account tree
    ✓ successful claim (141ms)
    ✓ transfers the token (82ms)
    ✓ must have enough to transfer (116ms)
    ✓ sets #isClaimed (120ms)
    ✓ cannot allow two claims (84ms)
    ✓ cannot claim more than once: 0 and then 1 (132ms)
    ✓ cannot claim more than once: 1 and then 0 (112ms)
    ✓ cannot claim for address other than proof
    ✓ cannot claim more than proof
    ✓ gas (50ms)
    larger tree
    ✓ claim index 4 (48ms)
    ✓ claim index 9 (51ms)
    ✓ gas (53ms)
    ✓ gas second down about 15k (92ms)
    realistic size tree
    ✓ proof verification works
    ✓ gas (53ms)
    ✓ gas deeper node (53ms)
    ✓ gas average random distribution (1389ms)
    ✓ gas average first 25 (1298ms)
    ✓ no double claims in random distribution (77ms)

parseBalanceMap
    ✓ check the proofs is as expected
    ✓ all claims work exactly once (242ms)
    ✓ all claims work exactly once (242ms)

26 passing (9s)

✨  Done in 31.64s.