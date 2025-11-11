@isTest
public with sharing class BookingTriggerTest {
    @TestSetup
    static void makeData(){
        //Create contacts
        TestDataFactory.CreatContact(2);
        //Create cars
        TestDataFactory.CreateCar(2);
        
    }
    @isTest
    static void testAfterBookingClosed(){
        Car__c car=[select id,Total_Bookings_Value__c from Car__c limit 1];
        Contact contact=[select id from Contact limit 1];
        
        //create new booking
        Booking__c booking=new Booking__c(Car__c=car.Id,Customer__c=contact.Id,Start_date_time__c=Datetime.now().addDays(1),
        End_date_time__c=Datetime.now().addDays(3),Status__c=Constants.BOOKING_PENDING_STATUS,Payment_Status__c=Constants.BOOKING_PAYMENT_PENDING,Final_Booking_Price__c=200.00);
        insert booking;
        
        // creat a new payment -securty deposit: 20% of final booking price
        System_Thresholds__mdt threShold=System_Thresholds__mdt.getinstance(Constants.SECURITY_DEPOSIT_THRESHOLD);
        Decimal securityDepositPercentage=Decimal.valueOf(threShold.Value__c)/100;
        Decimal securtiyDeposit=securityDepositPercentage*booking.Final_Booking_Price__c;
        
        Payment_Transaction__c payment=new Payment_Transaction__c(Booking__c=booking.Id,Type__c =Constants.TYPE_SECURITY_DEPOSIT, Amount__c=securtiyDeposit,
        Status__c=Constants.SUCCESS,Transaction_Date__c=Datetime.now());
        
        // create Payment rental payment
        Payment_Transaction__c rentalPayment=new Payment_Transaction__c( Booking__c=booking.Id,Type__c =Constants.TYPE_PARTIAL_PAYMENT, Amount__c=booking.Final_Booking_Price__c,
        Status__c=Constants.SUCCESS,Transaction_Date__c=Datetime.now());
        
        list<Payment_Transaction__c> payments=new list<Payment_Transaction__c>{payment,rentalPayment};
        insert payments;
        
        //updating Booking status to closed
        Test.startTest();
        booking.Status__c=Constants.BOOKING_CLOSED_STATUS;
        update booking;
        Test.stopTest();
        // assert
        Car__c updatedCar=[select id,Total_Bookings_Value__c from Car__c where id=:car.Id];
        Decimal expectedTotalBookingsValue=booking.Final_Booking_Price__c;
        Decimal actualTotalBookingsValue=updatedCar.Total_Bookings_Value__c;
        
        System.Assert.areEqual(expectedTotalBookingsValue,actualTotalBookingsValue,'Total Bookings Value not updated correctly');
        
    }
    
}