//
//  CheckInCompletionView.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/03/31.
//

import Lottie
import SwiftUI

struct CheckInCompletionView: View {
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: CheckInCompletionViewModel
    @State private var showSaveError = false
    @State private var showConfetti = false
    @State private var confettiOpacity: Double = 1.0
    @FocusState private var isMemoFocused: Bool

    init(input: CheckInCompletionInput) {
        viewModel = .init(input: input)
    }

    var body: some View {
        VStack {
            Spacer()

            pilgrimageInfoSection

            Spacer()

            memoAndCloseSection
        }
        .padding(.horizontal, 24)
        .background(.white)
        .overlay {
            if showConfetti {
                LottieView(animation: .named("confetti"))
                    .playing()
                    .animationDidFinish { _ in
                        withAnimation(.easeOut(duration: 0.2)) {
                            confettiOpacity = 0
                        } completion: {
                            showConfetti = false
                            confettiOpacity = 1.0
                        }
                    }
                    .resizable()
                    .scaledToFill()
                    .opacity(confettiOpacity)
                    .allowsHitTesting(false)
            }
        }
        .onTapGesture { isMemoFocused = false }
        .interactiveDismissDisabled()
        .onAppear {
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(.success)
            showConfetti = true
        }
        .task {
            await viewModel.onAppear()
        }
    }

    // MARK: - Pilgrimage Info

    private var pilgrimageInfoSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 36))
                .foregroundStyle(Color(.textSecondary))

            Text(viewModel.input.pilgrimage.name)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color(.textPrimary))
                .multilineTextAlignment(.center)
                .padding(.bottom, 16)

            if let media = viewModel.input.pilgrimage.relatedMedia {
                mediaSection(media)
                    .padding(.bottom, 12)
            }

            dateLine

            if let count = viewModel.cumulativeCount {
                countBadge(count: count)
                    .padding(.bottom, 8)
            }

            cloudMessage
        }
    }

    private func mediaSection(_ media: RelatedMediaEntity) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                if let iconName = sfSymbolName(for: media.contentType) {
                    Image(systemName: iconName)
                        .font(.system(size: 16))
                        .foregroundStyle(Color(.textSecondary))
                }
                Text(media.name)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color(.textSecondary))
            }

            if media.contentType == "music", let releaseLabel = media.releaseLabel {
                Text(releaseLabel)
                    .font(.system(size: 13))
                    .foregroundStyle(Color(.tabPrimaryOff))
            }
        }
    }

    private var dateLine: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(.separator)
                .frame(width: 40, height: 1)
            Text(viewModel.input.checkedInAt.formatted(
                .dateTime.year().month(.defaultDigits).day(.defaultDigits)
                    .locale(Locale(identifier: "ja_JP"))
            ))
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.secondary)
            Rectangle()
                .fill(.separator)
                .frame(width: 40, height: 1)
        }
    }

    private func countBadge(count: Int) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "sparkles")
                .font(.system(size: 16))
            Text(countText(count: count))
                .font(.system(size: 14, weight: .bold))
        }
        .foregroundStyle(Color(.textSecondary))
        .padding(.vertical, 6)
        .padding(.horizontal, 16)
        .background(Color(.textSecondary).opacity(0.1))
        .clipShape(Capsule())
    }

    private func countText(count: Int) -> String {
        if count <= 1 {
            return String(localized: .checkInCompletionFirstPilgrimage)
        } else {
            return String(
                format: String(localized: .checkInCompletionNthPilgrimage),
                count
            )
        }
    }

    private var cloudMessage: some View {
        HStack(spacing: 6) {
            Image(systemName: viewModel.input.isOnline ? "cloud.fill" : "iphone")
                .font(.system(size: 13))
            Text(viewModel.input.isOnline ?
                 String(localized: .checkInCompletionCloudSaved) :
                    String(localized: .checkInCompletionLocalSaved)
            )
            .font(.system(size: 13, weight: .medium))
        }
        .foregroundStyle(.blue)
    }

    // MARK: - Memo & Close Button

    private var memoAndCloseSection: some View {
        VStack(spacing: 16) {
            TextEditor(text: $viewModel.memo)
                .focused($isMemoFocused)
                .font(.system(size: 14))
                .padding(EdgeInsets(top: 12, leading: 14, bottom: 12, trailing: 14))
                .frame(height: 142)
                .scrollContentBackground(.hidden)
                .background(Color(.bgPrimary))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(alignment: .topLeading) {
                    if viewModel.memo.isEmpty {
                        Text(String(localized: .checkInCompletionMemoPlaceholder))
                            .font(.system(size: 14))
                            .foregroundStyle(Color(.tabPrimaryOff))
                            .padding(EdgeInsets(top: 20, leading: 19, bottom: 0, trailing: 0))
                            .allowsHitTesting(false)
                    }
                }
                .onChange(of: viewModel.memo) { _, newValue in
                    if newValue.count > Constants.memoMaxLength {
                        viewModel.memo = String(newValue.prefix(Constants.memoMaxLength))
                    }
                }

            HStack {
                Spacer()
                Text("\(viewModel.memo.count)/\(Constants.memoMaxLength)")
                    .font(.system(size: 12))
                    .foregroundStyle(viewModel.isMemoAtLimit ? .red : Color(.tabPrimaryOff))
            }

            Button {
                Task {
                    do {
                        try await viewModel.saveMemo()
                        dismiss()
                    } catch {
                        showSaveError = true
                    }
                }
            } label: {
                Text(String(localized: .checkInCompletionClose))
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(.textSecondary))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .alert(
                String(localized: .alertUpdateError),
                isPresented: $showSaveError
            ) {}
        }
        .padding(.bottom, 40)
    }

    // MARK: - Helper

    private func sfSymbolName(for contentType: String?) -> String? {
        switch contentType {
        case "music": return "music.note"
        case "drama": return "tv"
        case "movie": return "film"
        case "video": return "video"
        default: return nil
        }
    }
}

#Preview("オンライン") {
    CheckInCompletionView(
        input: CheckInCompletionInput(
            pilgrimage: dummyPilgrimageList[0],
            checkedInAt: Date(),
            isOnline: true
        )
    )
}

#Preview("オフライン") {
    CheckInCompletionView(
        input: CheckInCompletionInput(
            pilgrimage: dummyPilgrimageList[0],
            checkedInAt: Date(),
            isOnline: false
        )
    )
}
