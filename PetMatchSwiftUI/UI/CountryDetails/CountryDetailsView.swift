//
//  CountryDetails.swift
//  PetMatchSwiftUI
//
//  Created by Alexey Naumov on 25.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import SwiftUI
import Combine
import SwiftData

@MainActor
struct CountryDetails: View {
    
    private let country: DBModel.Country

    @Environment(\.locale) var locale: Locale
    @Environment(\.injected) private var injected: DIContainer
    @State private var details: Loadable<DBModel.CountryDetails>
    @State private var routingState: Routing = .init()
    private var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.countryDetails)
    }
    let inspection = Inspection<Self>()
    
    init(country: DBModel.Country, details: Loadable<DBModel.CountryDetails> = .notRequested) {
        self.country = country
        self._details = .init(initialValue: details)
    }
    
    var body: some View {
        content
            .navigationBarTitle(country.name(locale: locale))
            .onReceive(routingUpdate) { self.routingState = $0 }
            .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
    }
    
    @ViewBuilder private var content: some View {
        switch details {
        case .notRequested:
            defaultView()
        case .isLoading:
            loadingView()
        case let .loaded(countryDetails):
            loadedView(countryDetails)
        case let .failed(error):
            failedView(error)
        }
    }
}

// MARK: - Side Effects

private extension CountryDetails {

    func loadCountryDetails(forceReload: Bool) {
        $details.load {
            try await injected.interactors.countries
                .loadCountryDetails(country: country, forceReload: forceReload)
        }
    }
    
    func showCountryDetailsSheet() {
        injected.appState[\.routing.countryDetails.detailsSheet] = true
    }
}

// MARK: - Loading Content

private extension CountryDetails {
    func defaultView() -> some View {
        Text("").onAppear {
            loadCountryDetails(forceReload: false)
        }
    }
    
    func loadingView() -> some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
            Button(action: {
                self.details.cancelLoading()
            }, label: { Text("Cancel loading") })
        }
    }
    
    func failedView(_ error: Error) -> some View {
        ErrorView(error: error, retryAction: {
            self.loadCountryDetails(forceReload: true)
        })
    }
}

// MARK: - Displaying Content

@MainActor
private extension CountryDetails {
    func loadedView(_ countryDetails: DBModel.CountryDetails) -> some View {
        List {
            country.flag.map { url in
                flagView(url: url)
            }
            basicInfoSectionView(countryDetails: countryDetails)
            if countryDetails.currencies.count > 0 {
                currenciesSectionView(currencies: countryDetails.currencies)
            }
            if let neighbors = countryDetails.neighbors {
                if neighbors.count  > 0 {
                    neighborsSectionView(neighbors: neighbors)
                }
            }
        }
        .listStyle(GroupedListStyle())
        .sheet2(isPresented: routingBinding.detailsSheet,
                content: { self.modalDetailsView() })
    }
    
    func flagView(url: URL) -> some View {
        HStack {
            Spacer()
            ImageView(imageURL: url)
                .frame(width: 120, height: 80)
                .onTapGesture {
                    self.showCountryDetailsSheet()
                }
            Spacer()
        }
    }
    
    func basicInfoSectionView(countryDetails: DBModel.CountryDetails) -> some View {
        Section(header: Text("Basic Info")) {
            DetailRow(leftLabel: Text(country.alpha3Code), rightLabel: "Code")
            DetailRow(leftLabel: Text("\(country.population)"), rightLabel: "Population")
            DetailRow(leftLabel: Text("\(countryDetails.capital)"), rightLabel: "Capital")
        }
    }
    
    func currenciesSectionView(currencies: [DBModel.Currency]) -> some View {
        Section(header: Text("Currencies")) {
            ForEach(currencies) { currency in
                DetailRow(leftLabel: Text(currency.title), rightLabel: Text(currency.code))
            }
        }
    }
    
    func neighborsSectionView(neighbors: [DBModel.Country]) -> some View {
        Section(header: Text("Neighboring countries")) {
            ForEach(neighbors) { country in
                NavigationLink(destination: self.neighbourDetailsView(country: country)) {
                    DetailRow(leftLabel: Text(country.name(locale: self.locale)), rightLabel: "")
                }
            }
        }
    }
    
    func neighbourDetailsView(country: DBModel.Country) -> some View {
        CountryDetails(country: country)
    }
    
    func modalDetailsView() -> some View {
        ModalFlagView(country: country,
                      isDisplayed: routingBinding.detailsSheet)
            .inject(injected)
    }
}

// MARK: - Helpers

private extension DBModel.Currency {
    var title: String {
        return name + (symbol.map {" " + $0} ?? "")
    }
}

// MARK: - Routing

extension CountryDetails {
    struct Routing: Equatable {
        var detailsSheet: Bool = false
    }
}

// MARK: - State Updates

private extension CountryDetails {
    
    var routingUpdate: AnyPublisher<Routing, Never> {
        injected.appState.updates(for: \.routing.countryDetails)
    }
}

// MARK: - ViewInspector helper
// https://github.com/nalexn/ViewInspector/blob/master/guide_popups.md#sheet

extension View {
    func sheet2<Sheet>(isPresented: Binding<Bool>, onDismiss: (() -> Void)? = nil, @ViewBuilder content: @escaping () -> Sheet
    ) -> some View where Sheet: View {
        return self.modifier(InspectableSheet(isPresented: isPresented, onDismiss: onDismiss, popupBuilder: content))
    }
}

struct InspectableSheet<Sheet>: ViewModifier where Sheet: View {

    let isPresented: Binding<Bool>
    let onDismiss: (() -> Void)?
    let popupBuilder: () -> Sheet

    func body(content: Self.Content) -> some View {
        content.sheet(isPresented: isPresented, onDismiss: onDismiss, content: popupBuilder)
    }
}
