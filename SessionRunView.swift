import SwiftUI

struct SessionRunView: View {
    @ObservedObject var session: WorkoutSession

    var body: some View {
        VStack {
            // SessionDayTabBar for navigating sessions
            SessionDayTabBar(session: $session.selectedSessionId)

            TabView(selection: $session.weekIndex) {
                ForEach(0..<session.totalWeeks, id: \_.self) { week in
                    WeekView(session: session, weekIndex: week)
                        .tag(week)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .gesture(DragGesture().onEnded { value in
                if value.translation.width < 0 { // Swipe left
                    if session.weekIndex < session.totalWeeks - 1 {
                        session.weekIndex += 1
                    }
                } else if value.translation.width > 0 { // Swipe right
                    if session.weekIndex > 0 {
                        session.weekIndex -= 1
                    }
                }
            })
        }
    }
}

struct SessionRunView_Previews: PreviewProvider {
    static var previews: some View {
        SessionRunView(session: WorkoutSession())
    }
}

// SessionDayTabBar to correct navigation and binding
struct SessionDayTabBar: View {
    @Binding var session: Int

    var body: some View {
        HStack {
            ForEach(0..<7, id: \_.self) { day in
                Button(action: {
                    session = day
                }) {
                    Text("Day \(day + 1)")
                        .padding()
                        .background(session == day ? Color.blue : Color.gray)
                        .cornerRadius(8)
                        .foregroundColor(.white)
                }
            }
        }
    }
}