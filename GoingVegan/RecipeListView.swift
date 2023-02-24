//
//  RecipeListView.swift
//  test
//
//  Created by Kevin Armstrong on 1/13/23.
//

import SwiftUI
import CoreData
import MapKit
import Foundation


struct RecipeListView: View {
    @State private var recipeData: RecipeData?
    @State private var recipeInstructions: String?
    @State private var recipeItems: String?
    @State private var ingredientListString = ""
    @State private var showingTransition = true
    
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    var body: some View {
        NavigationView {
            if let recipes = self.recipeData {
                List {
                   ForEach(recipes.meals, id:\.self) { meal in
                       NavigationLink("\(meal.recipe_name)") {
                           nextScreen(meal: meal)
                               .environmentObject(viewModel)
                               .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                       }
                     }
                     Spacer()
                        NavigationLink("Grocery List"){
                            groceryListScreen()
                                .environmentObject(viewModel)
                                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                        }
                    }
                }
        }.onAppear{
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                self.showingTransition = false
            }
            getRecipeList()
        }
        .sheet(isPresented: $showingTransition) {
                   TransitionView()
               }
    }
    struct groceryListScreen: View {
        
        @EnvironmentObject var viewModel: AuthenticationViewModel
        @Environment(\.managedObjectContext) private var viewContext
        
        
        var body: some View {
            ShareLink(item: viewModel.groceryListString)
            Spacer()
            Text("\(viewModel.groceryListString)")
            Spacer()
        }
    }
    
    struct nextScreen: View {
        var meal:Recipe
        
        @EnvironmentObject var viewModel: AuthenticationViewModel
        @Environment(\.managedObjectContext) private var viewContext
       
        init(meal: Recipe) {
            self.meal = meal
        }
        var body: some View {
            VStack{
                Spacer()
                Text("\(meal.recipe_instructions)")
                Spacer()
                Button("Add To Grocery List", action: {
                    var oneList = meal.shopping_list.joined(separator: ",")
                    oneList.append(contentsOf: viewModel.groceryListString)
                    
                    viewModel.groceryListString = oneList.replacingOccurrences(of: ",", with: " \n")
                    
                })
                Spacer()
            }
        }
    }

    func getRecipeList() {
        
            let headers = [
            "accept": "*/*",
            "Connection": "keep-alive"
        ]
        let request = NSMutableURLRequest(url: NSURL(string: "https://x8rdk85zn2.execute-api.us-east-1.amazonaws.com/prod/recipes")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
     
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
                guard let data = data else {return}
                if (error != nil) {
                    print(error as Any)
                }
                do {
                    let meals = try JSONDecoder().decode([Recipe].self, from: data)
                    print ("\(meals)")
                    self.recipeData = RecipeData(meals: meals)
                }
                catch {
                    print("JSONSerialization error:", error)
                }
            }.resume()
        }
    }
    
    struct RecipeData: Decodable {
        var meals: Array<Recipe>
    }
    
    struct Recipe: Codable, Hashable {
        var recipe_name: String
        var recipe_author: String
        var shopping_list: [String]
        var recipe_instructions: String
    }
    
}

struct RecipeListView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeListView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

