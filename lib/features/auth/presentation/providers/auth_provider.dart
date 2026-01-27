import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_repository.dart';
import '../../../../core/config/app_config.dart';
import '../../../../config/supabase/supabase_config.dart';
import '../../../../core/network/node_api_client.dart';
import '../../../../core/network/node_api_provider.dart';

// State class
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? user;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
    this.user,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? user,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      user: user ?? this.user,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final NodeApiClient _nodeApi;

  AuthNotifier(this._repository, this._nodeApi) : super(const AuthState());

  Future<void> bootstrap() async {
    if (!AppConfig.useSupabaseAuth) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final session = SupabaseConfig.client.auth.currentSession;
      if (session == null) {
        state = state.copyWith(isLoading: false, isAuthenticated: false);
        return;
      }

      final profile = await _nodeApi.getMe(accessToken: session.accessToken);
      // API returns { user: {...} }, so extract the actual user data
      final profileData = profile['user'] as Map<String, dynamic>? ?? {};
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: {
          'auth_user_id': session.user.id,
          'access_token': session.accessToken,
          ...profileData,
        },
      );
    } on NodeApiException catch (e) {
      if (e.statusCode == 401 || e.statusCode == 403) {
        await _repository.logout();
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          error: 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
        );
        return;
      }
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        error: e.statusCode == 404
            ? 'Không tìm thấy user profile. Hãy liên hệ admin hoặc chạy bootstrap (auth.users → public.users).'
            : 'Không thể tải profile từ API (${e.statusCode}).',
      );
    } catch (_) {
      state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          error: 'Không thể khởi tạo phiên đăng nhập.');
    }
  }

  Future<void> requestPhoneOtp(String phone) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.requestPhoneOtp(phone);
      state = state.copyWith(isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: 'Gửi OTP thất bại, vui lòng thử lại');
    }
  }

  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repository.login(username, password);
      if (!AppConfig.useSupabaseAuth) {
        state =
            state.copyWith(isAuthenticated: true, isLoading: false, user: user);
        return;
      }

      final token = user['token'] as String?;
      if (token == null || token.isEmpty) {
        state = state.copyWith(
            isLoading: false, error: 'Thiếu access token sau đăng nhập');
        return;
      }

      final profile = await _nodeApi.getMe(accessToken: token);
      // API returns { user: {...} }, so extract the actual user data
      final profileData = profile['user'] as Map<String, dynamic>? ?? {};
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        user: {
          ...user,
          ...profileData,
          'access_token': token,
        },
      );
    } catch (e) {
      // Improve error message handling
      String errorMessage = 'Đăng nhập thất bại';
      if (e.toString().contains('Invalid login credentials')) {
        errorMessage = 'Email hoặc mật khẩu không đúng';
      } else if (e.toString().contains('Email not confirmed')) {
        errorMessage = 'Vui lòng xác thực email trước';
      } else if (e is NodeApiException && e.statusCode == 404) {
        errorMessage =
            'Đăng nhập OK nhưng không có user profile. Hãy liên hệ admin hoặc chạy bootstrap users trên Supabase.';
      }

      state = state.copyWith(isLoading: false, error: errorMessage);
    }
  }

  Future<void> signupEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repository.signup(email, password);
      if (!AppConfig.useSupabaseAuth) {
        state =
            state.copyWith(isAuthenticated: true, isLoading: false, user: user);
        return;
      }

      final token = user['token'] as String?;
      if (token == null || token.isEmpty) {
        state = state.copyWith(
            isLoading: false, error: 'Thiếu access token sau đăng ký');
        return;
      }

      final profile = await _nodeApi.getMe(accessToken: token);
      // API returns { user: {...} }, so extract the actual user data
      final profileData = profile['user'] as Map<String, dynamic>? ?? {};
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        user: {
          ...user,
          ...profileData,
          'access_token': token,
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Đăng ký thất bại');
    }
  }

  Future<void> loginPhone(String phone, String otp) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repository.loginWithPhone(phone, otp);
      if (!AppConfig.useSupabaseAuth) {
        state =
            state.copyWith(isAuthenticated: true, isLoading: false, user: user);
        return;
      }

      final token = user['token'] as String?;
      if (token == null || token.isEmpty) {
        state = state.copyWith(
            isLoading: false, error: 'Thiếu access token sau xác thực OTP');
        return;
      }

      final profile = await _nodeApi.getMe(accessToken: token);
      // API returns { user: {...} }, so extract the actual user data
      final profileData = profile['user'] as Map<String, dynamic>? ?? {};
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        user: {
          ...user,
          ...profileData,
          'access_token': token,
        },
      );
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: 'Mã OTP không đúng hoặc đã hết hạn');
    }
  }

  /// Complete phone signup flow: verify OTP, set password, fetch profile
  Future<void> signupPhone(String phone, String otp, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Step 1: Verify OTP and set password in Supabase
      final user = await _repository.signupPhone(phone, otp, password);

      if (!AppConfig.useSupabaseAuth) {
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          user: user,
        );
        return;
      }

      // Step 2: Get token from response
      final token = user['token'] as String?;
      if (token == null || token.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: 'Thiếu access token sau đăng ký',
        );
        return;
      }

      // Step 3: Fetch profile from Node API (will create if not exists)
      final profile = await _nodeApi.getMe(accessToken: token);
      final profileData = profile['user'] as Map<String, dynamic>? ?? {};

      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        user: {
          ...user,
          ...profileData,
          'access_token': token,
        },
      );
    } catch (e) {
      String errorMessage = 'Đăng ký thất bại';
      if (e.toString().contains('Invalid OTP')) {
        errorMessage = 'Mã OTP không đúng';
      } else if (e.toString().contains('password')) {
        errorMessage = 'Mật khẩu không đủ mạnh (tối thiểu 6 ký tự)';
      }
      state = state.copyWith(isLoading: false, error: errorMessage);
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState(isAuthenticated: false);
  }
}

final authRepositoryProvider = Provider((ref) => AuthRepository());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
      ref.watch(authRepositoryProvider), ref.watch(nodeApiClientProvider));
});
