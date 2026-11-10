# churn-math

Library docs for churn-math, a D package that prices bank account signup
offers as piecework. The repo README carries the hourly-rate arithmetic and
the worked-offer table. This page walks the part of the method that decides
what lands on the calendar: hold windows, cool-offs, idle days between
offers, and the wait a bank imposes before a closed account can earn the
same bonus twice.

## The functions, grouped by question

Pricing a single offer:

- `simpleInterest` and `afterTax` convert a rate and a day count into
  interest you keep.
- `forgoneInterest` prices the savings yield your cash gives up while it
  sits in the bonus account.
- `netBonus` folds taxes, forgone yield, and fees into one number.
- `effectiveHourly` and `breakEvenHours` turn that number into a rate you
  can compare against your normal work.

Scheduling the year:

- `calendarSlots` counts how many offers a rotation calendar fits, given
  hold periods and cool-offs.
- `idleCost` prices the days the pool spends in a zero-interest account
  between offers.
- `eligibilityDays` converts a bank's requalification window into a day
  count.

## Two offers on one calendar

Run the demo and put its two offers on a 365-day calendar. The
high-deposit case ($300 bonus, $10,000 parked 120 days, 4 hours of
setup) nets $116 and pays about $29 an hour. The low-deposit case
($200 bonus, $2,500 parked 90 days, 2.5 hours) nets $131 at $52 an
hour. With a 30-day cool-off, the 120-day hold fits twice in a year:
$232 of net profit. The 90-day hold with a 15-day cool-off fits three
times: $393. The calendar, not the headline bonus, picks the winner.

Idle days have a price too. Leaving $15,000 in the zero-interest
account for 30 days between offers costs $55, which `idleCost` reports
directly. And when a bank makes you wait 24 months before requalifying,
`eligibilityDays(24)` returns 720, the day count to put on the calendar
before that offer can repeat.

## Reproduce the numbers

```d
dub run --config=demo
```

prints the whole ledger: both offers, the fee-waiver miss, the 3%
savings baseline, the idle-cash figure, both rotation calendars, and
the requalification window. From code:

```d
import churnmath;

auto slots = calendarSlots(120, 30);        // 2 offers a year
auto wait  = eligibilityDays(24);           // 720 days
auto slip  = idleCost(15_000.0, 0.045, 30); // about $55
```

`dub test` checks every figure above against the library's own
unittests.

## Where the complete method lives

The complete walkthrough, waiver fine print included, lives on
[ExtraHustles](https://www.extrahustles.com).
