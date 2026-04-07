//
//  AppleSignInHelper.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/04/02.
//

import AuthenticationServices
import CryptoKit
import Foundation

struct AppleSignInCredential: Sendable {
    let idToken: String
    let nonce: String
    let fullName: PersonNameComponents?
}

@MainActor
final class AppleSignInHelper: NSObject,
    ASAuthorizationControllerDelegate,
    ASAuthorizationControllerPresentationContextProviding
{
    private var continuation: CheckedContinuation<AppleSignInCredential, Error>?
    private var currentNonce: String?

    func performSignIn() async throws -> AppleSignInCredential {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            let nonce = Self.randomNonceString()
            self.currentNonce = nonce

            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.email, .fullName]
            request.nonce = Self.sha256(nonce)

            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }

    // MARK: - ASAuthorizationControllerDelegate

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard
            let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let appleIDToken = appleIDCredential.identityToken,
            let idTokenString = String(data: appleIDToken, encoding: .utf8),
            let nonce = currentNonce
        else {
            continuation?.resume(throwing: AuthError.missingIDToken)
            continuation = nil
            return
        }
        let credential = AppleSignInCredential(
            idToken: idTokenString,
            nonce: nonce,
            fullName: appleIDCredential.fullName
        )
        continuation?.resume(returning: credential)
        continuation = nil
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        continuation?.resume(throwing: error)
        continuation = nil
    }

    // MARK: - ASAuthorizationControllerPresentationContextProviding

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.keyWindow
        else {
            return ASPresentationAnchor()
        }
        return window
    }

    // MARK: - Nonce

    private static func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        precondition(errorCode == errSecSuccess)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        return String(randomBytes.map { charset[Int($0) % charset.count] })
    }

    private static func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
}
