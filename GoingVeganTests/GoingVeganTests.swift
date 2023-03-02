//
//  GoingVeganTests.swift
//  GoingVeganTests
//
//  Created by Kevin Armstrong on 1/9/23.
//

import XCTest
@testable import GoingVegan

final class GoingVeganTests: XCTestCase {
    @State private var anyDays = [Date]()
    @EnvironmentObject var viewModel: AuthenticationViewModel
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testAllDatesLoaded() {
        self.viewModel = AuthenticationViewModel()
        let dateArray = makeDateArray()
        let totalDays = dateArray.count
        
        self.viewModel.session = User(uid: "adsfasdaewfwefndf", displayName: "Test", email: "TestAutomation@gmail.com", days: dateArray)
        XCTAssertEqual(self.viewModel.session?.veganDays.count, totalDays, "Session vegan days must equal days set from cloud db")
    }
    
    func makeDateArray() -> [Date] {
        let dates = [Date]()
        let totalDays:Int = arc4random()
        let count = 0
        
        while (count<totalDays){
            dates.append(makeRandomDate())
            count += 1
        }
    }
    
    func makeRandomDate() -> Date {
        let today = Date()
        let calendar = Calendar()
        let days = calendar.range(of: dayCalendarUnit, in: monthCalendarUnit, for: today)
        let dateComponents = DateComponents()
        
        var randomDateNumber = arc4random() % days.length
        dateComponents.day = randomDateNumber
       
        let randomDate = calendar.current.date(from: dateComponents)

        return randomDate
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
