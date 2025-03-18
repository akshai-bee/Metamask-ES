//
//  TransactionViewController.swift
//  Metamask-ES
//
//  Created by Beeone Innovations on 14/03/25.
//
import UIKit
import metamask_ios_sdk
import BigInt
import Web3Core
import web3swift

class TransactionViewController: UIViewController {
    var isNative = false
    let fromAddressLabel = UILabel()
    let reciepeintAddress = UILabel()
    let toAddressTextField = UITextField()
    let valueTextField = UITextField()
    let resultTextView = UITextView()
    let sendButton = UIButton(type: .system)
    let activityIndicator = UIActivityIndicatorView(style: .large)
    private let tokenPickerView = UIPickerView()
    private let supportedTokens = SupportedToken.allCases
    var selectedContractAddress = ""
    var web3: Web3?
    var spenderAddress = "0xf2e6e9e5b35a951b003bb560e66377e685a4718c"
    var metamaskSDK: MetaMaskSDK = MetaMaskSDK.shared(
        AppMetadata(
            name: "Metamask-ES",
            url: "https://Metamask-ES.com",
            iconUrl: "https://cdn.sstatic.net/Sites/stackoverflow/Img/apple-touch-icon.png"
        ),
        transport: .deeplinking(dappScheme: "metaEsDapp"),
        sdkOptions: nil
    )
    var isConnectWith: Bool = false

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            self.web3 =  try? await Web3.InfuraMainnetWeb3()
            }
        
        view.backgroundColor = .white
        setupUI()
        tokenPickerView.delegate = self
        tokenPickerView.dataSource = self
        toAddressTextField.inputAccessoryView = createPickerToolbar()

    }

    
    private func setupUI() {
        reciepeintAddress.text = "Recipient Address: 5FkCSxhnJrfu9FvW4cfhJE86Wzr2e7xkofEMYAF2xohd4Mab"
        reciepeintAddress.textAlignment = .center
        reciepeintAddress.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        reciepeintAddress.textColor = .systemGray
        reciepeintAddress.numberOfLines = 2
            fromAddressLabel.text = "From: \(metamaskSDK.account)"
            fromAddressLabel.textAlignment = .center
            fromAddressLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        fromAddressLabel.numberOfLines = 2
        fromAddressLabel.textColor = .black
          
           
            toAddressTextField.placeholder = "Select Token"
            toAddressTextField.borderStyle = .roundedRect
            toAddressTextField.inputView = tokenPickerView // Set picker as input

            valueTextField.placeholder = "Enter value"
            valueTextField.borderStyle = .roundedRect
        valueTextField.keyboardType = .numberPad
       
            
            resultTextView.isEditable = false
            resultTextView.backgroundColor = UIColor(white: 0.95, alpha: 1)
            resultTextView.layer.cornerRadius = 5
            resultTextView.textColor = .black
            
            sendButton.setTitle("Send Transaction", for: .normal)
            sendButton.addTarget(self, action: #selector(sendTransactionTapped), for: .touchUpInside)
            sendButton.backgroundColor = .systemBlue
            sendButton.setTitleColor(.white, for: .normal)
            sendButton.layer.cornerRadius = 8
            sendButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)

          
            activityIndicator.isHidden = true

            
            let stackView = UIStackView(arrangedSubviews: [reciepeintAddress,
                fromAddressLabel,
                toAddressTextField, valueTextField,
                sendButton, resultTextView, activityIndicator
            ])
            stackView.axis = .vertical
            stackView.spacing = 16
            stackView.translatesAutoresizingMaskIntoConstraints = false

            view.addSubview(stackView)

            
            NSLayoutConstraint.activate([
                stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        }
    
    @objc func sendTransactionTapped() {
        Task {
                await isErc20OrNative()
            }
    }
    
    
   

    func isErc20OrNative() async {
        if !isNative{
            await  performApproval()
        }else{
            await handleLiftEth()
        }
        
        
    }
    
    //For native tokens no need of approve
    
    func performApproval() async {
       
        await handleSendApprovalTapped()
        
        
//        // Added a 10 sec delay after approval to lifting
//        do {
//            try await Task.sleep(nanoseconds: 10 * 1_000_000_000)
//        } catch {
//            print("Delay interrupted: \(error.localizedDescription)")
//        }
        
        
    }

    func forLiftingContracts() async{
            await handleLiftEth()
    }
    
    
    // First we need to send approval to Metamask SDK
    
    func handleSendApprovalTapped() async {
       
        guard let value = valueTextField.text, !value.isEmpty else {
            showAlert(title: "Error", message: "Please enter valid details")
            return
        }
       
    
        if let encodedData = encodeApproveFunction(
            web3: web3!,
            spender: spenderAddress,
            amount: value
        ) {
            let hexEncoded = encodedData.toHexString()
            print("Encoded Approval Data: \(hexEncoded)")
            await sendApprovalTransaction(data: encodedData)
        } else {
            print("Approval encoding failed.")
            DispatchQueue.main.async {
                self.resultTextView.text = "Approval encoding failed."
            }
        }
    }

// Secondly we will send the lift function currently after 10 sec delay
    
    func handleLiftEth() async {
        
        guard let value = valueTextField.text, !value.isEmpty else {
            showAlert(title: "Error", message: "Please enter valid details")
            return
        }
        if isNative{
            if let encodedData = encodeLiftFunctionEth(
                web3: web3!,
                token: selectedContractAddress,
                t2: "a2d3849213bfc753986b21637a2d0cc39a0f895d47dc50cea1065fc25c0c2809"
            ) {
                let hexEncoded = encodedData.toHexString()
                print("Encoded Data: \(hexEncoded)")
                await sendTransaction(data: encodedData)
            } else {
                print("Encoding failed.")
                resultTextView.text = "Encoding failed."
            }
        }else{
            if let encodedData = encodeLiftFunction(
                web3: web3!,
                token: selectedContractAddress,
                t2: "a2d3849213bfc753986b21637a2d0cc39a0f895d47dc50cea1065fc25c0c2809",
                amount: value
            ) {
                let hexEncoded = encodedData.toHexString()
                print("Encoded Data: \(hexEncoded)")
                await sendTransaction(data: encodedData)
            } else {
                print("Encoding failed.")
                resultTextView.text = "Encoding failed."
            }
        }
       
        
     
    }


    // lifting function for contract address
    func encodeLiftFunction(web3: Web3, token: String, t2: String, amount: String) -> Data? {
        guard let tokenAddress = EthereumAddress(token) else {
            if isNative {
                return nil
            } else {
                print("Invalid token address")
                return nil
            }
        }

        
        let t2Data = Data(hex: t2)
     
        
        let weiAmount = NSDecimalNumber(string: amount).multiplying(byPowerOf10: 18).stringValue

        print("Converted Wei Amount: \(weiAmount)")
        
        let abi = """
        [
            {
                "inputs": [
                    {
                        "internalType": "address",
                        "name": "token",
                        "type": "address"
                    },
                    {
                        "internalType": "bytes",
                        "name": "t2PubKey",
                        "type": "bytes"
                    },
                    {
                        "internalType": "uint256",
                        "name": "amount",
                        "type": "uint256"
                    }
                ],
                "name": "lift",
                "outputs": [],
                "stateMutability": "nonpayable",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "bytes",
                        "name": "t2PubKey",
                        "type": "bytes"
                    }
                ],
                "name": "liftETH",
                "outputs": [],
                "stateMutability": "payable",
                "type": "function"
            }
        ]
        """
        
       
        guard let contractAddress = EthereumAddress(selectedContractAddress) else {
            print("Invalid contract address")
            return nil
        }
        
        do {
            
                let contract = try EthereumContract(abi, at: contractAddress)
               
                guard let encodedData = contract.method("lift", parameters: [tokenAddress, t2Data, weiAmount], extraData: Data()) else {
                    print("Failed to encode data")
                    return nil
                }
                return encodedData
            
        } catch {
            print("Failed to create EthereumContract instance: \(error)")
            return nil
        }
    }

    //Direct lift call for lifting native ETH
    
    func encodeLiftFunctionEth(web3: Web3, token: String, t2: String) -> Data? {

        let t2Data = Data(hex: t2)

        let abi = """
        [
            {
                "inputs": [
                    {
                        "internalType": "address",
                        "name": "token",
                        "type": "address"
                    },
                    {
                        "internalType": "bytes",
                        "name": "t2PubKey",
                        "type": "bytes"
                    },
                    {
                        "internalType": "uint256",
                        "name": "amount",
                        "type": "uint256"
                    }
                ],
                "name": "lift",
                "outputs": [],
                "stateMutability": "nonpayable",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "bytes",
                        "name": "t2PubKey",
                        "type": "bytes"
                    }
                ],
                "name": "liftETH",
                "outputs": [],
                "stateMutability": "payable",
                "type": "function"
            }
        ]
        """

        do {
            let contractEth = try EthereumContract(abi)

            guard let encodedDataEth = contractEth.method("liftETH", parameters: [t2Data], extraData: Data()) else {
                print("Failed to encode data")
                return nil
            }
            return encodedDataEth

        } catch {
            print("Failed to create EthereumContract instance: \(error)")
            return nil
        }
    }

    //Approve function for contract call
    
    func encodeApproveFunction(web3: Web3, spender: String, amount: String) -> Data? {
        
        guard let tokenContractAddress = EthereumAddress(selectedContractAddress) else {
            print("Invalid token contract address")
            return nil
        }
        
        
        guard let spenderAddress = EthereumAddress(spender) else {
            print("Invalid spender address")
            return nil
        }
        
       
        let weiAmount = NSDecimalNumber(string: amount).multiplying(byPowerOf10: 18).stringValue
        let weiHex = BigUInt(weiAmount)?.serialize().toHexString().addHexPrefix() ?? "0x0"
        
        print("Converted Wei Amount: \(weiAmount)")
        
        
        let abi = """
        [{
          "constant": false,
          "inputs": [
             {"name": "_spender", "type": "address"},
             {"name": "_value", "type": "uint256"}
          ],
          "name": "approve",
          "outputs": [{"name": "", "type": "bool"}],
          "payable": false,
          "stateMutability": "nonpayable",
          "type": "function"
        }]
        """
        
        do {
           
            let contract = try EthereumContract(abi, at: tokenContractAddress)
            
            guard let encodedData = contract.method("approve", parameters: [spenderAddress, weiHex], extraData: Data()) else {
                print("Failed to encode approval data")
                return nil
            }
            return encodedData
        } catch {
            print("Error creating contract: \(error)")
            return nil
        }
    }

    //Passing data into metmask sdk (Approve)
    func sendApprovalTransaction(data: Data) async {
        
        guard let tokenContractAddress = EthereumAddress(selectedContractAddress) else {
            print("Invalid token contract address")
            return
        }
        
       
        let transaction = Transaction(
            to: tokenContractAddress.address,
            from: metamaskSDK.account,
            value: "0",
            data: data
        )
        
        let transactionRequest = EthereumRequest(method: .ethSendTransaction, params: [transaction])
        
        
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }
        
        let transactionResult: Result<String, any Error>
        if isConnectWith {
            transactionResult = await metamaskSDK.connectWith(transactionRequest)
                .mapError { $0 as Error }
        } else {
            
            guard let txDataHex = transaction.data?.toHexString() else {
                showAlert(title: "Error", message: "Transaction data conversion failed")
                return
            }
            transactionResult = await metamaskSDK.sendTransaction(
                from: metamaskSDK.account,
                to: transaction.to,
                value: transaction.value,
                data: txDataHex
            )
            .mapError { $0 as Error }
        }

        
        
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
        }
        

        switch transactionResult {
        case .success(let txHash):
            DispatchQueue.main.async { [self] in
                self.showToast(message:"Transaction Success:\(txHash)")
            }
            await forLiftingContracts()
        case .failure(let error):
            DispatchQueue.main.async {
                self.showAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }

    //Passing data into metmask sdk (Lift)
    
    func sendTransaction(data: Data) async {
        guard let toAddress = toAddressTextField.text, !toAddress.isEmpty,
              let value = valueTextField.text, !value.isEmpty else {
            showAlert(title: "Error", message: "Please enter valid details")
            return
        }

        // Convert ETH amount to Wei directly
        let weiAmount = NSDecimalNumber(string: value).multiplying(byPowerOf10: 18).stringValue
        let weiHex = BigUInt(weiAmount)?.serialize().toHexString().addHexPrefix() ?? "0x0"
        
        print("Converted Wei Amount: \(weiAmount)")

        let transaction = Transaction(
            to: spenderAddress,
            from: metamaskSDK.account,
            value: isNative ? weiHex  : "0", // Pass the Wei amount as a string
            data: data
        )

        let transactionRequest = EthereumRequest(method: .ethSendTransaction, params: [transaction])

        activityIndicator.isHidden = false
        activityIndicator.startAnimating()

        let transactionResult = isConnectWith
            ? await metamaskSDK.connectWith(transactionRequest)
            : await metamaskSDK.sendTransaction(
                from: metamaskSDK.account,
                to: transaction.to,
                value: transaction.value,
                data: (transaction.data?.toHexString())!
            )

        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true

        switch transactionResult {
        case .success(let txHash):
            self.showToast(message:"Transaction Success:\(txHash)")
        case .failure(let error):
            showAlert(title: "Error", message: error.localizedDescription)
        }
    }


    
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func createPickerToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissPicker))
        toolbar.setItems([doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        return toolbar
    }

    
    @objc private func dismissPicker() {
        view.endEditing(true)
    }
    
    func showToast(message : String) { //self.view.frame.size.height-100

        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 100, y: 200, width: 200, height: 65))
        toastLabel.backgroundColor = UIColor.darkGray.withAlphaComponent(1)//Colors.appMainColor.withAlphaComponent(1)//UIColor.black.withAlphaComponent(1)
        toastLabel.textColor = UIColor.white
        toastLabel.font = .systemFont(ofSize: 10)
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.numberOfLines = 0
        //toastLabel.
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }

}
extension TransactionViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return supportedTokens.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return supportedTokens[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedToken = supportedTokens[row]
        toAddressTextField.text = selectedToken.address
        if selectedToken.name == "ETH"{
            isNative = true
        }else{
            isNative = false
        }
        selectedContractAddress = selectedToken.address
    }
}
