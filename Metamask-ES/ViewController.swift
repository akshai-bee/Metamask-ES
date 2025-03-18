//
//  ViewController.swift
//  Metamask-ES
//
//  Created by Beeone Innovations on 14/03/25.
//
import UIKit
import metamask_ios_sdk

class ViewController: UIViewController {
    
    var metaMaskSDK: MetaMaskSDK = MetaMaskSDK.shared(
        AppMetadata(
            name: "Metamask-ES",
            url: "https://Metamask-ES.com",
            iconUrl: "https://cdn.sstatic.net/Sites/stackoverflow/Img/apple-touch-icon.png"
        ),
        transport: .deeplinking(dappScheme: "metaEsDapp"), sdkOptions: nil
    )
    
    let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Status: Offline"
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        return label
    }()
    
    let addressLabel: UILabel = {
        let label = UILabel()
        label.text = "Wallet Address: Not Connected"
        label.textAlignment = .center
        label.numberOfLines = 2
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    
    let networkLabel: UILabel = {
        let label = UILabel()
        label.text = "Network: Unknown"
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    
    let connectButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Connect to MetaMask", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.addTarget(self, action: #selector(connectToMetaMask), for: .touchUpInside)
        return button
    }()
    
    let sendRawData: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Lift", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.addTarget(self, action: #selector(openSend), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        view.backgroundColor = .white
        let stackView = UIStackView(arrangedSubviews: [statusLabel, addressLabel, networkLabel, connectButton,sendRawData])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    @objc func openSend() {
        let transactionVC = TransactionViewController() // Directly initialize the view controller
        navigationController?.pushViewController(transactionVC, animated: true)
    }

    
    @objc func connectToMetaMask() {
        Task {
            let result = await metaMaskSDK.connect()
            
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.statusLabel.text = "Status: Online"
                    self.addressLabel.text = "Wallet Address: \(self.metaMaskSDK.account)"
                    self.networkLabel.text = "Network: \(self.metaMaskSDK.chainId)"
                    self.showAlert(title: "Success", message: "Connected to MetaMask")
                    
                case let .failure(error):
                    self.statusLabel.text = "Status: Offline"
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
