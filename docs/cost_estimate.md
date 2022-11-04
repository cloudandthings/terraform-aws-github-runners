## Cost Estimate

As per https://calculator.aws/#/

Assumptions:
- A single `t3.medium` instance type.
- Region is `af-south-1`.
- The instance will run for 9 hours from Mon-Fri (`195.54` instance hours per month).
- EBS Storage is configured as `40 GB`.

As the `t3.medium` has 2 vCPU, this would provide 2 concurrent runners by default.

**EC2 monthly cost**

- On-Demand hourly cost for `t3.medium`: `0.0542 USD`
- Historical average discount for `t3.medium`: 70%
- `195.54` On-Demand instances hours x `0.0542 USD`: `10.6 USD`
- Less 70% Spot discount: `10.6 USD - (10.6 USD x 0.7)` : `3.18 USD`

EC2 monthly subtotal = `3.18 USD`

**EBS monthly cost**

- No snapshots.
- Cost per GB: `0.1309 USD`
- `195.54` total EC2 hours / `730` hours in a month : `0.27` instance months
- `40 GB x 0.27` instance months at `0.1309 USD` : `0.35 USD`

EBS monthly subotal = `1.41 USD`

**Total monthly cost**
 - EC2 monthly subtotal + EBS monthly subtotal
 - `3.18 USD + 1.41 USD` : `4.59 USD`

Total monthly cost:

`4.59 USD` 💸🚫
