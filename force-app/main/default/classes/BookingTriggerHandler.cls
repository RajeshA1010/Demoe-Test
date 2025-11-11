public with sharing class BookingTriggerHandler extends TriggerHandler {
    override public void afterUpdate(){
        BookingTriggerHandlerService.updateTotalBookingValueForCar((list<Booking__C>)Trigger.New,(Map<Id,Booking__C>)Trigger.oldMap);
    }
}