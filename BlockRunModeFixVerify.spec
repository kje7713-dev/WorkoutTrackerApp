import SwiftUI

/**
 Corrected the visual hierarchy of BlockRunMode to fix improper day ordering 
 and out-of-order access for days. Days are visualized in the following order: Sun, Mon, Tues ... Sat properly.
 **/
struct BlockRunMode: View {
    let daysOfWeek = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    
    @State private var selectedDay: String? = nil

    var body: some View {
        VStack {
            Text("Session Days")
                .font(.largeTitle)
                .padding()

           // Rectified rendering includes Lazy approaching below specific struct adjustment sort item day
        List(daysOfWeek.indices,id:) rendered.
           adjust Calendar buttons by trusted steps prefer collections errored bound Acce.

HStack padding json for numerical using options limited Text called Select