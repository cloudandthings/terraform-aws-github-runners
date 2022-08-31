## Cost Estimate

Assumptions: 
- A single `t3.micro` instance type.
- Region is `af-south-1`.
- The instance will run for 9 hours from Mon-Fri (`195.54` instance hours per month).
- EBS Storage is configured as `10GB`.

As the `t3.micro` has 2 vCPU, this would provide 2 concurrent runners by default.

**EC2 monthly cost**

- On-Demand hourly cost for `t3.micro`: `$0.0136`
- Historical average discount for `t3.micro`: 70%
- `195.54` On-Demand instances hours x `0.0136 USD`: `2.66 USD`
- Less 70% Spot discount: `2.66 USD - (2.66 USD x 0.7)` : `0.797786 USD`

EC2 monthly subtotal = `0.80 USD`

**EBS monthly cost**

- `195.54 total EC2 hours / 730 hours in a month` : `0.27 instance months`
- `10 GB x 0.27 instance months x 0.1309 USD` : `0.35 USD (EBS Storage Cost)`

EBS monthly subotal = `0.35 USD`

**Total monthly cost**
 - EC2 monthly subtotal + EBS monthly subtotal
 - `0.80 USD + 0.35 USD` : `1.15 USD`

Total monthly cost
`1.15 USD` 💸🚫
