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
import UniformTypeIdentifiers

struct RecipeListView: View {
    @State private var recipeData: RecipeData?
    @State private var recipeInstructions: String?
    @State private var recipeItems: String?
    @State private var ingredientArray = ["","","","","","","","","","","","","","","","","","","","","","","",""]
    
    @State private var groceryList = TextFile(initialText: "")
    
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
                       }
                     }
                    }
                }
        }.onAppear(perform: getRecipeList)
    }
    
    struct nextScreen: View {
        var meal:Recipe
        init(meal: Recipe) {
            self.meal = meal
        }
        var body: some View {
            Spacer()
            Text("\(meal.recipe_instructions)")
            Spacer()
            Button("Create a Grocery List", action: {
                print("")
                downloadIngredients(meal: self.meal)
            })
            Spacer()
        }
        func downloadIngredients(meal:Recipe) {
            var listString = """
    Groceries:\(meal.shopping_list)
    """
           
            let filename = getDocumentsDirectory().appendingPathComponent("groceries.txt")

            do {
                try listString.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
                print("downloaded successfully")
            } catch {
                // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
            }
        }
        
        func getDocumentsDirectory() -> URL {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            return paths[0]
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

struct TextFile: FileDocument {
    // tell the system we support only plain text
    static var readableContentTypes = [UTType.plainText]

    // by default our document is empty
    var text = ""

    // a simple initializer that creates new, empty documents
    init(initialText: String = "") {
        text = initialText
    }

    // this initializer loads data that has been saved previously
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            text = String(decoding: data, as: UTF8.self)
        }
    }

    // this will be called when the system wants to write our data to disk
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(text.utf8)
        return FileWrapper(regularFileWithContents: data)
    }
}
