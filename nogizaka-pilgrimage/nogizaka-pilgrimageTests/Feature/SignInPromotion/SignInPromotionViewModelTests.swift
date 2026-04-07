//
//  SignInPromotionViewModelTests.swift
//  nogizaka-pilgrimageTests
//
//  Created by k_kudo on 2026/04/07.
//

import Dependencies
import Foundation
import Testing

@testable import nogizaka_pilgrimage

private let testUser = AuthUser(
    uid: "test-uid",
    email: "test@example.com",
    displayName: "テスト"
)

@MainActor
@Suite(.timeLimit(.minutes(1)))
struct SignInPromotionViewModelTests {

    // MARK: - signInWithApple

    @Test("サインイン成功でisSignedInとisCompletedがtrueになる")
    func signIn_success() async {
        let viewModel = withDependencies {
            $0[SignInUseCase.self].execute = { testUser }
        } operation: {
            SignInPromotionViewModel(context: .launch)
        }

        await viewModel.signInWithApple()

        #expect(viewModel.isSignedIn == true)
        #expect(viewModel.isCompleted == true)
        #expect(viewModel.activeAlert == nil)
    }

    @Test("サインインキャンセルでアラートが表示されない")
    func signIn_cancelled() async {
        let viewModel = withDependencies {
            $0[SignInUseCase.self].execute = { throw AuthError.cancelled }
        } operation: {
            SignInPromotionViewModel(context: .launch)
        }

        await viewModel.signInWithApple()

        #expect(viewModel.isCompleted == false)
        #expect(viewModel.isSignedIn == false)
        #expect(viewModel.activeAlert == nil)
    }

    @Test("サインインエラーでアラートが表示される")
    func signIn_error() async {
        let viewModel = withDependencies {
            $0[SignInUseCase.self].execute = { throw AuthError.signInFailed }
        } operation: {
            SignInPromotionViewModel(context: .launch)
        }

        await viewModel.signInWithApple()

        #expect(viewModel.activeAlert == .signInError)
        #expect(viewModel.isCompleted == false)
        #expect(viewModel.isSignedIn == false)
    }

    // MARK: - skip / close

    @Test("skipでisCompletedがtrueになる")
    func skip_setsCompleted() {
        let viewModel = SignInPromotionViewModel(context: .launch)

        viewModel.skip()

        #expect(viewModel.isCompleted == true)
        #expect(viewModel.isSignedIn == false)
    }

    @Test("closeでisCompletedがtrueになる")
    func close_setsCompleted() {
        let viewModel = SignInPromotionViewModel(context: .checkIn)

        viewModel.close()

        #expect(viewModel.isCompleted == true)
        #expect(viewModel.isSignedIn == false)
    }

    // MARK: - context

    @Test("launchコンテキストはスキップ可能")
    func launch_isDismissible() {
        #expect(SignInPromotionContext.launch.isDismissible == true)
    }

    @Test("checkInコンテキストはスキップ不可")
    func checkIn_isNotDismissible() {
        #expect(SignInPromotionContext.checkIn.isDismissible == false)
    }
}
