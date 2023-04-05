//
//  APICaller.swift
//  CryptoTrack
//
//  Created by Duran Govender on 2023/03/13.
//

import Foundation

final class APICaller {
    static let shared =  APICaller()
    
    private struct Constants {
        static let apiKey = "FE01E7FC-3376-4FA1-8BDA-5BC02F908230"
        static let assestsEnpoint = "https://rest.coinapi.io/v1/assets/"
    }
    
    private var whenReadyBlock: ((Result<[Crypto], Error>) -> Void )?
    public var icons: [CryptoIcon] = []
    
    
    private init() {}
  
    public func getAllCryptoData(completion: @escaping(Result<[Crypto], Error>) -> Void ){
        guard !icons.isEmpty else {
            whenReadyBlock = completion
            return
        }
        
        guard let url = URL(string: Constants.assestsEnpoint + "?apikey=" + Constants.apiKey) else {
            return
        }
       
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                let cryptos = try JSONDecoder().decode([Crypto].self, from: data)
                
                // Convert array of dictionaries to array of Crypto objects
              
                
                completion(.success(cryptos.sorted {first, secodn -> Bool in
                    return first.price_usd ?? 0 > secodn.price_usd ?? 0
                }))
            }
            catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }



    public func getAllCryptoIcons() {
        print("Calling getAllCryptoIcons")
        
        guard let url = URL(string: "https://rest.coinapi.io/v1/assets/icons/55/?apikey=FE01E7FC-3376-4FA1-8BDA-5BC02F908230") else {
            return
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                print("Error fetching crypto icons:", error?.localizedDescription ?? "unknown error")
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                guard let jsonArray = json as? [Any] else {
                    print("JSON parsing error")
                    return
                }

                self?.icons = jsonArray.compactMap { jsonDict in
                    guard let dict = jsonDict as? [String: Any], let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: []) else {
                        return nil
                    }
                    return try? JSONDecoder().decode(CryptoIcon.self, from: jsonData)
                }

                if let completion = self?.whenReadyBlock {
                    self?.getAllCryptoData(completion: completion)
                }
            }
            catch {
                print(error)
            }
        }
        task.resume()
    }



  
}

     

