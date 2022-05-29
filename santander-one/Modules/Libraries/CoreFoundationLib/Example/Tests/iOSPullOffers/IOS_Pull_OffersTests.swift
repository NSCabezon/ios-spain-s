//
//  IOS_Pull_OffersTests.swift
//  IOS-Pull-OffersTests
//
//  Created by Carlos Pérez Pérez on 4/6/18.
//  Copyright © 2018 Carlos Pérez Pérez. All rights reserved.
//

import XCTest
@testable import IOS_Pull_Offers

class IOS_Pull_OffersTests: XCTestCase {
    
    var xmlToParse: String? = nil
    
    override func setUp() {
        super.setUp()
        xmlToParse = getXML()
    }
    
    //VALID VARIABLES, CONSTANTS AND OPERATORS
    let validCharsForVariable = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_1234567890"
    let validCharsForConstant = "abcdefghijklmnñopqrstuvwxyzABCDEFGHIJKLMNÑOPQRSTUVWXYZ_1234567890\"'/- ,"
    let validCharsForOperators = "<>=*/+-!&|"
    
    //INPUT VALUES FOR TESTING
    let variablesArray = ["GCN", "PN", "AA", "NT", "ÑN", "PP", "A", "b", "c", "auxDate", "testArray", "testArray2", "BOTE"]
    let variablesValuesArray: [Any] = [4, true, false, 16, "\"a\"", "\"string\"", 4, 3, 2, "'07/07/2018'", [true, false], [4, "str2"], 4]
    
    //INPUT EXPRESSIONS FOR TESTING
    let arrayTests = ["[4,5] contains GCN+1",
                      "[4,5] contains (GCN+1)",
                      "[4,5] contains [4,5,6]",
                      "(GCN>=[3,4,5])",
                      "(GCN>=[3, 4, 5])",
                      "(GCN>=[true,false,false])",
                      "(GCN>=[\"ab\",\"cd\",\"ef\"])",
                      "([\"ab\",\"cd\",\"ef\"] contains GCN)",
                      "([4,5,6] contains GCN)",
                      "([4,\"cd\",\"ef\"] contains GCN)",
                      "[1,2,3] < 4",
                      "[1,2,3] > 2",
                      "[GCN,NT,A] > 2"]
    
    let dateTests = ["GCN<3 || auxDate > '25/12/2014' && 8 > 3/2",
                     "GCN<3 || auxDate > '25-12-2014' && 8 > 3/2",
                     "GCN<3 || auxDate > '25-12-2014' && 8>3/2",
                     "GCN<3 || auxDate > '25-12-2014' && PP==\"dos strings\"",
                     "GCN<3||auxDate>'25-12-2014'&&PP==\"dos strings\"",
                     "GCN<3||auxDate>'25-12-2014'&&PPcontains\"dos strings\"",
                     "GCN<3||auxDate>'25-12-2014'&&PP contains \"dos strings\"",
                     "GCN<3||auxDate>'25-12-2014'&&PP contains\"dos strings\""]
    
    let boteTests = ["BOTE == GCN",
                     "BOTE contains 4"]
    
    let notBalancedTests = ["((GCN>=1) && PN==true",
                            " contains 1 ) ",
                            "contains 1 ) "]
    
    let notValidOperatorsTests = ["(GCN-1) | PN==PN",
                     "(GCN>=1) & & PN==true",
                     "(\"esp\">=1) &&& PN==234",
                     "(\"esp\">=1) &&& PN= =23 4",
                     "(\"esp>=1) &&& PN==234",
                     "(GCM>=1) _ PN= %",
                     "(GCN ?= 1 ) ",
                     "(GCN === 1 ) ",
                     "(GCN no_contansw 1 ) ",
                     "(GCN contans 1 ) ",
                     "(GCN contansw 1 ) ",
                     "contañs 1 ) ",
                     "contans 1"]
    
    let indexOfTests = ["[4,5] indexOf 5",
                        "[4,5] indexOf(5)",
                        "[4,5] indexOf (7)",
                        "[4,5] indexOf [6]",
                        "[4,5] indexOf (5)",
                        "[4,5] indexOf GCN",
                        "[4,5] indexOf true",
                        "[4,true] indexOf true",
                        "[false,true] indexOf true",
                        "[false, true] indexOf true",
                        "[\"aux2\", \"aux\"] indexOf \"aux\"",
                        "[\"aux2 \",\"aux\"] indexOf \"aux\"",
                        "[4,5] indexOf GCN+1",
                        "[4,5] indexOf 1",
                        "[4,5] indexOf (GCN+1)",
                        "[4, 4, 5] indexOf 4"]
    
    private func getXML() -> String? {
        do {
            if let bundlePath = Bundle.allBundles.filter({$0.bundlePath.contains("IOS-Pull-OffersTests") && !$0.bundlePath.contains("Framework")}).first {
                if let path = bundlePath.path(forResource: "rulesV2", ofType: "xml") {
                    let data = try Data(contentsOf: URL(fileURLWithPath: path) , options: .mappedIfSafe)
                    guard let dataToString = String(data: data, encoding: String.Encoding.utf8) else { return nil }
                    return dataToString
                }
            }
            
            return nil
        } catch _ {
            return nil
        }
    }
    
    func testLexicalAnalysis() {
        var testingExpressions = ["(GCN>=1)",
                                  "(GCN>=1 ) && PN== true",
                                  "(ÑN>=1) PN==true",
                                  "(GCN contains 1 ) ",
                                  "(GCN no_contains 1 ) ",
                                  "(GCN >= 1 ) "]
        
        testingExpressions.append(contentsOf: notValidOperatorsTests)
        
        var failed = false
        
        for expression in testingExpressions {
            let engine = PullOfferLexicalEngine(rawExpression: expression, validCharsForVariable: validCharsForVariable, validCharsForConstant: validCharsForConstant, validCharsForOperators: validCharsForOperators)
            
            do {
                let tokens = try engine.performLexicalAnalysis()
                print("\n💚 INPUT: \(expression)\n💚 OUTPUT: \(engine.getSeparatedTokens(tokens: tokens).joined(separator: " "))\n")
                XCTAssert(true)
            } catch let exc {
                print("\n💔 INPUT: \(expression)\n💔 OUTPUT: \(exc.localizedDescription)\n")
                failed = true
            }
        }
        
        if failed {
            XCTAssert(false)
        }
    }
    
    func testSintacticalAnalysis() {
        var testingExpressions = ["(GCN>=1)",
                                  "(testArray contains \"str1\")",
                                  "(testArray2 contains \"str1\")",
                                  "(GCN>=1 ) && PN== true",
                                  "(GCN>=1) && (PN==true) && AA==false",
                                  "(GCN>=1) && (PN==true) && (AA==false || PP==\"string\")",
                                  "(GCN>=1) * (PN==true) + AA==false",
                                  "(GCN>=1) * ((PN==true) + AA==false)",
                                  "(GCN>=1) * (PN==true + AA==false)",
                                  "A+b*c",
                                  "(GCN>=1) * (PN==true + AA==false * NT*4)",
                                  "(ÑN>=1) PN==true",
                                  "(GCN contains 1 ) ",
                                  "(GCN contains 1 )",
                                  "(PP contains \"a\" ) ",
                                  "(GCN no_contains 1 ) ",
                                  "(GCN >= 1 ) "]
        
        //        testingExpressions.append(contentsOf: arrayTests)
        //        testingExpressions.append(contentsOf: dateTests)
        //        testingExpressions.append(contentsOf: notValidOperatorsTests)
        //        testingExpressions.append(contentsOf: notBalancedTests)
        //        testingExpressions.append(contentsOf: boteTests)
        testingExpressions.append(contentsOf: indexOfTests)
        
        var failed = false
        
        for expression in testingExpressions {
            do {
                let lexicalEngine = PullOfferLexicalEngine(rawExpression: expression, validCharsForVariable: validCharsForVariable, validCharsForConstant: validCharsForConstant, validCharsForOperators: validCharsForOperators)
                
                let tokens = try lexicalEngine.performLexicalAnalysis()
                
                let sintacticalEngine = PullOfferSintacticalEngine(originExpression: expression, tokens: tokens, validCharsForVariable: validCharsForVariable, validCharsForConstant: validCharsForConstant, validCharsForOperators: validCharsForOperators)
                
                guard let pullOfferExpression = try sintacticalEngine.performSintacticalAnalysis() else {
                    print("\n💔 INPUT: \(expression)\n💔 DID NOT RETURN EXPRESSION\n")
                    XCTAssert(false)
                    return
                }
                
                if let op = pullOfferExpression.getTopParent() as? PullOfferOperation {
                    op.printFullTree()
                } else {
                    failed = true
                }

            } catch let exc {
                print("\n💔 INPUT: \(expression)\n💔 OUTPUT: \(exc.localizedDescription)\n")
                failed = true
            }
        }
        
        if failed {
            XCTAssert(false)
        }
    }
    
    func testSemanticalAnalysis() {
        var testingExpressions = ["(GCN>=1)",
//                                  "(GCN!=1)",
//                                  "(testArray containsw \"str1\")",
//                                  "(testArray containsw)",
//                                  "(testArray2 contains \"str1\")",
//                                  "(GCN>=1 ) && PN== true",
//                                  "(GCN>=1) && (PN==true) && AA==false",
//                                  "(GCN>=1) && (PN==true) && (AA==false || PP==\"string\")",
//                                  "(GCN>=1) * (PN==true) + AA==false",
//                                  "(GCN>=1) * ((PN==true) + AA==false)",
//                                  "(GCN>=1) * (PN==true + AA==false)",
//                                  "A+b*c",
//                                  "(GCN>=1) * (PN==true + AA==false * NT*4)",
//                                  "(ÑN>=1) PN==true",
//                                  "(GCN contains 1 ) ",
//                                  "(GCN contains 1 )",
//                                  "(PP contains \"a\" ) ",
//                                  "(GCN no_contains 1 ) ",
                                  "(GCN >= 1 ) "]
        
        testingExpressions.append(contentsOf: arrayTests)
        testingExpressions.append(contentsOf: dateTests)
        testingExpressions.append(contentsOf: notValidOperatorsTests)
        testingExpressions.append(contentsOf: notBalancedTests)
        testingExpressions.append(contentsOf: boteTests)
        testingExpressions.append(contentsOf: indexOfTests)
        
        var failed = false
        
        for expression in testingExpressions {
            do {
                let lexicalEngine = PullOfferLexicalEngine(rawExpression: expression, validCharsForVariable: validCharsForVariable, validCharsForConstant: validCharsForConstant, validCharsForOperators: validCharsForOperators)

                let tokens = try lexicalEngine.performLexicalAnalysis()
                
                let sintacticalEngine = PullOfferSintacticalEngine(originExpression: expression, tokens: tokens, validCharsForVariable: validCharsForVariable, validCharsForConstant: validCharsForConstant, validCharsForOperators: validCharsForOperators)
                
                guard let pullOfferExpression = try sintacticalEngine.performSintacticalAnalysis() else {
                    print("\n💔 INPUT: \(expression)\n💔 DID NOT RETURN EXPRESSION\n")
                    XCTAssert(false)
                    return
                }
                
                let semanticalEngine = PullOfferSemanticalEngine(variablesNamesArray: variablesArray, variablesValuesArray: variablesValuesArray)
                
                let result: Result = try semanticalEngine.performSemanticalAnalysis(with: pullOfferExpression)
                (result.result == .valid)
                    ? print("\n💚 INPUT: \(expression)\n💚 OUTPUT: \(lexicalEngine.getSeparatedTokens(tokens: tokens).joined(separator: " "))\n\n\n")
                    : print("\n💔 INPUT: \(expression)\n💔 OUTPUT: \(result.resultError ?? "")\n\n\n")

                XCTAssert(result.result == .valid)
            } catch let exc {
                print("\n💔 INPUT: \(expression)\n💔 OUTPUT: \(exc.localizedDescription)\n")
                failed = true
            }
        }
        
        if failed {
            XCTAssert(false)
        }
    }
}
