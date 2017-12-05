//
//  Instrument.swift
//  MIDIPlayer
//
//  Created by Yulun Wu on 2017-12-05.
//  Copyright © 2017 Yulun Wu. All rights reserved.
//

import Foundation

/*
struct Instrument {
    var LSB:UInt8
    var MSB:UInt8
    var name:CFString
    var program:UInt8
    
}
 */

class Instrument {
    var LSB:Int!
    var MSB:Int!
    var name:String!
    var program:Int!
    
    init(LSB l:Int, MSB m:Int,name n:String,program p:Int) {
        LSB = l
        MSB = m
        name = n
        program = p
        
    }
}
/*
let InstrumentList = [Instrument(LSB:0,MSB:121,name:"Applause",program:126),
                      Instrument(LSB:0,MSB:120,name:"Orchestra Drums",program:48),
                      Instrument(LSB:0,MSB:121,name:"Applause",program:126),
                      Instrument(LSB:0,MSB:121,name:"Applause",program:126),
                      Instrument(LSB:0,MSB:121,name:"Applause",program:126),
]
 */
