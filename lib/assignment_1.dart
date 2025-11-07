abstract class BankAccount {
  final int _accountNumber;
  final String _accountHolderName;
  double _balance;
  final List<String> _transactionHistory = [];

  BankAccount(this._accountNumber, this._accountHolderName, this._balance);

  int get accountNumber => _accountNumber;
  String get accountHolderName => _accountHolderName;
  double get balance => _balance;

  set balance(double newBalance) {
    _balance = newBalance;
  }

  void addTransaction(String message) {
    _transactionHistory.add("${DateTime.now()} ➜ $message");
  }

  void showTransactionHistory() {
    print('\n Transaction History for $_accountHolderName:');
    if (_transactionHistory.isEmpty) {
      print("No transactions yet.");
    } else {
      for (var t in _transactionHistory) {
        print(" - $t");
      }
    }
  }

  void deposit(double amount);
  void withdraw(double amount);

  void displayAccountInfo() {
    print('-----------------------------');
    print('Account Number: $_accountNumber');
    print('Account Holder: $_accountHolderName');
    print('Balance: \$${_balance.toStringAsFixed(2)}');
    print('-----------------------------');
  }
}

abstract class InterestBearing {
  double calculateInterest();
}

class SavingsAccount extends BankAccount implements InterestBearing {
  static const double _minBalance = 500.0;
  static const double _interestRate = 0.02;
  static const int _maxWithdrawals = 3;

  int _withdrawalCount = 0;

  SavingsAccount(int accNo, String holder, double bal)
    : super(accNo, holder, bal);

  @override
  void deposit(double amount) {
    if (amount > 0) {
      balance += amount;
      addTransaction("Deposited \$${amount.toStringAsFixed(2)}");
      print('Deposited \$${amount.toStringAsFixed(2)} successfully.');
    } else {
      print('Invalid deposit amount!');
    }
  }

  @override
  void withdraw(double amount) {
    if (amount <= 0) {
      print('Invalid withdrawal amount!');
      return;
    }

    if (_withdrawalCount >= _maxWithdrawals) {
      print('Withdrawal limit reached for this month!');
      return;
    }
    if (balance - amount < _minBalance) {
      print(
        'Cannot withdraw — minimum balance of \$$_minBalance must be maintained.',
      );
      return;
    }

    balance -= amount;
    _withdrawalCount++;
    addTransaction("Withdrew \$${amount.toStringAsFixed(2)}");
    print('Withdrawn \$${amount.toStringAsFixed(2)} successfully.');
  }

  @override
  double calculateInterest() {
    return balance * _interestRate;
  }
}

class CheckingAccount extends BankAccount {
  static const double _overdraftFee = 35.0;

  CheckingAccount(int accNo, String holder, double bal)
    : super(accNo, holder, bal);

  @override
  void deposit(double amount) {
    if (amount > 0) {
      balance += amount;
      addTransaction("Deposited \$${amount.toStringAsFixed(2)}");
      print('Deposited \$${amount.toStringAsFixed(2)} successfully.');
    } else {
      print('Invalid deposit amount!');
    }
  }

  @override
  void withdraw(double amount) {
    if (amount <= 0) {
      print('Invalid withdrawal amount!');
      return;
    }

    if (balance - amount < 0) {
      print('Warning: This withdrawal will result in overdraft!');
    }

    balance -= amount;
    addTransaction("Withdrew \$${amount.toStringAsFixed(2)}");
    print('Withdrawn \$${amount.toStringAsFixed(2)} successfully.');

    if (balance < 0) {
      balance -= _overdraftFee;
      addTransaction("Overdraft fee of \$$_overdraftFee applied.");
      print('Overdraft fee of \$$_overdraftFee applied.');
    }
  }
}

class PremiumAccount extends BankAccount implements InterestBearing {
  static const double _minBalance = 10000.0;
  static const double _interestRate = 0.05;

  PremiumAccount(int accNo, String holder, double bal)
    : super(accNo, holder, bal);

  @override
  void deposit(double amount) {
    if (amount > 0) {
      balance += amount;
      addTransaction("Deposited \$${amount.toStringAsFixed(2)}");
      print('Deposited \$${amount.toStringAsFixed(2)} successfully.');
    } else {
      print('Invalid deposit amount!');
    }
  }

  @override
  void withdraw(double amount) {
    if (amount <= 0) {
      print('Invalid withdrawal amount!');
      return;
    }

    if (balance - amount < _minBalance) {
      print(
        'Cannot withdraw — minimum balance of \$$_minBalance must be maintained.',
      );
      return;
    }

    balance -= amount;
    addTransaction("Withdrew \$${amount.toStringAsFixed(2)}");
    print('Withdrawn \$${amount.toStringAsFixed(2)} successfully.');
  }

  @override
  double calculateInterest() {
    return balance * _interestRate;
  }
}

class StudentAccount extends BankAccount {
  static const double _maxBalance = 5000.0;

  StudentAccount(int accNo, String holder, double bal)
    : super(accNo, holder, bal);

  @override
  void deposit(double amount) {
    if (amount <= 0) {
      print('Invalid deposit amount!');
      return;
    }

    if ((balance + amount) > _maxBalance) {
      print('Deposit exceeds max balance of \$$_maxBalance!');
      return;
    }

    balance += amount;
    addTransaction("Deposited \$${amount.toStringAsFixed(2)}");
    print('Deposited \$${amount.toStringAsFixed(2)} successfully.');
  }

  @override
  void withdraw(double amount) {
    if (amount <= 0) {
      print('Invalid withdrawal amount!');
      return;
    }

    if (amount > balance) {
      print('Insufficient funds!');
      return;
    }

    balance -= amount;
    addTransaction("Withdrew \$${amount.toStringAsFixed(2)}");
    print('Withdrawn \$${amount.toStringAsFixed(2)} successfully.');
  }
}

class Bank {
  final List<BankAccount> _accounts = [];

  void addAccount(BankAccount account) {
    _accounts.add(account);
    print('✅ Account created for ${account.accountHolderName}');
  }

  BankAccount? findAccount(int accountNumber) {
    for (var acc in _accounts) {
      if (acc.accountNumber == accountNumber) return acc;
    }
    print(' Account not found!');
    return null;
  }

  void transfer(int fromAccNo, int toAccNo, double amount) {
    var sender = findAccount(fromAccNo);
    var receiver = findAccount(toAccNo);

    if (sender == null || receiver == null) {
      print(' Transfer failed: One of the accounts does not exist.');
      return;
    }

    if (amount <= 0) {
      print(' Transfer failed: Invalid transfer amount.');
      return;
    }

    print('\n Initiating transfer of \$${amount.toStringAsFixed(2)}...');

    double originalBalance = sender.balance;
    sender.withdraw(amount);

    if (sender.balance < originalBalance) {
      receiver.deposit(amount);
      sender.addTransaction(
        "Transferred \$${amount.toStringAsFixed(2)} to ${receiver.accountHolderName}",
      );
      receiver.addTransaction(
        "Received \$${amount.toStringAsFixed(2)} from ${sender.accountHolderName}",
      );
      print('Transfer completed successfully!\n');
    } else {
      print(
        ' Transfer failed: Insufficient funds or withdrawal limit reached.\n',
      );
    }
  }

  void applyMonthlyInterest() {
    print('\n💰 Applying monthly interest to eligible accounts...');
    for (var acc in _accounts) {
      if (acc is InterestBearing) {
        // Now we can safely call calculateInterest because we checked the type
        double interest = (acc as InterestBearing).calculateInterest();
        acc.balance += interest;
        acc.addTransaction(
          "Monthly interest of \$${interest.toStringAsFixed(2)} applied.",
        );
        print(
          'Interest of \$${interest.toStringAsFixed(2)} applied to ${acc.accountHolderName}',
        );
      }
    }
  }

  void generateReport() {
    print('\n📋 --- Bank Account Report ---');
    for (var acc in _accounts) {
      acc.displayAccountInfo();
      acc.showTransactionHistory();
    }
  }
}

void main() {
  Bank bank = Bank();

  // Create accounts
  var acc1 = SavingsAccount(1001, 'Alice', 2000);
  var acc2 = CheckingAccount(1002, 'Bob', 500);
  var acc3 = PremiumAccount(1003, 'Charlie', 20000);
  var acc4 = StudentAccount(1004, 'David', 1500);

  // Add accounts to bank
  bank.addAccount(acc1);
  bank.addAccount(acc2);
  bank.addAccount(acc3);
  bank.addAccount(acc4);

  // Perform operations
  print('\n--- Performing Operations ---');
  acc1.withdraw(1000);
  acc1.deposit(500);
  acc2.withdraw(600);
  acc3.withdraw(5000);
  acc4.deposit(400);
  acc4.deposit(400);

  // Transfer
  print('\n--- Transfer Operations ---');
  bank.transfer(1003, 1002, 2000);
  bank.transfer(1001, 1004, 300);

  // Apply monthly interest
  bank.applyMonthlyInterest();

  // Generate report
  bank.generateReport();
}
