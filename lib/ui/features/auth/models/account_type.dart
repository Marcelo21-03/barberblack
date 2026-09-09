enum AccountType {
  cliente,
  barbeiro;

  String get label {
    switch (this) {
      case AccountType.cliente:
        return 'Cliente';
      case AccountType.barbeiro:
        return 'Barbeiro';
    }
  }
}
