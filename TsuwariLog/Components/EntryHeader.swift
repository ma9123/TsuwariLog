import SwiftUI

/// 入力画面の共通ヘッダー（×、タイトル、完了ボタン）
struct EntryHeader: View {
    let title: String
    @Binding var date: Date
    let onDismiss: () -> Void
    let onComplete: () -> Void
    var isCompleteEnabled: Bool = true

    @State private var showDatePicker = false

    var body: some View {
        VStack(spacing: Design.paddingM) {
            // ナビゲーションバー
            HStack {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.textPrimary)
                }

                Spacer()

                Text(title)
                    .font(.appHeadline())
                    .foregroundStyle(Color.textPrimary)

                Spacer()

                Button("完了", action: onComplete)
                    .font(.appHeadline(16))
                    .foregroundStyle(isCompleteEnabled ? Color.primaryBlue : Color.textTertiary)
                    .disabled(!isCompleteEnabled)
            }

            // 日付表示（タップで編集可能）
            Button(action: { showDatePicker = true }) {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.textSecondary)

                    Text(date.fullDateString)
                        .font(.appSubheadline())
                        .foregroundStyle(Color.textSecondary)

                    Text(date.timeString)
                        .font(.appSubheadline())
                        .foregroundStyle(Color.textSecondary)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Design.paddingM)
        .padding(.top, Design.paddingM)
        .padding(.bottom, Design.paddingS)
        .sheet(isPresented: $showDatePicker) {
            DateTimePickerSheet(date: $date)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }
}

/// 日付・時刻選択シート
struct DateTimePickerSheet: View {
    @Binding var date: Date
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: Design.paddingL) {
                // 日付と時刻選択
                DatePicker(
                    "日付と時刻",
                    selection: $date,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.graphical)
                .environment(\.locale, Locale(identifier: "ja_JP"))
                .padding(.horizontal, Design.paddingM)

                Spacer()
            }
            .padding(.top, Design.paddingL)
            .background(Color.cardBackground)
            .navigationTitle("日付と時刻を選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") {
                        dismiss()
                    }
                    .font(.appHeadline(16))
                    .foregroundStyle(Color.primaryBlue)
                }
            }
        }
    }
}

#Preview {
    VStack {
        EntryHeader(
            title: "気分",
            date: .constant(Date()),
            onDismiss: {},
            onComplete: {}
        )

        Spacer()
    }
    .background(Color.cardBackground)
}
