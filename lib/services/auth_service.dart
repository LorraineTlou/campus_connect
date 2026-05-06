import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
	const AuthService();

	static const String studentEmailDomain = '@students.nust.ac.zw';
	static const String invalidStudentEmailMessage =
			'You must use a valid @students.nust.ac.zw email';

	static bool isStudentEmail(String email) {
		return email.trim().toLowerCase().endsWith(studentEmailDomain);
	}

	static String? validateStudentEmail(
		String? value, {
		String emptyMessage = 'Email is required',
		String invalidMessage = invalidStudentEmailMessage,
	}) {
		if (value == null || value.trim().isEmpty) {
			return emptyMessage;
		}
		if (!isStudentEmail(value)) {
			return invalidMessage;
		}
		return null;
	}

	String _normalizedEmail(String email) {
		return email.trim().toLowerCase();
	}

	void _ensureStudentEmail(String email) {
		if (!isStudentEmail(email)) {
			throw FirebaseAuthException(
				code: 'invalid-email',
				message: invalidStudentEmailMessage,
			);
		}
	}

	Future<UserCredential> login({
		required String email,
		required String password,
	}) async {
		final normalizedEmail = _normalizedEmail(email);
		_ensureStudentEmail(normalizedEmail);

		return FirebaseAuth.instance.signInWithEmailAndPassword(
			email: normalizedEmail,
			password: password.trim(),
		);
	}

	Future<UserCredential> signUp({
		required String name,
		required String email,
		required String password,
	}) async {
		final normalizedEmail = _normalizedEmail(email);
		_ensureStudentEmail(normalizedEmail);

		final userCredential = await FirebaseAuth.instance
				.createUserWithEmailAndPassword(
					email: normalizedEmail,
					password: password.trim(),
				);

		final user = userCredential.user;
		if (user != null) {
			await user.updateDisplayName(name.trim());
		}

		return userCredential;
	}

	Future<void> sendPasswordResetEmail({required String email}) async {
		final normalizedEmail = _normalizedEmail(email);
		_ensureStudentEmail(normalizedEmail);

		await FirebaseAuth.instance.sendPasswordResetEmail(email: normalizedEmail);
	}
}
