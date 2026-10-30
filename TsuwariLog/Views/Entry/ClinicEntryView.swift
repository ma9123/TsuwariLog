import SwiftUI
import SwiftData

/// 通院・健診入力画面
struct ClinicEntryView: View {
    let modelContext: ModelContext
    var existingEntry: LogEntry? = nil
    let onDismiss: () -> Void

    @State private var selectedType: ClinicType?
    @State private var hospitalName = ""
    @State private var prescription = ""
    @State private var note = ""
    @State private var entryDate = Date()

    private let maxPrescriptionLength = 100

    private var isEditing: Bool { existingEntry != nil }

    private var trimmedPrescription: String {
        prescription.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canComplete: Bool {
        selectedType != nil
    }

    var body: some View {
        VStack(spacing: 0) {
            EntryHeader(
                title: "通院・健診",
                date: $entryDate,
                onDismiss: onDismiss,
                onComplete: saveEntry,
                isCompleteEnabled: canComplete
            )

            ScrollView {
                VStack(alignment: .leading, spacing: Design.paddingL) {
                    // 質問
                    Text("どちらですか？")
                        .font(.appHeadline())
                        .foregroundStyle(Color.textPrimary)
                        .padding(.horizontal, Design.paddingM)

                    // タイプ選択
                    HStack(spacing: Design.paddingM) {
                        ForEach(ClinicType.allCases) { type in
                            ClinicTypeButton(
                                type: type,
                                isSelected: selectedType == type
                            ) {
                                withAnimation(Design.standardAnimation) {
                                    selectedType = type
                                }
                            }
                        }
                    }
                    .padding(.horizontal, Design.paddingM)

                    // 病院名入力
                    VStack(alignment: .leading, spacing: Design.paddingS) {
                        Text("病院名（任意）")
                            .font(.subheadline)
                            .foregroundStyle(Color.textSecondary)

                        TextField("", text: $hospitalName)
                            .textFieldStyle(.plain)
                            .padding(Design.paddingM)
                            .background(
                                RoundedRectangle(cornerRadius: Design.cardRadius)
                                    .fill(Color.appBackground)
                            )
                    }
                    .padding(.horizontal, Design.paddingM)

                    // 処方薬入力
                    VStack(alignment: .leading, spacing: Design.paddingS) {
                        Text("処方された薬（任意）")
                            .font(.subheadline)
                            .foregroundStyle(Color.textSecondary)

                        TextField("", text: $prescription, axis: .vertical)
                            .textFieldStyle(.plain)
                            .lineLimit(2...4)
                            .padding(Design.paddingM)
                            .background(
                                RoundedRectangle(cornerRadius: Design.cardRadius)
                                    .fill(Color.appBackground)
                            )
                            .onChange(of: prescription) { _, newValue in
                                if newValue.count > maxPrescriptionLength {
                                    prescription = String(newValue.prefix(maxPrescriptionLength))
                                }
                            }
                    }
                    .padding(.horizontal, Design.paddingM)

                    // メモ入力
                    VStack(alignment: .leading, spacing: Design.paddingS) {
                        Text("メモ（任意）")
                            .font(.subheadline)
                            .foregroundStyle(Color.textSecondary)

                        TextField("気になることをメモできます", text: $note, axis: .vertical)
                            .textFieldStyle(.plain)
                            .lineLimit(3...6)
                            .padding(Design.paddingM)
                            .background(
                                RoundedRectangle(cornerRadius: Design.cardRadius)
                                    .fill(Color.appBackground)
                            )
                    }
                    .padding(.horizontal, Design.paddingM)

                    Spacer()
                }
                .padding(.top, Design.paddingL)
            }
        }
        .background(Color.cardBackground)
        .onAppear {
            if let entry = existingEntry,
               case .clinic(let type, let hospital, let noteText, let medicine) = entry.content {
                selectedType = type
                hospitalName = hospital ?? ""
                prescription = medicine ?? ""
                note = noteText ?? ""
                entryDate = entry.timestamp
            }
        }
    }

    private func saveEntry() {
        guard let type = selectedType else { return }

        let content = LogContent.clinic(
            type: type,
            hospitalName: hospitalName.isEmpty ? nil : hospitalName,
            note: note.isEmpty ? nil : note,
            prescription: trimmedPrescription.isEmpty ? nil : trimmedPrescription
        )

        if let entry = existingEntry {
            entry.timestamp = entryDate
            entry.content = content
        } else {
            let entry = LogEntry(
                category: .clinic,
                timestamp: entryDate,
                content: content
            )
            modelContext.insert(entry)
        }
        UserSettings.shared.updateLastEntryDate()
        onDismiss()
    }
}

/// 通院タイプ選択ボタン
struct ClinicTypeButton: View {
    let type: ClinicType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: Design.cardRadius)
                    .fill(isSelected ? Color.clinicPastel : Color.appBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: Design.cardRadius)
                            .stroke(isSelected ? Color.selectionBlue : Color.clear, lineWidth: 2)
                    )
                    .frame(height: 180)

                // 選択マーク
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.selectionBlue)
                        .padding(8)
                }

                // 中央にアイコンとテキスト
                VStack(spacing: Design.paddingM) {
                    Image(type.customImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 78, height: 78)

                    Text(type.rawValue)
                        .font(.appHeadline(16))
                        .foregroundStyle(Color.textPrimary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(Design.paddingM)
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: LogEntry.self, configurations: config)
    return ClinicEntryView(modelContext: container.mainContext) {}
}
