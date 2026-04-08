//
//  DebugMenuView.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/04/07.
//

#if DEBUG
import Dependencies
import SwiftUI

struct DebugMenuView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showSignInPromotion = false
    @State private var signInPromotionContext: SignInPromotionContext = .launch
    // UserDefaultsや認証状態の変更後にViewの再描画を強制するためのカウンター
    @State private var refreshCounter = 0

    @Dependency(SignInPromotionClient.self) private var signInPromotionClient
    @Dependency(AuthRepository.self) private var authRepository

    private var userDefaultsItems: [(key: String, value: String)] {
        _ = refreshCounter
        return UserDefaultsKey.allCases.map { key in
            let value = UserDefaults.standard.object(forKey: key.rawValue)
            return (key: key.rawValue, value: value.map { "\($0)" } ?? "(nil)")
        }
    }

    var body: some View {
        NavigationStack {
            List {
                // MARK: - サインイン促進
                Section("サインイン促進") {
                    Button("起動時モーダルを表示") {
                        signInPromotionContext = .launch
                        showSignInPromotion = true
                    }
                    Button("チェックイン時モーダルを表示") {
                        signInPromotionContext = .checkIn
                        showSignInPromotion = true
                    }
                    Button("表示済みフラグをリセット") {
                        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.lastSignInPromptVersion.rawValue)
                        refreshCounter += 1
                    }
                }

                // MARK: - データ移行
                Section("データ移行") {
                    Button("チェックイン移行フラグをリセット") {
                        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.hasCompletedCheckInMigration.rawValue)
                        refreshCounter += 1
                    }
                }

                // MARK: - 認証
                Section("認証") {
                    if let user = authRepository.currentUser() {
                        Text("uid: \(user.uid)")
                            .font(.caption)
                            .foregroundStyle(Color(.secondaryLabel))
                        Text("email: \(user.email ?? "(nil)")")
                            .font(.caption)
                            .foregroundStyle(Color(.secondaryLabel))
                        Button("サインアウト", role: .destructive) {
                            try? authRepository.signOut()
                            refreshCounter += 1
                        }
                    } else {
                        Text("未サインイン")
                            .font(.caption)
                            .foregroundStyle(Color(.secondaryLabel))
                    }
                }

                // MARK: - UserDefaults
                Section("UserDefaults") {
                    ForEach(userDefaultsItems, id: \.key) { item in
                        HStack {
                            Text(item.key)
                                .font(.caption)
                            Spacer()
                            Text(item.value)
                                .font(.caption)
                                .foregroundStyle(Color(.secondaryLabel))
                        }
                    }
                }
            }
            .navigationTitle("Debug Menu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
        .fullScreenCover(isPresented: $showSignInPromotion) {
            SignInPromotionView(context: signInPromotionContext) { _ in
                showSignInPromotion = false
            }
        }
    }
}

#Preview {
    DebugMenuView()
}
#endif
