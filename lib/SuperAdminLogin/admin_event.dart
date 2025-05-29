part of 'admin_bloc.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

class AdminInsert extends AdminEvent {
  final String id;
  final String name;
  final String email;
  final String pass;
  final String check;
  final String companyName;
  final String field;

  const AdminInsert({
    required this.id,
    required this.name,
    required this.email,
    required this.pass,
    required this.check,
    required this.companyName,
    required this.field,
  });

  @override
  List<Object?> get props => [id, name, email, pass, check, companyName, field];
}

class AdminFetch extends AdminEvent {
  const AdminFetch();
}

class AdminLogin extends AdminEvent {
  final String email;
  final String password;
  final String check;

  const AdminLogin({
    required this.email,
    this.check = "isLogin",
    required this.password,
  });

  @override
  List<Object?> get props => [email, check, password];
}

class AdminLogout extends AdminEvent {
  final String? email;

  const AdminLogout({this.email});

  @override
  List<Object?> get props => [email];
}
class AdminLoginCheck extends AdminEvent {
  final bool isLogin;
  const AdminLoginCheck({required this.isLogin});
  @override
  List<Object?> get props => [isLogin];

}