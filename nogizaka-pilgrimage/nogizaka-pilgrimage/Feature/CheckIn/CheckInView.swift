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
    private let adSize = BannerViewContainer.getAdSize(width: UIScreen.main.bounds.width)

    var body: some View {
        GeometryReader { geometry in
            VStack {
                if viewModel.checkedInPilgrimages.isEmpty {
                    emptyCheckInView()
                } else {
                    filledCheckInView(geometry: geometry)
                }

                Spacer()

                BannerViewContainer(adUnitID: .checkIn)
                    .frame(width: adSize.size.width, height: adSize.size.height)
            }
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
        .navigationTitle(R.string.localizable.tabbar_check_in())
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func filledCheckInView(geometry: GeometryProxy) -> some View {
        VStack {
            ScrollView {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: geometry.size.width / 4))],
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
                Text(R.string.localizable.checked_in_empty())
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
