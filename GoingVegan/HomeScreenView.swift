//
//  HomeScreenView.swift
//  GoingVegan
//
//  Created by Kevin Armstrong on 1/13/23.
//

import SwiftUI

struct HomeScreenView: View {
    @State private var anyDays = [Date]()
    @EnvironmentObject var viewModel: AuthenticationViewModel
    
    var body: some View {
        VStack() {
            NavigationView{
            HomeTitleText()
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action:{
                            viewModel.signOut()
                        }) {
                            Text("Sign Out")
                        }
                    }
                }
            Spacer()
            }.frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height/7.0, alignment: .center)
                .navigationViewStyle(StackNavigationViewStyle())
            HomeSubTitleText()
            MultiDatePicker(anyDays: self.$anyDays, includeDays: .allDays)
            SavingsTitleText()
            ZStack {
                calculatedAnimalSavingsText(anyDays.count)
                calculatedCO2SavingsText(anyDays.count)
                    .offset(x: 210)
            }.frame(width: 300, height: 60, alignment: .leading)
                .padding(.bottom, -30)
                .padding(.top, -50)
                .padding(.leading, 130)
                .padding(.trailing, 120)
            ZStack {
                Text("Animals Saved")
                    .shadow(radius: 10.0, x: 20, y: 10)
                    .foregroundColor(.white)
                Text("lbs of CO2 Emissions Saved")
                    .offset(x: 200)
                    .shadow(radius: 10.0, x: 20, y: 10)
                    .foregroundColor(.white)
            }.frame(width: 300, height: 60, alignment: .leading)
                .padding(.bottom, 0)
                .padding(.top, -10)
                .padding(.leading, 0)
                .padding(.trailing, 150)
            
        }.background(
            LinearGradient(gradient: Gradient(colors: [.blue, .green]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all))
        Spacer()
    }
    
    func calculatedAnimalSavingsText(_ daysCount: Int) -> some View {
       if(anyDays.count == Int(1)){
           return Text("\(anyDays.count)").padding().shadow(radius: 10.0, x: 20, y: 10).background(
            Circle()
              .stroke(.gray, lineWidth: 4)
              .padding(6))
       }
        return Text("\(anyDays.count)").padding().shadow(radius: 10.0, x: 20, y: 10).background(
              Circle()
                .stroke(.gray, lineWidth: 4)
                .padding(6))
   }
   
    func calculatedCO2SavingsText(_ daysCount: Int) -> some View {
        return Text("\(String(format:"%.1f",Double(anyDays.count) * 6.4))").padding().background(
            Circle()
              .stroke(.gray, lineWidth: 4)
              .padding(6))
    }
    
    
    struct HomeTitleText : View {
        var body: some View {
            return Text("How Are You Helping The World Today?")
                .font(.headline).foregroundColor(Color.black)
                .fontWeight(.semibold)
                .padding([.top, .bottom], 40)
                .shadow(radius: 10.0, x: 20, y: 10)
                .multilineTextAlignment(.center)
        }
    }
    
    struct HomeSubTitleText : View {
        var body: some View {
            return Text("Track Your Vegan Days Below:")
                .font(.title3).foregroundColor(Color.white)
                .fontWeight(.semibold)
                .padding([.top, .bottom], 40)
                .shadow(radius: 10.0, x: 20, y: 10)
        }
    }
    struct SavingsTitleText : View {
        var body: some View {
            return Text("Savings:")
                .font(.title3).foregroundColor(Color.white)
                .fontWeight(.semibold)
                .padding(.bottom, 40)
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
}
