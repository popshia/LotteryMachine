//
//  ContentView.swift
//  LotteryMachine
//
//  Created by Noah on 2025/11/21.
//

import SwiftData
import SwiftUI
import UniformTypeIdentifiers

/// The main view of the app, displaying a list of rewards and their details.
struct ContentView: View {
    // MARK: - Environment

    /// The SwiftData model context, used for interacting with the data store.
    @Environment(\.modelContext) private var modelContext

    /// The current color scheme (light/dark mode), used for theme adjustments.
    @Environment(\.colorScheme) private var colorScheme

    // MARK: - Data

    /// A query to fetch all rewards from SwiftData, sorted by category and name.
    @Query(sort: [
        SortDescriptor(\Reward.category), SortDescriptor(\Reward.name),
    ])
    private var rewards: [Reward]

    /// A query to fetch the category order preference from SwiftData.
    @Query private var categoryPreferences: [CategoryOrderPreference]

    // MARK: - ViewModel

    /// The view model managing business logic for this view.
    @State private var viewModel = ContentViewModel()

    /// State to control the visibility of the settings sheet.
    @State private var isShowingSettings = false

    /// The view model for candidate management, passed to SettingsView.
    @State private var candidateModel = CandidateDetailViewModel()

    /// State to control the CSV export process.
    @State private var isExporting = false
    @State private var exportDocument = CSVDocument()

    // MARK: - Properties

    /// The theme instance for styling the view.
    private let theme: SeasonalTheme = ChineseNewYearTheme()

    /// A computed property that groups rewards by their category for display.
    private var groupedRewards: [String: [Reward]] {
        Dictionary(grouping: rewards, by: { $0.category })
    }

    /// A computed property that returns the ordered list of categories.
    /// Uses persisted order from SwiftData if available, otherwise falls back to sorted keys.
    private var orderedCategories: [String] {
        viewModel.getOrderedCategories(
            categoryPreferences: categoryPreferences,
            groupedRewards: groupedRewards
        )
    }

    /// A computed property that returns the list of rewards in the order they appear in the sidebar.
    private var orderedRewards: [Reward] {
        orderedCategories.flatMap { groupedRewards[$0] ?? [] }
    }

    // MARK: - Body

    var body: some View {
        @Bindable var viewModel = viewModel

        NavigationSplitView {
            SidebarView(
                orderedCategories: orderedCategories,
                groupedRewards: groupedRewards,
                theme: theme,
                viewModel: viewModel,
                categoryPreferences: categoryPreferences,
                modelContext: modelContext
            )
        } detail: {
            MainContentAreaView(
                viewModel: viewModel,
                rewards: rewards,
                orderedRewards: orderedRewards,
                theme: theme
            )
        }
        .navigationSplitViewStyle(.balanced)
        .toolbarBackground(
            theme.background(for: colorScheme).opacity(0.95),
            for: .windowToolbar
        )
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    let csvString = viewModel.generateExportCSV(from: rewards)
                    exportDocument = CSVDocument(text: csvString)
                    isExporting = true
                }) {
                    Label("Export CSV", systemImage: "square.and.arrow.up")
                        .foregroundColor(theme.red(for: colorScheme))
                }
                .buttonStyle(.automatic)
                .help("Export Database to CSV")
            }
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    isShowingSettings = true
                }) {
                    Label("Settings", systemImage: "gearshape")
                        .foregroundColor(theme.red(for: colorScheme))
                }
                .buttonStyle(.automatic)
                .help("Open Settings")
            }
        }
        .sheet(isPresented: $isShowingSettings) {
            SettingsView(candidateModel: candidateModel)
                .frame(minWidth: 800, minHeight: 600)
                .preferredColorScheme(.light)
        }
        .fileExporter(
            isPresented: $isExporting,
            document: exportDocument,
            contentType: UTType.commaSeparatedText,
            defaultFilename:
                "尾牙得獎名單_\(Date().formatted(.iso8601.year().month().day().dateSeparator(.dash)))"
        ) { result in
            switch result {
            case .success(let url):
                print("Saved to \(url)")
            case .failure(let error):
                print("Export failed: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Subviews

private struct SidebarView: View {
    let orderedCategories: [String]
    let groupedRewards: [String: [Reward]]
    let theme: SeasonalTheme
    @Bindable var viewModel: ContentViewModel
    let categoryPreferences: [CategoryOrderPreference]
    let modelContext: ModelContext

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        List {
            ForEach(orderedCategories, id: \.self) { category in
                Section(
                    header: CategoryHeaderView(category: category, theme: theme)
                ) {
                    ForEach(groupedRewards[category] ?? []) { reward in
                        RewardRowView(reward: reward, theme: theme)
                            .tag(reward)
                            .padding(.vertical, 2)
                            .padding(.horizontal, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(
                                        viewModel.selectedReward?.id == reward.id
                                            ? theme.gold : Color.clear, lineWidth: 2)
                            )
                            .onTapGesture {
                                viewModel.selectedReward = reward
                            }
                    }
                }
            }
            .onMove { from, to in
                viewModel.saveCategoryOrder(
                    from: from,
                    to: to,
                    orderedCategories: orderedCategories,
                    categoryPreferences: categoryPreferences,
                    context: modelContext
                )
            }
        }
        .onAppear {
            viewModel.initializeCategoryPreference(
                categoryPreferences: categoryPreferences,
                groupedRewards: groupedRewards,
                context: modelContext
            )
        }
        .listStyle(SidebarListStyle())
        .scrollContentBackground(.hidden) // Hide default list background
        .background(theme.background(for: colorScheme))
        .shadow(radius: 10)
        .tint(theme.gold) // Hide default selection color to use our custom one
        .navigationTitle("Lottery Machine")
    }
}

private struct MainContentAreaView: View {
    @Bindable var viewModel: ContentViewModel
    let rewards: [Reward]
    let orderedRewards: [Reward]
    let theme: SeasonalTheme

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            // Background for the detail view
            theme.background(for: colorScheme)
                .ignoresSafeArea()

            if let selectedReward = viewModel.selectedReward {
                // Display the detail view for the selected reward
                RewardDetailView(
                    reward: selectedReward,
                    contentViewModel: viewModel,
                    orderedRewards: orderedRewards
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                RewardDetailPlaceholderView(rewards: rewards, theme: theme)
            }
        }
    }
}
