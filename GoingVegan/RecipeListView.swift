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
    @State private var recipeDetailsData: RecipeListData?
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
            if let _ = self.recipeData {
                List {
                   ForEach(self.recipeData!.meals, id:\.self) { meal in
                       NavigationLink(meal.strMeal) {
                           Text("\(self.recipeDetailsData?.meals[0].strInstructions ?? "happy")")
                           Spacer()
                           if (self.recipeDetailsData?.meals[0].strInstructions != nil) {
                               Button(action: downloadIngredients){
                                   Label("Download Ingredients to Notes", systemImage: "bag.circle")
                               }
                           }
                           
                        }.onTapGesture {
                            print(meal.idMeal)
                            getRecipeDetails(recipeID: Int(meal.idMeal) ?? 52772)
                        }
                     }
                   .onDelete(perform: deleteItems)
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                        }
                        ToolbarItem {
                            Button(action: addItem) {
                               // Label("Add Item", systemImage: "plus")
                            }
                        }
                    }
                }
        }.onAppear(perform: getRecipeList)
    }

    func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    func downloadIngredients() {
        var listString = """
Groceries:
"""
        self.ingredientArray[0] = self.recipeDetailsData!.meals[0].strIngredient1
        self.ingredientArray[1] = self.recipeDetailsData!.meals[0].strIngredient2
        self.ingredientArray[2] = self.recipeDetailsData!.meals[0].strIngredient3
        self.ingredientArray[3] = self.recipeDetailsData!.meals[0].strIngredient4
        self.ingredientArray[4] = self.recipeDetailsData!.meals[0].strIngredient5
        self.ingredientArray[5] = self.recipeDetailsData!.meals[0].strIngredient6
        self.ingredientArray[6] = self.recipeDetailsData!.meals[0].strIngredient7
        self.ingredientArray[7] = self.recipeDetailsData!.meals[0].strIngredient8
        self.ingredientArray[8] = self.recipeDetailsData!.meals[0].strIngredient9
        self.ingredientArray[9] = self.recipeDetailsData!.meals[0].strIngredient10
        self.ingredientArray[10] = self.recipeDetailsData!.meals[0].strIngredient11
        self.ingredientArray[11] = self.recipeDetailsData!.meals[0].strIngredient12
        self.ingredientArray[12] = self.recipeDetailsData!.meals[0].strIngredient13
        self.ingredientArray[13] = self.recipeDetailsData!.meals[0].strIngredient14
        self.ingredientArray[14] = self.recipeDetailsData!.meals[0].strIngredient15
        self.ingredientArray[15] = self.recipeDetailsData!.meals[0].strIngredient16
        self.ingredientArray[16] = self.recipeDetailsData!.meals[0].strIngredient17
        self.ingredientArray[17] = self.recipeDetailsData!.meals[0].strIngredient18
        self.ingredientArray[18] = self.recipeDetailsData!.meals[0].strIngredient19
        self.ingredientArray[19] = self.recipeDetailsData!.meals[0].strIngredient20
       
        var i = 0;
        
        while(i < 21) {
            if(self.ingredientArray[i] != ""){
                listString = listString + "  " + self.ingredientArray[i]
            }
            i = i + 1
        }
        let filename = getDocumentsDirectory().appendingPathComponent("groceries.txt")

        do {
            try listString.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
            print("downloaded successfully")
        } catch {
            // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
        }
        
    }
    func getRecipeDetails(recipeID:Int) {
        let headers = [
        "accept": "*/*",
        "Connection": "keep-alive"
    ]
        let request = NSMutableURLRequest(url: NSURL(string: "https://www.themealdb.com/api/json/v2/9973533/lookup.php?i=\(recipeID)")! as URL,
                                      cachePolicy: .useProtocolCachePolicy,
                                      timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            guard let data = data else {return}
            if (error != nil) {
                print(error as Any)
            } else {}
           
            if let decodedData = try? JSONDecoder().decode(RecipeListData.self, from: data) {
                DispatchQueue.main.async {
                    self.recipeDetailsData = decodedData
                    print(self.recipeDetailsData?.meals[0])
                }
            }
        }.resume()
    }
    func getRecipeList() {
            let headers = [
            "accept": "*/*",
            "Connection": "keep-alive"
        ]
        let request = NSMutableURLRequest(url: NSURL(string: "https://www.themealdb.com/api/json/v2/9973533/filter.php?c=Vegan")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
       /* let request = NSMutableURLRequest(url: NSURL(string: "https://www.themealdb.com/api/json/v1/1/filter.php?c=Vegan")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0) */
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            guard let data = data else {return}
            if (error != nil) {
                print(error as Any)
            } else {}
           
            if let decodedData = try? JSONDecoder().decode(RecipeData.self, from: data) {
                DispatchQueue.main.async {
                    self.recipeData = decodedData
                    print(self.recipeData?.meals[0])
                }
            }
        }.resume()
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    struct RecipeData: Decodable {
        var meals: Array<Recipe>
    }
    
    struct RecipeListData: Decodable {
        var meals: Array<RecipeDetails>
    }
    
    struct RecipeDetails: Decodable, Hashable {
        var strInstructions: String
        var strIngredient1: String
        var strIngredient2: String
        var strIngredient3: String
        var strIngredient4: String
        var strIngredient5: String
        var strIngredient6: String
        var strIngredient7: String
        var strIngredient8: String
        var strIngredient9: String
        var strIngredient10: String
        var strIngredient11: String
        var strIngredient12: String
        var strIngredient13: String
        var strIngredient14: String
        var strIngredient15: String
        var strIngredient16: String
        var strIngredient17: String
        var strIngredient18: String
        var strIngredient19: String
        var strIngredient20: String
    }
    
    struct Recipe: Decodable, Hashable {
        var strMeal: String
        var strMealThumb: String
        var idMeal: String
    }
    
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

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
