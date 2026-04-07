//
//  SignInPromotionView.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/04/07.
//

import AuthenticationServices
import SwiftUI

// MARK: - SignInWithAppleButtonWrapper

/// HIG準拠のSignInWithAppleButtonをSignInUseCase経由で動作させるラッパー
struct SignInWithAppleButtonWrapper: View {
    let isDisabled: Bool
    let action: () async -> Void

    var body: some View {
        SignInWithAppleButton(.signIn) { request in
            request.requestedScopes = [.email, .fullName]
        } onCompletion: { _ in }
            .signInWithAppleButtonStyle(.black)
            .frame(height: Constants.Layout.Button.signInWithAppleHeight)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .disabled(isDisabled)
            .overlay {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        Task { await action() }
                    }
            }
            .accessibilityLabel(String(localized: .menuSignInWithApple))
    }
}

// MARK: - SignInPromotionView

struct SignInPromotionView: View {
    @State private var viewModel: SignInPromotionViewModel
    let onCompleted: (Bool) -> Void

    init(context: SignInPromotionContext, onCompleted: @escaping (Bool) -> Void) {
        viewModel = SignInPromotionViewModel(context: context)
        self.onCompleted = onCompleted
    }

    var body: some View {
        VStack {
            // ヘッダー（チェックイン時のみ×ボタン）
            HStack {
                if viewModel.context == .checkIn {
                    Button {
                        viewModel.close()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(Color(.systemGray))
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)

            Spacer()

            // 中央コンテンツ
            VStack(spacing: 24) {
                Image(systemName: viewModel.context == .launch ? "lock.shield.fill" : "person.badge.key.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(Color(.textSecondary))

                Text(viewModel.context == .launch ?
                     String(localized: .signInPromotionLaunchMessage) :
                        String(localized: .signInPromotionCheckInMessage)
                )
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color(.label))
                .multilineTextAlignment(.center)

                Text(viewModel.context == .launch ?
                     String(localized: .signInPromotionLaunchDescription) :
                        String(localized: .signInPromotionCheckInDescription)
                )
                .font(.system(size: 14))
                .foregroundStyle(Color(.secondaryLabel))
                .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)

            Spacer()

            // ボタンエリア
            VStack(spacing: 12) {
                SignInWithAppleButtonWrapper(
                    isDisabled: viewModel.isSigningIn,
                    action: { await viewModel.signInWithApple() }
                )

                if viewModel.context.isDismissible {
                    Button(String(localized: .signInPromotionSkip)) {
                        viewModel.skip()
                    }
                    .font(.system(size: 15))
                    .foregroundStyle(Color(.secondaryLabel))
                    .frame(height: 44)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .foregroundStyle(.primary)
        .background(Color(.systemBackground))
        .interactiveDismissDisabled()
        .alert(
            viewModel.activeAlert?.title ?? "",
            isPresented: Binding(
                get: { viewModel.activeAlert != nil },
                set: { if !$0 { viewModel.activeAlert = nil } }
            )
        ) {}
        .onChange(of: viewModel.isCompleted) { _, isCompleted in
            if isCompleted {
                onCompleted(viewModel.isSignedIn)
            }
        }
    }
}
