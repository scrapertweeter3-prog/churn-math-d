/** Bank-account bonus churning arithmetic: the effective hourly rate of a
    signup bonus after federal tax and forgone high-yield savings interest,
    simple-interest opportunity cost, fee drag, idle-cash cost between
    offers, rotation-calendar spacing, and repeat-bonus eligibility windows.
    Rates are decimals (0.045 = 4.5% APY); months are 30-day months. */
module churnmath;

/// Simple interest over a day count: principal * rate * days / 365.
double simpleInterest(double principal, double annualRate, int days)
@safe pure {
    return principal * annualRate * days / 365.0;
}

/// Interest income after federal tax (Form 1099-INT, marginal rate).
double afterTax(double amount, double marginalRate) @safe pure {
    return amount * (1.0 - marginalRate);
}

/// Savings interest you give up parking the pool in a bonus checking
/// account, after tax on that interest.
double forgoneInterest(double principal, double savingsAPY, int holdDays,
    double marginalRate) @safe pure {
    return afterTax(simpleInterest(principal, savingsAPY, holdDays),
        marginalRate);
}

/// Net profit on one offer: after-tax bonus minus after-tax forgone
/// interest minus maintenance fees actually paid.
double netBonus(double bonus, double marginalRate, double principal,
    double savingsAPY, int holdDays, double fees) @safe pure {
    return afterTax(bonus, marginalRate)
        - forgoneInterest(principal, savingsAPY, holdDays, marginalRate)
        - fees;
}

/// Effective hourly rate for one offer: net profit divided by hands-on
/// hours across the hold period.
double effectiveHourly(double bonus, double marginalRate, double principal,
    double savingsAPY, int holdDays, double fees, double hours)
@safe pure {
    return netBonus(bonus, marginalRate, principal, savingsAPY, holdDays,
        fees) / hours;
}

/// Hours an offer must take before it fails a personal hourly threshold.
double breakEvenHours(double bonus, double marginalRate, double principal,
    double savingsAPY, int holdDays, double fees, double threshold)
@safe pure {
    return netBonus(bonus, marginalRate, principal, savingsAPY, holdDays,
        fees) / threshold;
}

/// Interest lost to leaving the pool idle in the zero-interest account
/// after the hold period ends (the calendar's return-to-savings gap).
double idleCost(double principal, double savingsAPY, int idleDays)
@safe pure {
    return simpleInterest(principal, savingsAPY, idleDays);
}

/// Offers a 12-month rotation can run given each hold period and the
/// cool-off between offers: 365 divided by the cycle length.
int calendarSlots(int holdDays, int coolDays) @safe pure {
    if (holdDays + coolDays <= 0) return 0;
    return 365 / (holdDays + coolDays);
}

/// Days until a closed account requalifies for a repeat bonus, for banks
/// enforcing a months-long eligibility window after closure.
int eligibilityDays(int monthsWait) @safe pure {
    return monthsWait * 30;
}

unittest {
    import std.math : approxEqual;

    // Worked offers, 4.5% HYSA baseline, 24% federal bracket.
    // High-deposit: $300 bonus, $10,000, 120 days, 4 hours.
    auto hiNet = netBonus(300.0, 0.24, 10_000.0, 0.045, 120, 0.0);
    assert(approxEqual(hiNet, 116.0, 1e-6, 0.5));
    assert(approxEqual(effectiveHourly(300.0, 0.24, 10_000.0, 0.045, 120,
        0.0, 4.0), 28.89, 1e-6, 0.05));

    // Low-deposit: $200 bonus, $2,500, 90 days, 2.5 hours.
    auto loNet = netBonus(200.0, 0.24, 2_500.0, 0.045, 90, 0.0);
    assert(approxEqual(loNet, 131.0, 1e-6, 0.5));
    assert(approxEqual(effectiveHourly(200.0, 0.24, 2_500.0, 0.045, 90,
        0.0, 2.5), 52.37, 1e-6, 0.05));

    // Gross pieces behind the high-deposit offer.
    assert(approxEqual(simpleInterest(10_000.0, 0.045, 120), 147.95, 1e-6,
        0.02));
    assert(approxEqual(forgoneInterest(10_000.0, 0.045, 120, 0.24), 112.44,
        1e-6, 0.5));
    assert(approxEqual(afterTax(300.0, 0.24), 228.0));

    // A 3% savings baseline widens the same offer's margin.
    assert(approxEqual(forgoneInterest(10_000.0, 0.03, 120, 0.0), 98.63,
        1e-6, 0.05));

    // Fees bite first: a waived-fee miss wipes a third of the low-deposit
    // offer's net.
    assert(approxEqual(netBonus(200.0, 0.24, 2_500.0, 0.045, 90, 25.0),
        106.0, 1e-6, 0.5));

    // Idle cash between offers: 30 days back at 4.5% on $15,000.
    assert(approxEqual(idleCost(15_000.0, 0.045, 30), 55.48, 1e-6, 0.05));

    // Calendar: 120-day holds with a 30-day cool-off run 2 offers/year;
    // tighter 90/15 cycles run 3.
    assert(calendarSlots(120, 30) == 2);
    assert(calendarSlots(90, 15) == 3);

    // Eligibility: a 24-month repeat window is 720 days.
    assert(eligibilityDays(24) == 720);
}
