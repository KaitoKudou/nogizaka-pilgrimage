//
//  MenuViewModelTests.swift
//  nogizaka-pilgrimageTests
//
//  Created by k_kudo on 2026/04/06.
//

import Dependencies
import Foundation
import Testing

@testable import nogizaka_pilgrimage

private let testUser = AuthUser(
    uid: "test-uid-123",
    email: "test@example.com",
    displayName: "テストユーザー"
)

@MainActor
@Suite(.timeLimit(.minutes(1)))
struct MenuViewModelTests {

    // MARK: - observeAuthState

    @Test("observeAuthStateでsignedInが反映される")
    func observeAuthState_signedIn() async {
        let viewModel = withDependencies {
            $0[AuthRepository.self].observeAuthState = {
                AsyncStream { continuation in
                    continuation.yield(.signedIn(testUser))
                    continuation.finish()
                }
            }
        } operation: {
            MenuViewModel()
        }

        await viewModel.observeAuthState()

        #expect(viewModel.authState == .signedIn(testUser))
    }

    @Test("observeAuthStateでsignedOutが反映される")
    func observeAuthState_signedOut() async {
        let viewModel = withDependencies {
            $0[AuthRepository.self].observeAuthState = {
                AsyncStream { continuation in
                    continuation.yield(.signedOut)
                    continuation.finish()
                }
            }
        } operation: {
            MenuViewModel()
        }

        await viewModel.observeAuthState()

        #expect(viewModel.authState == .signedOut)
    }

    @Test("初期状態はunknown")
    func initialState_isUnknown() {
        let viewModel = MenuViewModel()
        #expect(viewModel.authState == .unknown)
    }

    // MARK: - signInWithApple

    @Test("signInWithAppleで成功時にisSigningInがfalseに戻る")
    func signIn_success_resetsIsSigningIn() async {
        let viewModel = withDependencies {
            $0[SignInUseCase.self].execute = { testUser }
            $0[CheckInMigrationClient.self].migrateIfNeeded = {}
        } operation: {
            MenuViewModel()
        }

        await viewModel.signInWithApple()

        #expect(viewModel.isSigningIn == false)
        #expect(viewModel.activeAlert == nil)
    }

    @Test("signInWithAppleで成功時にチェックインマイグレーションが実行される")
    func signIn_success_callsMigration() async {
        let migrationCalled = LockIsolated(false)

        let viewModel = withDependencies {
            $0[SignInUseCase.self].execute = { testUser }
            $0[CheckInMigrationClient.self].migrateIfNeeded = {
                migrationCalled.setValue(true)
            }
        } operation: {
            MenuViewModel()
        }

        await viewModel.signInWithApple()

        #expect(migrationCalled.value == true)
    }

    @Test("signInWithAppleでキャンセル時にアラートが表示されない")
    func signIn_cancelled_noAlert() async {
        let viewModel = withDependencies {
            $0[SignInUseCase.self].execute = { throw AuthError.cancelled }
        } operation: {
            MenuViewModel()
        }

        await viewModel.signInWithApple()

        #expect(viewModel.activeAlert == nil)
        #expect(viewModel.isSigningIn == false)
    }

    @Test("signInWithAppleでキャンセル時にマイグレーションは実行されない")
    func signIn_cancelled_doesNotCallMigration() async {
        let migrationCalled = LockIsolated(false)

        let viewModel = withDependencies {
            $0[SignInUseCase.self].execute = { throw AuthError.cancelled }
            $0[CheckInMigrationClient.self].migrateIfNeeded = {
                migrationCalled.setValue(true)
            }
        } operation: {
            MenuViewModel()
        }

        await viewModel.signInWithApple()

        #expect(migrationCalled.value == false)
    }

    @Test("signInWithAppleでエラー時にsignInErrorアラートが表示される")
    func signIn_error_showsAlert() async {
        let viewModel = withDependencies {
            $0[SignInUseCase.self].execute = { throw AuthError.signInFailed }
        } operation: {
            MenuViewModel()
        }

        await viewModel.signInWithApple()

        #expect(viewModel.activeAlert == .signInError)
        #expect(viewModel.isSigningIn == false)
    }

    @Test("signInWithAppleでエラー時にマイグレーションは実行されない")
    func signIn_error_doesNotCallMigration() async {
        let migrationCalled = LockIsolated(false)

        let viewModel = withDependencies {
            $0[SignInUseCase.self].execute = { throw AuthError.signInFailed }
            $0[CheckInMigrationClient.self].migrateIfNeeded = {
                migrationCalled.setValue(true)
            }
        } operation: {
            MenuViewModel()
        }

        await viewModel.signInWithApple()

        #expect(migrationCalled.value == false)
    }

    // MARK: - signOut

    @Test("signOutでsignOutUseCaseが呼ばれる")
    func signOut_callsUseCase() {
        let signOutCalled = LockIsolated(false)

        let viewModel = withDependencies {
            $0[SignOutUseCase.self].execute = {
                signOutCalled.setValue(true)
            }
        } operation: {
            MenuViewModel()
        }

        viewModel.signOut()

        #expect(signOutCalled.value == true)
        #expect(viewModel.activeAlert == nil)
    }

    @Test("signOutでエラー時にsignOutErrorアラートが表示される")
    func signOut_error_showsAlert() {
        let viewModel = withDependencies {
            $0[SignOutUseCase.self].execute = {
                throw AuthError.signOutFailed
            }
        } operation: {
            MenuViewModel()
        }

        viewModel.signOut()

        #expect(viewModel.activeAlert == .signOutError)
    }

    // MARK: - confirmSignOut

    @Test("confirmSignOutでsignOutConfirmationアラートが表示される")
    func confirmSignOut_showsConfirmation() {
        let viewModel = MenuViewModel()

        viewModel.confirmSignOut()

        #expect(viewModel.activeAlert == .signOutConfirmation)
    }
}
