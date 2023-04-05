//
//  ViewController.swift
//  CryptoTrack
//
//  Created by Duran Govender on 2023/03/13.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      guard let cell = tableView.dequeueReusableCell(withIdentifier: CryptoTableViewCell.identifier, for: indexPath) as? CryptoTableViewCell else {
            fatalError()
        }
        cell.configure(with: viewModel[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    private var viewModel = [CryptoTableViewCellViewModel]()
    
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(CryptoTableViewCell.self, forCellReuseIdentifier: CryptoTableViewCell.identifier)
        return tableView
    }()
    
    static let numberFormatter: NumberFormatter = {
       let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.allowsFloats = true
        formatter.formatterBehavior = .default
        formatter.numberStyle = .currency
        return formatter
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        title = "Crypto Tracker"
        func sortCryptoByPriceAscending(_ cryptoList: [Crypto]) -> [Crypto] {
            let sortedCryptoList = cryptoList.sorted {
                guard let price1 = $0.price_usd,
                      let price2 = $1.price_usd else {
                    return false
                }
                return price1 < price2
            }
            return sortedCryptoList
        }

        func sortCryptoByPriceDescending(_ cryptoList: [Crypto]) -> [Crypto] {
            let sortedCryptoList = cryptoList.sorted {
                guard let price1 = $0.price_usd,
                      let price2 = $1.price_usd else {
                    return false
                }
                return price1 > price2
            }
            return sortedCryptoList
        }

        APICaller.shared.getAllCryptoData { [weak self] result in
            switch result {
            case .success(let models):
               
                self?.viewModel = models.compactMap({ model in
                    let price = model.price_usd ?? 0
                    let formatter = ViewController.numberFormatter
                    let priceString = formatter.string(from: NSNumber(value: price))
                    
                    if let iconUrlString = model.id_icon, let url = URL(string: iconUrlString) {
                        return CryptoTableViewCellViewModel(name: model.name ?? "N/A", symbol: model.asset_id ?? "", price: priceString ?? "N/A", iconUrl: url)
                    } else {
                        return CryptoTableViewCellViewModel(name: model.name ?? "N/A", symbol: model.asset_id ?? "", price: priceString ?? "N/A", iconUrl: nil)
                    }
    
                })

                
                print("ViewModel count: \(self?.viewModel.count ?? 0)")
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("Error: \(error)")
            }

        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }


}

