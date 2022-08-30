import UIKit
import Foundation

enum VehicleType {
    case car, moto, bus, miniBus
    
    var tax: Int {
        switch self {
        case .bus:
            return 30
        case .car:
            return 20
        case .moto:
            return 15
        case .miniBus:
            return 25
        }
    }
}

protocol Parkable {
    var plate: String { get }
    var type: VehicleType { get }
    var checkInTime: Date { get }
    var discountCard: String? { get }
}

struct Vehicle: Parkable, Hashable {
    
    static func == (lhs: Vehicle, rhs: Vehicle) -> Bool {
        return lhs.plate == rhs.plate
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(plate)
    }
    
    var plate: String
    let type: VehicleType
    var checkInTime: Date
    let discountCard: String?
    lazy var parkedTime = { Calendar.current.dateComponents([.minute], from:
                                                                checkInTime, to: Date()).minute ?? 0}()
    
    init(plate: String, type: VehicleType, checkInTime: Date, discountCard: String?) {
        self.plate = plate
        self.type = type
        self.checkInTime = checkInTime
        self.discountCard = discountCard
    }
}

struct Parking {
    var vehicles: Set<Vehicle> = []
    let maxVehicles = 20
    var vehiclesOut = (totalVehicles: 0, totalAmount: 0)
    
    mutating func checkInVehicle(_ vehicle: Vehicle, onFinish:
                                 (Bool, String) -> Void) {
        
        guard vehicles.count < maxVehicles else {
            onFinish(false, "Sorry, the check-in failed")
            return
        }
                
        if vehicles.insert(vehicle).inserted {
            vehicles.insert(vehicle)
            onFinish(true, "Welcome to AlkeParking")
        } else {
            onFinish(false, "Sorry, the check-in failed")
        }
    }
    
    mutating func checkOutVehicle(plate: String, onSuccess: (String) -> Void, onError: (String) -> Void) {
        if vehicles.contains(where: { $0.plate == plate }) {
            guard var vehicleToRemove = vehicles.first(where: { $0.plate == plate }) else { return }
            
            let fee = calculateFee(type: vehicleToRemove.type, parkedTime: vehicleToRemove.parkedTime, hasDiscountCard: (vehicleToRemove.discountCard != nil))
            
            vehiclesOut.totalVehicles += 1
            
            vehicles.remove(vehicleToRemove)
            
            onSuccess("Your fee is $\(fee). Come back soon")
        } else {
            onError("Sorry, the check-out failed")
        }
    }
    
    mutating func calculateFee(type: VehicleType, parkedTime: Int, hasDiscountCard: Bool) -> Int {
        var totalFee: Int = 0
        
        if parkedTime > 120 {
            let leftTime = parkedTime - 120
            let blocksOfTime = leftTime / 15
            let partialFee = blocksOfTime * 5
            
            totalFee = type.tax + partialFee
            
        } else {
            totalFee = type.tax
        }
        
        if hasDiscountCard {
            totalFee = Int(Double(totalFee) - (Double(totalFee) * 0.15))
        }
        
        vehiclesOut.totalAmount += totalFee
        return totalFee
    }
    
    func showTotalEarnings() {
        print("\(vehiclesOut.totalVehicles) vehicles have checked out and have earnings of $\(vehiclesOut.totalAmount)")
    }
    
    func listVehicles() {
        for vehicle in vehicles {
            print(vehicle.plate)
        }
    }
    
}
extension Date {
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: self)!
    }

    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: self)!
    }
}

var alkeParking = Parking()
let vehicle1 = Vehicle(plate: "AA111AA", type:
                        VehicleType.car, checkInTime: Date(), discountCard:
                        "DISCOUNT_CARD_001")
let vehicle2 = Vehicle(plate: "B222BBB", type:
                        VehicleType.moto, checkInTime: Date().dayBefore, discountCard: nil)
let vehicle3 = Vehicle(plate: "CC333CC", type:
                        VehicleType.miniBus, checkInTime: Date(), discountCard:
                        nil)
let vehicle4 = Vehicle(plate: "DD444DD", type:
                        VehicleType.bus, checkInTime: Date(), discountCard:
                        "DISCOUNT_CARD_002")
let vehicle5 = Vehicle(plate: "AA111BB", type:
                        VehicleType.car, checkInTime: Date(), discountCard:
                        "DISCOUNT_CARD_003")
let vehicle6 = Vehicle(plate: "B222CCC", type:
                        VehicleType.moto, checkInTime: Date().dayBefore, discountCard:
                        "DISCOUNT_CARD_004")

let vehicles = [vehicle1, vehicle2, vehicle3, vehicle4, vehicle5, vehicle6]

for vehicle in vehicles {
    alkeParking.checkInVehicle(vehicle) { canPark, message in
        print(message)
    }
}

alkeParking.checkOutVehicle(plate: "B222BBB") { message in
    print(message)
} onError: { message in
   print(message)
}

alkeParking.checkOutVehicle(plate: "DD444DD") { message in
    print(message)
} onError: { message in
   print(message)
}

//Teste de check out com menos de 2h
alkeParking.checkOutVehicle(plate: "AA111BB") { message in
    print(message)
} onError: { message in
   print(message)
}

//Teste de placa que não existe
alkeParking.checkOutVehicle(plate: "HEUHEU") { message in
    print(message)
} onError: { message in
    print(message)
}

alkeParking.showTotalEarnings()
alkeParking.listVehicles()
