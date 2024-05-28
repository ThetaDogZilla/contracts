# DogZilla (DOGZ) on Theta Network

<img src="./img/dogzilla.png" alt="DogZilla" width="350"/>

## Setup

Prerequisites:
* Git
* Node
* NPM

To install NPM dependencies:

```
npm install
```

## Contracts 

### TNT-20 Token 

TNT-20 token is based on Openzeppelin library.
To read TNT-20 Token:

```
node scripts/read_token.js
```

Output

```bash
Balance of DogZilla in mint wallet: 0 DogZilla (wei)
Max Supply: 1000000000 DogZilla (wei)
Total Supply: 900000000 DogZilla (wei)
Name: DogZilla
Symbol: DOGZ
```

### Token vesting

Cliff token vesting contract is taken form [AbdelStark](https://github.com/AbdelStark/token-vesting-contracts). 

This is an audited contract. The report can be found [here](https://github.com/AbdelStark/token-vesting-contracts/blob/main/audits/hacken_audit_report.pdf)

To read the vested contract:

```
node scripts/vesting/read_contract.js
```
Output

```bash
==========================================================================
Token Vesting contract
==========================================================================

Associated token address: 0x7B292F1EA85155EDC2fe9703E938d569DEd33db2
Vesting total amount: 680000000 DOGZ
Vesting count: 5

==========================================================================
Token Vesting at index [0]: Core Team Wallet
==========================================================================

Vesting ID: 0x4de0c7ddf76e277dd16d71b1f6a43688f08181c3a717c644c320af4f860ba0c1
Vesting releasable amount: 0 DOGZ
Beneficiary:  0x81b67d9e832126bA5e8301795047B34d7feE3793
Initial vesting period:  31/3/2024, 09:00:00
Vesting duration:  48 Months
Time between each release:  3 Months
Revocable:  false
Total amount: 150000000 DOGZ
Released: 0 DOGZ
Revoked:  false

==========================================================================
Token Vesting at index [1]: Marketing Wallet
==========================================================================

Vesting ID: 0x573149ab5388fc9b38f5ea7a18951abd450a3a29813e30634719e5c78c22de52
Vesting releasable amount: 0 DOGZ
Beneficiary:  0xD3cf594B3c1f624ed19D39E2b5a64E7CaD47A436
Initial vesting period:  31/3/2024, 09:00:00
Vesting duration:  48 Months
Time between each release:  3 Months
Revocable:  false
Total amount: 200000000 DOGZ
Released: 0 DOGZ
Revoked:  false

==========================================================================
Token Vesting at index [2]: Platform Wallet
==========================================================================

Vesting ID: 0x0356cd8e78ab362147b79b9c05cb90dad594b27001f02fcc91d7f9af739c89df
Vesting releasable amount: 0 DOGZ
Beneficiary:  0x98b7782740bdf4A00792B826701E43E4c807b715
Initial vesting period:  31/3/2024, 09:00:00
Vesting duration:  12 Months
Time between each release:  12 Months
Revocable:  false
Total amount: 230000000 DOGZ
Released: 0 DOGZ
Revoked:  false

==========================================================================
Token Vesting at index [3]: DEX Liquidity Pool (TDROP)
==========================================================================

Vesting ID: 0x8c440c572c6212ba68c310f615f001b83e685b3aa53777fd71ca86cd5d0e6bf5
Vesting releasable amount: 0 DOGZ
Beneficiary:  0x111b3743c905B4D1Cc10BEeF9bD86c909a443e70
Initial vesting period:  31/3/2024, 09:00:00
Vesting duration:  1 Months
Time between each release:  1 Months
Revocable:  false
Total amount: 40000000 DOGZ
Released: 0 DOGZ
Revoked:  false

==========================================================================
Token Vesting at index [4]: DEX Liquidity Pool (OTHERS)
==========================================================================

Vesting ID: 0xeed8e0d7f09c4eb6fb3e3091d8286f047cb1751836dbec2bc205e77e9173c881
Vesting releasable amount: 0 DOGZ
Beneficiary:  0x111b3743c905B4D1Cc10BEeF9bD86c909a443e70
Initial vesting period:  31/3/2024, 09:00:00
Vesting duration:  2 Months
Time between each release:  2 Months
Revocable:  false
Total amount: 60000000 DOGZ
Released: 0 DOGZ
Revoked:  false
```

To read all OTC vested contracts:
```
node scripts/vesting/read_otc_contract.js
```

Output

```bash
==========================================================================
OTC Token Vesting contract
==========================================================================

Associated token address: 0x7B292F1EA85155EDC2fe9703E938d569DEd33db2
Vesting total amount: 28825000 DOGZ
Vesting count: 7

==========================================================================
Token Vesting at index [0]: OTC Wallet 1
==========================================================================

Vesting ID: 0x580f42b0e17cd0f16a6e8c1088cbd40c8270ee226cb2fbf174e68812bc2d3f7c
Vesting releasable amount: 0 DOGZ
Beneficiary:  0x0aA03f65C0f2C4e036759afDbafCA3dA825fa708
Initial vesting period:  31/3/2024, 09:00:00
Vesting duration:  9 Months
Time between each release:  3 Months
Revocable:  true
Total amount: 1875000 DOGZ
Released: 0 DOGZ
Revoked:  false

==========================================================================
Token Vesting at index [1]: OTC Wallet 2
==========================================================================

Vesting ID: 0xa2249dbdde4e48ab699c17c533ff9075dbd3b5d957132e4330f6498a096f246d
Vesting releasable amount: 0 DOGZ
Beneficiary:  0xaDEFcc8bAEd865Ad22F20CBd5f358CF0013df43F
Initial vesting period:  31/3/2024, 09:00:00
Vesting duration:  6 Months
Time between each release:  6 Months
Revocable:  true
Total amount: 2500000 DOGZ
Released: 0 DOGZ
Revoked:  false

==========================================================================
Token Vesting at index [2]: OTC Wallet 3
==========================================================================

Vesting ID: 0x535c217ce6180d9fd515a09efeec6153d490fb4de4a85d63070d074d550c3c4e
Vesting releasable amount: 0 DOGZ
Beneficiary:  0x1b1CE5e254d36F701907bB630304ab20A7361259
Initial vesting period:  31/3/2024, 09:00:00
Vesting duration:  9 Months
Time between each release:  3 Months
Revocable:  true
Total amount: 7500000 DOGZ
Released: 0 DOGZ
Revoked:  false

==========================================================================
Token Vesting at index [3]: OTC Wallet 4
==========================================================================

Vesting ID: 0xd2d40949abdc10285444899dea79d23d031bc5186ec97556f706e252436ebcf9
Vesting releasable amount: 0 DOGZ
Beneficiary:  0xC33a92CA0844290CBe629546e9788e7EF341cA08
Initial vesting period:  31/3/2024, 09:00:00
Vesting duration:  6 Months
Time between each release:  6 Months
Revocable:  true
Total amount: 3199999.9999999995 DOGZ
Released: 0 DOGZ
Revoked:  false

==========================================================================
Token Vesting at index [4]: Website FE wallet
==========================================================================

Vesting ID: 0x252de4734ab319fc47d1c686fd54144db277b778ef634be2306119702d095e38
Vesting releasable amount: 0 DOGZ
Beneficiary:  0x8245e1DAB64d1024A4090147fA287cd223D7fECf
Initial vesting period:  31/3/2024, 09:00:00
Vesting duration:  15 Months
Time between each release:  3 Months
Revocable:  true
Total amount: 5000000 DOGZ
Released: 0 DOGZ
Revoked:  false

==========================================================================
Token Vesting at index [5]: Website SC wallet
==========================================================================

Vesting ID: 0xc8cb0fb0f9a2cef1fd616ab7f34f3848f00c2125e98d7df32f1543471833a96c
Vesting releasable amount: 0 DOGZ
Beneficiary:  0xf562f7F866aa38040127118999462716784E3e89
Initial vesting period:  31/3/2024, 09:00:00
Vesting duration:  15 Months
Time between each release:  3 Months
Revocable:  true
Total amount: 5000000 DOGZ
Released: 0 DOGZ
Revoked:  false

==========================================================================
Token Vesting at index [6]: OTC Wallet 5
==========================================================================

Vesting ID: 0x20479b69af4f20cc2ea966b05ca59d6b022630e532507b1005560eb06de1219e
Vesting releasable amount: 0 DOGZ
Beneficiary:  0xB0d007a8991052A4b6D1684241aec9fd7BC17113
Initial vesting period:  31/3/2024, 09:00:00
Vesting duration:  9 Months
Time between each release:  3 Months
Revocable:  true
Total amount: 3750000 DOGZ
Released: 0 DOGZ
Revoked:  false
```

