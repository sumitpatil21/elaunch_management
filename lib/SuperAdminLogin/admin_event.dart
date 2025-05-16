part of 'admin_bloc.dart';

class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object> get props => [];
}

class AdminInsert extends AdminEvent {
  final String name, email, pass, companyName, field, check;

  const AdminInsert(
    this.name,
    this.email,
    this.pass,
    this.check,
    this.companyName,
    this.field,
  );

  @override
  List<Object> get props => [name, email, pass, check, companyName, field];
}

class AdminFetch extends AdminEvent {
  @override
  List<Object> get props => [];
}

class AdminLogin extends AdminEvent {
  final String email;
  final String check;

  const AdminLogin({required this.email, required this.check});

  @override
  List<Object> get props => [email, check];
}

class AdminLogout extends AdminEvent {
  @override
  List<Object> get props => [];
}
