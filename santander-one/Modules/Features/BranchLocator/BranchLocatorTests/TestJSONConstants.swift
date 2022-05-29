//
//  TestJSONConstants.swift
//  BranchLocatorTests
//
//  Created by Ivan Cabezon on 13/9/18.
//  Copyright © 2018 Globile. All rights reserved.
//

import Foundation

let kOnlyOnePOI = """
{"contactData":null,"subType":{"multi":{},"code":"SELECT"},"location":{"parking":null,"type":"Point","zipcode":"SW1E 5NT","address":"115-117, Victoria St, Victoria, London, SW1E 5NT","coordinates":[-0.137663175,51.496898770000001],"city":"Victoria","locationDetails":null,"geoCoords":{"longitude":-0.137663175,"latitude":51.496898770000001},"country":"UK","urlPhoto":null,"descriptionPhoto":null},"status":null,"spokenlanguages":["EN"],"code":"Santander_UK_UK_B41","specialType":null,"distanceInKm":0.87079086399013184,"comercialProducts":[{"default":"THIS BRANCH WILL BE CLOSED ON BANK HOLIDAYS","en":"THIS BRANCH WILL BE CLOSED ON BANK HOLIDAYS"},{"default":"IF YOU WISH TO APPLY FOR OR DISCUSS ANY OF OUR FINANCIAL SERVICES WE RECOMMEND YOU CALL TO BOOK AN APPOINTMENT","en":"IF YOU WISH TO APPLY FOR OR DISCUSS ANY OF OUR FINANCIAL SERVICES WE RECOMMEND YOU CALL TO BOOK AN APPOINTMENT"},{"default":"CURRENT ACCOUNTS","en":"CURRENT ACCOUNTS"},{"default":"SAVINGS - INCLUDING ISA'S","en":"SAVINGS - INCLUDING ISA'S"},{"default":"UNSECURED PERSONAL LOANS","en":"UNSECURED PERSONAL LOANS"},{"default":"BUSINESS BANKING","en":"BUSINESS BANKING"},{"default":"CREDIT CARDS","en":"CREDIT CARDS"},{"default":"MORTGAGES","en":"MORTGAGES"},{"default":"INVESTMENTS","en":"INVESTMENTS"},{"default":"FINANCIAL PLANNING SERVICES","en":"FINANCIAL PLANNING SERVICES"},{"default":"INSURANCE","en":"INSURANCE"},{"default":"COUNTER SERVICE","en":"COUNTER SERVICE"},{"default":"CASH WITHDRAWALS","en":"CASH WITHDRAWALS"},{"default":"MAKE DEPOSITS TO YOUR ACCOUNTS","en":"MAKE DEPOSITS TO YOUR ACCOUNTS"},{"default":"CHECK YOUR BALANCE","en":"CHECK YOUR BALANCE"}],"richTexts":null,"events":null,"action":null,"dialogAttribute": {"RETIRO_CON_CODIGO": true,"OPERATIVE": true,"COWORKING_SPACES": true,"PAY": true,"EMBOSADORA": true,"FEES": true,"OPEN_SATURDAY": true,"WITHDRAW": true,"OPEN_EVENINGS": true,"MEETING_ROOMS": true,"ACCESIBILITY": true,"CONTACTLESS": true,"DRIVE_THRU": true,"LOW_DENOMINATION_BILL": true,"AUDIO_GUIDANCE": true,"SAFE_BOX": true,"PARKING": true,"WIFI": true,"MULTICAJERO": true},"poicode":"B41","schedule":{"specialDay":[],"workingDay":{"MONDAY":["09:00-17:00"],"THURSDAY":["09:00-17:00"],"SUNDAY":[],"FRIDAY":["09:00-17:00"],"WEDNESDAY":["10:00-17:00"],"SATURDAY":[],"TUESDAY":["09:00-17:00"]}},"appointment":{"waitingTimeTeller":null,"branchAppointment":"https://www.santander.co.uk/uk/book-an-appointment","waitingTimeSpecialist":null},"name":"Victoria Main","urlDetailPage":null,"id":"5b991415049794b9ebd647b3","distanceInMiles":1.3932653823842109,"banner":null,"socialData":{"facebookLink":"https://www.facebook.com/santanderuk/","linkedinLink":"https://www.linkedin.com/company/santander-uk-corporate-&-commercial","twitterLink":"https://twitter.com/santanderuk","googleLink":null,"youtubeLink":"https://www.youtube.com/user/UKSantander","instagramLink":null},"objectType":{"multi":{"default":"BRANCH","en":"BRANCH"},"code":"BRANCH"},"poiStatus":"ACTIVE","entityCode":"Santander_UK","attrib":[{"multi":{"default":"YES","en":"YES"},"code":"WIFI"},{"multi":{"default":"EXTERNAL ATM","en":"EXTERNAL ATM"},"code":"ATM_INSIDE"},{"multi":{"default":"APPOINTMENT","en":"APPOINTMENT"},"code":"APPOINTMENT"}],"people":null,"description":null}
"""

let kContactData = """
{"phoneNumber": "123456789", "fax": "112233", "email": "manolo@pepe.com", "customerPhone": "987654321"}
"""