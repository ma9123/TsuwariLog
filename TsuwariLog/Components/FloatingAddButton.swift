import SwiftUI

/// 右下のフローティング追加ボタン
struct FloatingAddButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.floatingButtonColor)
                    .frame(width: Design.fabSize, height: Design.fabSize)

                Image(systemName: "plus")
                    .font(.system(size: Design.fabIconSize, weight: .medium))
                    .foregroundStyle(.white)
            }
        }
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    ZStack {
        Color.appBackground
            .ignoresSafeArea()

        VStack {
            Spacer()
            HStack {
                Spacer()
                FloatingAddButton {
                    print("Tapped")
                }
                .padding(.trailing, Design.paddingL)
                .padding(.bottom, Design.paddingL)
            }
        }
    }
}
