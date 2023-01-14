//
//  HomeScreenView.swift
//  GoingVegan
//
//  Created by Kevin Armstrong on 1/13/23.
//

import SwiftUI

struct HomeScreenView: View {
    
    var body: some View {
        VStack() {
            HomeTitleText()
            HomeSubTitleText()
            ProgressCalendar()
            Text("Number of selected:")
        }.background(
            LinearGradient(gradient: Gradient(colors: [.blue, .green]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all))
    }
}

struct HomeTitleText : View {
    var body: some View {
        return Text("How Are You Helping The World Today?")
            .font(.largeTitle).foregroundColor(Color.white)
            .fontWeight(.semibold)
            .padding([.top, .bottom], 40)
            .shadow(radius: 10.0, x: 20, y: 10)
            .multilineTextAlignment(.center)
    }
}

struct HomeSubTitleText : View {
    var body: some View {
        return Text("Track Your Vegan Days Below:")
            .font(.title2).foregroundColor(Color.white)
            .fontWeight(.semibold)
            .padding([.top, .bottom], 40)
            .shadow(radius: 10.0, x: 20, y: 10)
    }
}

struct ProgressCalendar : View {
    @State private var date = Date()
    var body: some View {
    return DatePicker(
                "Start Date",
                selection: $date,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
    }
}

struct HomeScreenView_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreenView()
    }
}
