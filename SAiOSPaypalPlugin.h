//
//  SAiOSPaypalPlugin.h
//  Paypal Plugin for PhoneGap
//
//  Created by shazron on 10-10-08.
//  Copyright 2010 Shazron Abdullah. All rights reserved.

#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>
#import "PayPal.h"

typedef enum PaymentStatuses {
	PAYMENTSTATUS_SUCCESS,
	PAYMENTSTATUS_FAILED,
	PAYMENTSTATUS_CANCELED,
} PaymentStatus;


@interface PaypalPaymentInfo : NSObject
{
	NSString* paymentCurrency;
	NSString* paymentAmount;
	NSString* itemDesc;
	NSString* recipient;
	NSString* merchantName;
	NSString* nameItem;
    NSString* priceItem;
}

@property (nonatomic, copy) NSString* paymentCurrency;
@property (nonatomic, copy) NSString* paymentAmount;
@property (nonatomic, copy) NSString* itemDesc;
@property (nonatomic, copy) NSString* recipient;
@property (nonatomic, copy) NSString* merchantName;
@property (nonatomic, copy) NSString* nameItem;
@property (nonatomic, copy) NSString* priceItem;
@end


@interface SAiOSPaypalPlugin : CDVPlugin<PayPalPaymentDelegate> {
	UIButton* paypalButton;
	PaypalPaymentInfo* paymentInfo;
	PaymentStatus status;
    NSString* transaction;
}

@property (nonatomic, retain) UIButton* paypalButton;
@property (nonatomic, retain) PaypalPaymentInfo* paymentInfo;

- (void) prepare:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) pay:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) setPaymentInfo:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void) payWithPaypal;
@end
