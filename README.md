# Sybolicate Stackshot

This is a simple command-line utility to get information out of hard iOS app bugs that don't leave a trace: stalls, livelocks, deadlocks.
First, reproduce the problem, and take a stackshot.  (See latest iOS developer documentation.)
Next, sync your phone.

## Installation
```bash
bundle install
```

## Using
Once you've captured a stackshot, run the utility:
```bash
bundle exec symbolicate-stackshot.rb -s ~/Library/Logs/CrashReporter/MobileDevice/DEVICENAME/stacks-YEAR-MONTH-DAY-TIMESTAMP.ips -p PROCESSNAME -d PATHTOAPPDSYM
```

## Future Extensions
It would be useful to search through all known dSYMs, so pods and libraries also get symbolicated.

## License
See COPYING.
