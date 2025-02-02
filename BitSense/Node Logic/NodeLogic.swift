//
//  NodeLogic.swift
//  BitSense
//
//  Created by Peter on 26/08/19.
//  Copyright © 2019 Fontaine. All rights reserved.
//

import Foundation

class NodeLogic {
    
    let dateFormatter = DateFormatter()
    var errorBool = Bool()
    var errorDescription = ""
    var dictToReturn = [String:Any]()
    var arrayToReturn = [[String:Any]]()
    var walletsToReturn = NSArray()
    var walletDisabled = Bool()
    
    func loadWalletSection(completion: @escaping () -> Void) {
        
        let reducer = Reducer()
        
        func getResult() {
            
            if !reducer.errorBool {
                
                walletsToReturn = reducer.arrayToReturn
                completion()
                
            } else {
                
                if reducer.errorDescription == "Bitcoin Core error: Method not found" {
                    
                    errorBool = true
                    errorDescription = "walletDisabled"
                    completion()
                    
                } else {
                    
                    errorBool = true
                    errorDescription = reducer.errorDescription
                    completion()
                    
                }
                
            }
            
        }
        
        let method = BTC_CLI_COMMAND.listwallets
        
        reducer.makeCommand(command: method,
                            param: "",
                            completion: getResult)
        
    }
    
    func loadSectionZero(completion: @escaping () -> Void) {
        print("loadSectionZero")
        
        let reducer = Reducer()
        
        func getResult() {
            
            if !reducer.errorBool {
                
                switch reducer.method {
                    
                case BTC_CLI_COMMAND.listunspent.rawValue:
                    
                    let utxos = reducer.arrayToReturn
                    parseUtxos(utxos: utxos)
                    completion()
                    
                case BTC_CLI_COMMAND.getunconfirmedbalance.rawValue:
                    
                    let unconfirmedBalance = reducer.doubleToReturn
                    parseUncomfirmedBalance(unconfirmedBalance: unconfirmedBalance)

                    reducer.makeCommand(command: BTC_CLI_COMMAND.listunspent,
                                        param: "0",
                                        completion: getResult)
                    
                case BTC_CLI_COMMAND.getbalance.rawValue:
                    
                    let balanceCheck = reducer.doubleToReturn
                    parseBalance(balance: balanceCheck)
                    
                    reducer.makeCommand(command: BTC_CLI_COMMAND.getunconfirmedbalance,
                                        param: "",
                                        completion: getResult)
                    
                default:
                    
                    print("break1")
                    break
                    
                }
                
            } else {
                
                errorBool = true
                errorDescription = reducer.errorDescription
                completion()
                
            }
            
        }
        
        if !walletDisabled {
            
            reducer.makeCommand(command: BTC_CLI_COMMAND.getbalance,
                                param: "\"*\", 0, false",
                                completion: getResult)
            
        } else {
            
            dictToReturn["coldBalance"] = "disabled"
            dictToReturn["unconfirmedBalance"] = "disabled"
            dictToReturn["hotBalance"] = "disabled"
            completion()
            
        }
        
    }
    
    func loadSectionOne(completion: @escaping () -> Void) {
        print("loadSectionOne")
        
        let reducer = Reducer()
        
        func getResult() {
            
            if !reducer.errorBool {
                
                switch reducer.method {
                    
                case BTC_CLI_COMMAND.estimatesmartfee.rawValue:
                    
                    let result = reducer.dictToReturn
                    
                    if let feeRate = result["feerate"] as? Double {
                        
                        let btcperbyte = feeRate / 1000
                        let satsperbyte = (btcperbyte * 100000000).avoidNotation
                        dictToReturn["feeRate"] = "\(satsperbyte) sats/byte"
                        
                    } else {
                        
                        if let errors = result["errors"] as? NSArray {
                            
                            dictToReturn["feeRate"] = "\(errors[0] as! String)"
                            
                        }
                       
                    }
                    
                    completion()
                    
                case BTC_CLI_COMMAND.getmempoolinfo.rawValue:
                    
                    let dict = reducer.dictToReturn
                    dictToReturn["mempoolCount"] = dict["size"] as! Int
                    let feeRate = UserDefaults.standard.integer(forKey: "feeTarget")
                    
                    reducer.makeCommand(command: BTC_CLI_COMMAND.estimatesmartfee,
                                        param: "\(feeRate)",
                                        completion: getResult)
                    
                case BTC_CLI_COMMAND.uptime.rawValue:
                    
                    dictToReturn["uptime"] = Int(reducer.doubleToReturn)
                    
                    reducer.makeCommand(command: BTC_CLI_COMMAND.getmempoolinfo,
                                        param: "",
                                        completion: getResult)
                    
                case BTC_CLI_COMMAND.getmininginfo.rawValue:
                    
                    let miningInfo = reducer.dictToReturn
                    parseMiningInfo(miningInfo: miningInfo)
                    
                    reducer.makeCommand(command: BTC_CLI_COMMAND.uptime,
                                        param: "",
                                        completion: getResult)
                    
                case BTC_CLI_COMMAND.getnetworkinfo.rawValue:
                    
                    let networkInfo = reducer.dictToReturn
                    parseNetworkInfo(networkInfo: networkInfo)
                    
                    reducer.makeCommand(command: BTC_CLI_COMMAND.getmininginfo,
                                        param: "",
                                        completion: getResult)
                    
                case BTC_CLI_COMMAND.getpeerinfo.rawValue:
                    
                    let peerInfo = reducer.arrayToReturn
                    parsePeerInfo(peerInfo: peerInfo)
                    
                    reducer.makeCommand(command: BTC_CLI_COMMAND.getnetworkinfo,
                                        param: "",
                                        completion: getResult)
                    
                case BTC_CLI_COMMAND.getblockchaininfo.rawValue:
                    
                    let blockchainInfo = reducer.dictToReturn
                    parseBlockchainInfo(blockchainInfo: blockchainInfo)
                    
                    reducer.makeCommand(command: BTC_CLI_COMMAND.getpeerinfo,
                                        param: "",
                                        completion: getResult)
                    
                default:
                    
                    break
                    
                }
                
            } else {
                
                errorBool = true
                errorDescription = reducer.errorDescription
                completion()
                
            }
            
        }
        
        reducer.makeCommand(command: BTC_CLI_COMMAND.getblockchaininfo,
                            param: "",
                            completion: getResult)
        
    }
    
    func loadSectionTwo(completion: @escaping () -> Void) {
        print("loadSectionTwo")
        
        let reducer = Reducer()
        
        func getResult() {
            
            if !reducer.errorBool {
                
                switch reducer.method {
                    
                case BTC_CLI_COMMAND.listtransactions.rawValue:
                    
                    let transactions = reducer.arrayToReturn
                    parseTransactions(transactions: transactions)
                    completion()
                    
                default:
                    
                    break
                    
                }
                
            } else {
                
                errorBool = true
                errorDescription = reducer.errorDescription
                completion()
                
            }
            
        }
        
        if !walletDisabled {
            
            reducer.makeCommand(command: BTC_CLI_COMMAND.listtransactions,
                                param: "\"*\", 50, 0, true",
                                completion: getResult)
            
        } else {
            
            arrayToReturn = []
            completion()
            
        }
        
    }
    
    // MARK: Section 0 parsers
    
    func parseBalance(balance: Double) {
        
        if balance == 0.0 {
            
            dictToReturn["hotBalance"] = "0.00000000"
            
        } else {
            
            dictToReturn["hotBalance"] = "\(round(100000000*balance)/100000000)"
            
        }
        
    }
    
    func parseUncomfirmedBalance(unconfirmedBalance: Double) {
        
        if unconfirmedBalance != 0.0 || unconfirmedBalance != 0 {
            
            dictToReturn["unconfirmedBalance"] = "unconfirmed \(unconfirmedBalance.avoidNotation)"
            
        } else {
            
            dictToReturn["unconfirmedBalance"] = "unconfirmed 0.00000000"
            
        }
        
    }
    
    func parseUtxos(utxos: NSArray) {
        
        var amount = 0.0
        
        for utxo in utxos {
            
            let utxoDict = utxo as! NSDictionary
            let spendable = utxoDict["spendable"] as! Bool
            
            if !spendable {
                
                let balance = utxoDict["amount"] as! Double
                amount += balance
                
            }
            
        }
        
        if amount == 0.0 {
            
            dictToReturn["coldBalance"] = "0.00000000"
            
        } else {
            
            dictToReturn["coldBalance"] = "\(round(100000000*amount)/100000000)"
            
        }
        
    }
    
    // MARK: Section 1 parsers
    
    func parseMiningInfo(miningInfo: NSDictionary) {
        
        let hashesPerSecond = miningInfo["networkhashps"] as! Double
        let exahashesPerSecond = hashesPerSecond / 1000000000000000000
        dictToReturn["networkhashps"] = exahashesPerSecond.withCommas()
        
    }
    
    func parseBlockchainInfo(blockchainInfo: NSDictionary) {
        
        if let currentblockheight = blockchainInfo["blocks"] as? Int {
            
            dictToReturn["blocks"] = currentblockheight
            
        }
        
        if let difficultyCheck = blockchainInfo["difficulty"] as? Double {
            
            dictToReturn["difficulty"] = "\(difficultyCheck.withCommas())"
            
        }
        
        if let sizeCheck = blockchainInfo["size_on_disk"] as? Int {
            
            dictToReturn["size"] = "\(sizeCheck/1000000000) gb"
            
        }
        
        if let progressCheck = blockchainInfo["verificationprogress"] as? Double {
            
            dictToReturn["progress"] = "\(Int(progressCheck*100))%"
            
        }
        
        if let chain = blockchainInfo["chain"] as? String {
            
            dictToReturn["chain"] = chain
            
        }
        
        if let pruned = blockchainInfo["pruned"] as? Bool {
            
            dictToReturn["pruned"] = pruned
            
        }
        
    }
    
    func parsePeerInfo(peerInfo: NSArray) {
        
        var incomingCount = 0
        var outgoingCount = 0
        
        for peer in peerInfo {
            
            let peerDict = peer as! NSDictionary
            
            let incoming = peerDict["inbound"] as! Bool
            
            if incoming {
                
                incomingCount += 1
                dictToReturn["incomingCount"] = incomingCount
                
            } else {
                
                outgoingCount += 1
                dictToReturn["outgoingCount"] = outgoingCount
                
            }
            
        }
        
    }
    
    func parseNetworkInfo(networkInfo: NSDictionary) {
        
        let subversion = (networkInfo["subversion"] as! String).replacingOccurrences(of: "/", with: "")
        dictToReturn["subversion"] = subversion.replacingOccurrences(of: "Satoshi:", with: "")
        
        let networks = networkInfo["networks"] as! NSArray
        
        for network in networks {
            
            let dict = network as! NSDictionary
            let name = dict["name"] as! String
            
            if name == "onion" {
                
                let reachable = dict["reachable"] as! Bool
                dictToReturn["reachable"] = reachable
                
            }
            
        }
        
    }
    
    func parseTransactions(transactions: NSArray) {
        
        var transactionArray = [Any]()
        
        for item in transactions {
            
            if let transaction = item as? NSDictionary {
                
                var label = String()
                var replaced_by_txid = String()
                var isCold = false
                
                let address = transaction["address"] as! String
                let amount = transaction["amount"] as! Double
                let amountString = amount.avoidNotation
                let confirmations = String(transaction["confirmations"] as! Int)
                
                if let replaced_by_txid_check = transaction["replaced_by_txid"] as? String {
                    
                    replaced_by_txid = replaced_by_txid_check
                    
                }
                
                if let labelCheck = transaction["label"] as? String {
                    
                    label = labelCheck
                    
                    if labelCheck == "" {
                        
                        label = ""
                        
                    }
                    
                    if labelCheck == "," {
                        
                        label = ""
                        
                    }
                    
                } else {
                    
                    label = ""
                    
                }
                
                let secondsSince = transaction["time"] as! Double
                let rbf = transaction["bip125-replaceable"] as! String
                let txID = transaction["txid"] as! String
                
                let date = Date(timeIntervalSince1970: secondsSince)
                dateFormatter.dateFormat = "MMM-dd-yyyy HH:mm"
                let dateString = dateFormatter.string(from: date)
                
                if let boolCheck = transaction["involvesWatchonly"] as? Bool {
                    
                    isCold = boolCheck
                    
                }
                
                transactionArray.append(["address": address,
                                         "amount": amountString,
                                         "confirmations": confirmations,
                                         "label": label,
                                         "date": dateString,
                                         "rbf": rbf,
                                         "txID": txID,
                                         "replacedBy": replaced_by_txid,
                                         "involvesWatchonly":isCold])
                
            }
            
        }
        
        arrayToReturn = transactionArray as! [[String:Any]]
        
    }
    
}
