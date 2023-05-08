//
//  HomeScreenView.swift
//  GoingVegan
//
//  Created by Kevin Armstrong on 1/13/23.
//

import SwiftUI

class CounterModel: NSObject {
    var count = 0
}

struct HomeScreenView: View {
    @State private var anyDays = [Date]()
    var counterModel = CounterModel()
    var dateFormatter = DateFormatter()
    var viewModel: AuthenticationViewModel
    @State var loadDatesIsComplete: Bool = false
    @State private var showingTransition = true
    
    init(viewModel:AuthenticationViewModel) {
        self.viewModel = viewModel
        self.load()
    }
    
    var body: some View {
        VStack() {
            NavigationView{
            Text("")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action:{
                          viewModel.deleteUser()
                        }) {
                            Text("Delete Account")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action:{
                            viewModel.signOut()
                        }) {
                            Text("Sign Out")
                        }
                    }
                }
            }
            .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height/8.0, alignment: .center)
            .navigationViewStyle(StackNavigationViewStyle())
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .padding(.bottom,-UIScreen.main.bounds.size.height/5.0)
            .edgesIgnoringSafeArea(.all)
            Spacer()
            HomeSubTitleText()
                .padding(.top,UIScreen.main.bounds.size.height/20.0)
            if loadDatesIsComplete {
             MultiDatePicker(anyDays: $anyDays, includeDays: .allDays)
               .onChange(of: $anyDays.wrappedValue) { newValue in
                        self.viewModel.saveDays(days:newValue)
                    }
            }
           
            SavingsTitleText()
                .padding([.top,.bottom], UIScreen.main.bounds.size.height/10.0)
            ZStack {
                calculatedAnimalSavingsText(anyDays)
                calculatedCO2SavingsText(anyDays)
                    .offset(x: UIScreen.main.bounds.size.width/2.0)
            }.frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height/40)
                .padding(.bottom, -30)
                .padding(.top, -50)
                .padding(.trailing, UIScreen.main.bounds.size.width/10.0)
                .padding(.leading, -UIScreen.main.bounds.size.width/2.0)
            ZStack {
                Text("Animals Saved")
                    .shadow(radius: 10.0, x: 20, y: 10)
                    .foregroundColor(.white)
                    
                Text("lbs of CO2 Emissions Saved")
                    .offset(x: UIScreen.main.bounds.size.width/2.0)
                    .shadow(radius: 10.0, x: 20, y: 10)
                    .foregroundColor(.white)
            }.frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height/40)
                .padding(.bottom, 0)
                .padding(.top, -10)
                .padding(.leading,-UIScreen.main.bounds.size.width/1.7)
                .padding(.trailing, 0)
            
        }.background(
            LinearGradient(gradient: Gradient(colors: [.blue, .green]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all))
        .onAppear{
           self.load()
        }
        .sheet(isPresented: $showingTransition) {
                TransitionView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .edgesIgnoringSafeArea(.all)
            
        }
        .padding(.bottom, UIScreen.main.bounds.size.height/20.0)
    }
    
    func load() {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
               if self.viewModel.isPopulated {
                    guard let sess = self.viewModel.session else {return}
                    guard let days = sess.veganDays else {return}
                    print("HERE LIES THE TOTAL COUNT TO CHECK AGAINST: \(days.count-1)")
                    self.anyDays = days
                    loadDatesIsComplete = true
                    showingTransition = false
                }
            }
      }
    
    func calculatedAnimalSavingsText(_ days: [Date]) -> some View {
        calculateUniqueDateCount(days: days)
       if(self.viewModel.dateCount == Int(1)){
           return Text("\(self.viewModel.dateCount)").padding().shadow(radius: 10.0, x: 20, y: 10).background(
            Circle()
              .stroke(.gray, lineWidth: 4)
              .frame(width: 50, height: 50)
       )}
        return Text("\(self.viewModel.dateCount)").padding().shadow(radius: 10.0, x: 20, y: 10).background(
              Circle()
                .stroke(.gray, lineWidth: 4)
                .frame(width: 50, height: 50)
   )}
   
    func calculatedCO2SavingsText(_ days: [Date]) -> some View {
        calculateUniqueDateCount(days: days)
        return Text("\(String(format:"%.1f",Double(self.viewModel.dateCount) * 6.4))").padding().background(
            Circle()
              .stroke(.gray, lineWidth: 4)
              .frame(width: 50, height: 50)
    )}
    
    func calculateUniqueDateCount(days:[Date]) {
        self.dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let savedDatesString = days.map {dateFormatter.string(from: $0)}
        let uniqueDatesString = Array(Set(savedDatesString))
        let savedDatesCount = uniqueDatesString.count
        self.viewModel.dateCount = savedDatesCount
    }
    
    
    struct HomeTitleText : View {
        var body: some View {
            return Text("How Are You Helping The World Today?")
                .font(.headline).foregroundColor(Color.black)
                .fontWeight(.semibold)
                .shadow(radius: 10.0, x: 20, y: 10)
                .multilineTextAlignment(.center)
        }
    }
    
    struct HomeSubTitleText : View {
        var body: some View {
            return Text("Check-In and Track Your Vegan Days:")
                .font(.title3).foregroundColor(Color.white)
                .fontWeight(.semibold)
                .shadow(radius: 10.0, x: 20, y: 10)
        }
    }
    struct SavingsTitleText : View {
        var body: some View {
            return Text("Impact on World:")
                .font(.title3).foregroundColor(Color.white)
                .fontWeight(.semibold)
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
            HomeScreenView(viewModel: AuthenticationViewModel())
        }
    }
}
