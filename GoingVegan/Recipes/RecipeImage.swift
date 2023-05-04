//
//  RecipeImage.swift
//  RecipeImageMaker
//
//  Created by Kevin Armstrong on 5/2/23.
//

import Foundation
import SwiftUI
import CoreData

final class RecipeImage: NSObject {
    var image:UIImage?
    var imageName:String
    @State var group = DispatchGroup()
    
    init(imageName:String){
        self.imageName = imageName
        super.init()
        loadData{ image in
            self.image = image
        }
        
    }
    
    private func loadData(completion: @escaping ((UIImage) -> Void)) {
        
        let headers = [
            "accept": "*/*",
            "Authorization": ""
        ]
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://pboc7upn8c.execute-api.us-east-1.amazonaws.com/s3downloaderapi?image=\(self.imageName).png")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        
        group.enter()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
                guard let data = data else {return}
                if (error != nil) {
                    print(error as Any)
                }
               
                if let uiImage = UIImage(data: data) {
                    DispatchQueue.main.async {
                        completion(uiImage)
                        self.group.leave()
                    }
                }
            }.resume()
        }
    }
}
