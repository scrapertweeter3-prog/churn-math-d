import std.stdio;
import churnmath;

void main() {
    writeln("Bank-account bonus churning, priced as piecework (4.5% HYSA, 24% bracket):");
    writeln("  high-deposit offer: $300 bonus, $10,000 parked 120 days, 4 hours");
    writeln("    forgone interest after tax: ", usd(forgoneInterest(10_000.0, 0.045, 120, 0.24)));
    writeln("    net profit: ", usd(netBonus(300.0, 0.24, 10_000.0, 0.045, 120, 0.0)));
    writeln("    effective hourly rate: ", usd(effectiveHourly(300.0, 0.24, 10_000.0, 0.045, 120, 0.0, 4.0)));
    writeln("  low-deposit offer: $200 bonus, $2,500 parked 90 days, 2.5 hours");
    writeln("    forgone interest after tax: ", usd(forgoneInterest(2_500.0, 0.045, 90, 0.24)));
    writeln("    net profit: ", usd(netBonus(200.0, 0.24, 2_500.0, 0.045, 90, 0.0)));
    writeln("    effective hourly rate: ", usd(effectiveHourly(200.0, 0.24, 2_500.0, 0.045, 90, 0.0, 2.5)));
    writeln("  one missed $25 fee waiver on the low-deposit offer:");
    writeln("    net drops to ", usd(netBonus(200.0, 0.24, 2_500.0, 0.045, 90, 25.0)));
    writeln("  a 3% savings baseline instead of 4.5% (gross forgone): ",
            usd(simpleInterest(10_000.0, 0.03, 120)));
    writeln("  idle-cash cost of 30 days between offers on $15,000: ",
            usd(idleCost(15_000.0, 0.045, 30)));
    writeln("  rotation calendar: 120-day holds + 30-day cool-offs = ",
            calendarSlots(120, 30), " offers a year; 90+15 = ",
            calendarSlots(90, 15));
    writeln("  24-month repeat-bonus window = ", eligibilityDays(24), " days");
}

string usd(double amount) @safe pure {
    import std.conv : to;
    long whole = cast(long) (amount + 0.5);
    string digits = to!string(whole);
    string grouped;
    int count = 0;
    for (int i = cast(int) digits.length - 1; i >= 0; i--) {
        grouped = digits[i] ~ grouped;
        count++;
        if (count % 3 == 0 && i > 0) grouped = "," ~ grouped;
    }
    return "$" ~ grouped;
}
