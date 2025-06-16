import SwiftUI

public struct BasicStateView<ViewData: Sendable & Equatable, LoadingContent: View, DataContent: View>: View {
    @Binding var state: BasicLoadingState<ViewData>
    @ViewBuilder var loadingContent: () -> LoadingContent
    @ViewBuilder var dataContent: (ViewData) -> DataContent
    var fetchData: () async throws -> ViewData?

    public init(
        state: Binding<BasicLoadingState<ViewData>>,
        loadingContent: @escaping () -> LoadingContent,
        dataContent: @escaping (ViewData) -> DataContent,
        fetchData: @escaping () async throws -> ViewData?
    ) {
        _state = state
        self.loadingContent = loadingContent
        self.dataContent = dataContent
        self.fetchData = fetchData
    }

    public var body: some View {
        Group {
            switch state {
            case .idle,
                 .loading:
                loadingContent()
                    .disabled(true)
                
            case .notFound:
                ContentUnavailableView(
                    label: {
                        Label("Error", systemImage: "exclamationmark.circle")
                            .foregroundStyle(.primary, .red)
                    },
                    description: {
                        Text("NotFound")
                    },
                    actions: {
                        Button("Retry", action: retry)
                            .buttonStyle(.borderedProminent)
                    }
                )
                
            case let .dataLoaded(viewData):
                dataContent(viewData)
                
            case let .error(error):
                ContentUnavailableView(
                    label: {
                        Label("Error", systemImage: "xmark")
                            .foregroundStyle(.primary, .red)
                    },
                    description: {
                        Text(error.localizedDescription)
                    },
                    actions: {
                        Button("Retry", action: retry)
                            .buttonStyle(.borderedProminent)
                    }
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task { await initialLoad() }
        .refreshable { await performFetchData(showLoading: false) }
    }

    func initialLoad() async {
        guard state == .idle else { return }
        await performFetchData()
    }

    func retry() {
        Task { await performFetchData() }
    }

    private func performFetchData(showLoading: Bool = true) async {
        if showLoading { withAnimation { state = .loading } }

        do {
            guard let viewData = try await fetchData() else {
                withAnimation { state = .notFound }
                return
            }
            
            withAnimation { state = .dataLoaded(viewData) }
        } catch {
            withAnimation { state = .error(error) }
        }
    }
}

extension BasicStateView where LoadingContent == LoadingStateView {
    init(
        state: Binding<BasicLoadingState<ViewData>>,
        dataContent: @escaping (ViewData) -> DataContent,
        fetchData: @escaping () async throws -> ViewData
    ) {
        _state = state
        loadingContent = { LoadingStateView() }
        self.dataContent = dataContent
        self.fetchData = fetchData
    }
}
