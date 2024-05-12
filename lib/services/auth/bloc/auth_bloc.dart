import 'package:bloc/bloc.dart';
import 'package:flutterdemoapp/services/auth/auth_provider.dart';
import 'package:flutterdemoapp/services/auth/bloc/auth_event.dart';
import 'package:flutterdemoapp/services/auth/bloc/auth_state.dart';
import 'package:flutterdemoapp/services/crud/notes_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider)
      : super(const AuthStateUninitialized(isLoading: true)) {
    on<AuthEventInitialize>((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
      } else {
        emit(AuthStateLoggedIn(user: user, isLoading: false));
      }
    });

    //Login
    on<AuthEventLogin>((event, emit) async {
      emit(const AuthStateLoggedOut(
          exception: null, isLoading: true, loadingText: 'Logging in'));
      final email = event.email;
      final password = event.password;
      final provider = event.provider;
      try {
        final user = await provider.login(
          email: email,
          password: password,
        );
        //Disable loading dialog
        emit(const AuthStateLoggedOut(
          exception: null,
          isLoading: false,
        ));
        //Login to the app
        emit(AuthStateLoggedIn(user: user, isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(
          exception: e,
          isLoading: false,
        ));
      }
    });

    //Logout
    on<AuthEventLogout>((event, emit) async {
      emit(const AuthStateUninitialized(isLoading: true));
      try {
        await provider.logOut();
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    });

    //Register
    on<AuthEventRegister>((event, emit) async {
      logger.d('In Register event');
      emit(const AuthStateRegistering(
          exception: null, isLoading: true, loadingText: 'Creating account..'));
      final email = event.email;
      final password = event.password;
      try {
        await provider.createUser(
          email: email,
          password: password,
        );
        emit(const AuthStateVerification(
          isLoading: false,
        ));
        logger.d("After emiting Verification state");
      } on Exception catch (e) {
        emit(AuthStateRegistering(
          exception: e,
          isLoading: false,
        ));
      }
    });

    //Should Register
    on<AuthEventShouldRegister>((event, emit) async {
      emit(const AuthStateRegistering(
        exception: null,
        isLoading: false,
      ));
    });

    //Should Register
    on<AuthEventShouldLogin>((event, emit) async {
      emit(const AuthStateLoggedOut(exception: null, isLoading: false));
    });
  }
}
