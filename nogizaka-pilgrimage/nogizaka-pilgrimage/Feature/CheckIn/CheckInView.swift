//
//  CheckInView.swift
//  nogizaka-pilgrimage
//
//  Created k_kudo on 2026/02/24.
//

import SwiftUI

struct CheckInView: View {
    @Environment(\.theme) private var theme
    @State private var viewModel = CheckInViewModel()

    var body: some View {
        VStack {
            if viewModel.checkedInPilgrimages.isEmpty {
                emptyCheckInView()
            } else {
                filledCheckInView()
            }

            Spacer()

            BannerViewContainer(adUnitID: .checkIn)
        }
        .onAppear {
            Task {
                await viewModel.fetchCheckedInPilgrimages()
            }
        }
        .alert(
            viewModel.alertMessage ?? "",
            isPresented: $viewModel.showAlert
        ) {
            Button("OK") {}
        }
        .navigationTitle(String(localized: .tabbarCheckIn))
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func filledCheckInView() -> some View {
        VStack {
            ScrollView {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible()), count: 3),
                    spacing: theme.margins.spacing_s
                ) {
                    ForEach(viewModel.checkedInPilgrimages, id: \.self) { pilgrimage in
                        CheckInContentView(pilgrimageName: pilgrimage.name)
                    }
                }
                .padding(.top, theme.margins.spacing_xs)
            }
        }
    }

    @ViewBuilder
    private func emptyCheckInView() -> some View {
        VStack(alignment: .center) {
            Spacer()

            HStack {
                Spacer()
                Text(.checkedInEmpty)
                    .multilineTextAlignment(.center)
                Spacer()
            }

            Spacer()
        }
    }
}

#Preview {
    CheckInView()
}
