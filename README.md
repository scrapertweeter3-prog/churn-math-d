# churn-math

Effective hourly rate arithmetic for bank account bonus churning, as pure D
functions over the standard library. A signup bonus is piecework, not a
windfall: the bonus replaces savings interest your cash would have earned,
gets taxed as interest income, and costs hours of setup and monitoring. This
library prices all three.

## The functions

- `simpleInterest(principal, annualRate, days)` - simple interest over a day
  count.
- `afterTax(amount, marginalRate)` - interest income after federal tax, the
  Form 1099-INT treatment bank bonuses and savings interest both get.
- `forgoneInterest(principal, savingsAPY, holdDays, marginalRate)` - the
  after-tax savings interest you give up while the pool sits in a bonus
  checking account.
- `netBonus(bonus, marginalRate, principal, savingsAPY, holdDays, fees)` -
  after-tax bonus minus after-tax forgone interest minus fees actually paid.
- `effectiveHourly(...)` - net profit divided by hands-on hours, the real
  hourly rate of an offer.
- `breakEvenHours(...)` - the most hours an offer can cost before it fails a
  personal hourly threshold.
- `idleCost(principal, savingsAPY, idleDays)` - interest lost leaving the
  pool in the zero-interest account after the hold period ends.
- `calendarSlots(holdDays, coolDays)` - offers per year a rotation calendar
  can run given hold periods and cool-offs.
- `eligibilityDays(monthsWait)` - days until a closed account requalifies
  for a repeat bonus under a bank's waiting window.

## Worked offers

The worked examples use a 4.5% HYSA baseline and a 24% federal bracket, the
same scenario pair the churning guide on
[ExtraHustles](https://www.extrahustles.com) prices by hand:

| offer | bonus | capital | hold | hours | forgone (after tax) | net | hourly |
|---|---|---|---|---|---|---|---|
| high-deposit | $300 | $10,000 | 120 days | 4.0 | $112 | $116 | $29 |
| low-deposit | $200 | $2,500 | 90 days | 2.5 | $21 | $131 | $52 |

The lower-deposit offer wins on hourly rate because less capital sits idle.
Mid-tier bonuses with short holds and modest deposits beat the headline
numbers. The full method, including the 12-month rotation calendar and the
fee-waiver traps, is on ExtraHustles.

`dub test` reproduces every figure in that table; the demo config prints the
same ledger plus fee, calendar, and eligibility examples.

## Usage

```d
import churnmath;

auto rate = effectiveHourly(300.0, 0.24, 10_000.0, 0.045, 120, 0.0, 4.0);
// rate ~= 28.89
```

MIT licensed. DUB package: [churn-math](https://code.dlang.org/packages/churn-math).
