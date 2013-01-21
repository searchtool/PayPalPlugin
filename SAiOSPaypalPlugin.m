//
//  SAiOSPaypalPlugin.m
//  Paypal Plugin for PhoneGap
//
//  Created by shazron on 10-10-08.
//  Copyright 2010 Shazron Abdullah. All rights reserved.

#import "SAiOSPaypalPlugin.h"
#import "PayPal.h"
#import "PayPalPayment.h"
#import "PayPalAddress.h" // use for dynamic amount calculation
#import "PayPalAmounts.h" // use for dynamic amount calculation
#import "PayPalInvoiceItem.h"

@implementation PaypalPaymentInfo

@synthesize paymentCurrency, paymentAmount, itemDesc, recipient, merchantName,priceItem,nameItem;

- (void) dealloc
{
	self.paymentCurrency = nil;
	self.paymentAmount = nil;
	self.itemDesc = nil;
	self.recipient = nil;
	self.merchantName = nil;
	self.priceItem = nil;
    self.nameItem = nil;

	[super dealloc];
}

@end

@implementation SAiOSPaypalPlugin

@synthesize paypalButton, paymentInfo;

#define NO_APP_ID	@"APP-80W284485P519543T"

/* Get one from Paypal at developer.paypal.com */
#define PAYPAL_APP_ID	NO_APP_ID

/* valid values are ENV_SANDBOX, ENV_NONE (offline) and ENV_LIVE */
#define PAYPAL_APP_ENV	ENV_NONE


-(CDVPlugin*) initWithWebView:(UIWebView*)theWebView
{
    self = (SAiOSPaypalPlugin*)[super initWithWebView:(UIWebView*)theWebView];
    if (self) {
		if ([PAYPAL_APP_ID isEqualToString:NO_APP_ID]) {
			NSLog(@"WARNING: You are using a dummy PayPal App ID.");
		}
		if (PAYPAL_APP_ENV == ENV_NONE) {
			NSLog(@"WARNING: You are using the offline PayPal ENV_NONE environment.");
		}
		
		[PayPal initializeWithAppID:PAYPAL_APP_ID forEnvironment:PAYPAL_APP_ENV];

		if ([PayPal initializationStatus] == STATUS_NOT_STARTED) {
            NSLog(@"STATUS_NOT_STARTED");
        }
        if ([PayPal initializationStatus] == STATUS_COMPLETED_ERROR) {
            NSLog(@"STATUS_COMPLETED_ERROR");
        }
        if ([PayPal initializationStatus] == STATUS_INPROGRESS) {
            NSLog(@"STATUS_INPROGRESS");
        }
        if ([PayPal initializationStatus] == STATUS_COMPLETED_SUCCESS) {
            NSLog(@"STATUS_COMPLETED_SUCCESS");
        }

    }
    return self;
}

- (void) prepare:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	if (self.paypalButton != nil) {
		[self.paypalButton removeFromSuperview];
		self.paypalButton = nil;
	}
	
	int argc = [arguments count];
	if (argc < 1) {
		NSLog(@"SAiOSPaypalPlugin.prepare - missing first argument for paymentType (integer).");
		return;
	}
	
	NSString* strValue = [arguments objectAtIndex:0];
	NSInteger paymentType = [strValue intValue];

	self.paypalButton = [[PayPal getPayPalInst] getPayButtonWithTarget:self andAction:@selector(payWithPaypal) andButtonType: BUTTON_294x43];
    [self.paypalButton addTarget:self action:@selector(payWithPaypal) forControlEvents:UIControlEventTouchUpInside];

	[super.webView addSubview:self.paypalButton];
	self.paypalButton.hidden = YES;

	NSLog(@"SAiOSPaypalPlugin.prepare - set paymentType: %d", paymentType);
}


- (void) pay:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	if (self.paypalButton != nil) {
	    if ([PayPal initializationStatus] == STATUS_NOT_STARTED) {
        	NSLog(@"STATUS_NOT_STARTED");
        }
        if ([PayPal initializationStatus] == STATUS_COMPLETED_ERROR) {
        	NSLog(@"STATUS_COMPLETED_ERROR");
        }
        if ([PayPal initializationStatus] == STATUS_INPROGRESS) {
        	NSLog(@"STATUS_INPROGRESS");
        }
        if ([PayPal initializationStatus] == STATUS_COMPLETED_SUCCESS) {
        	NSLog(@"STATUS_COMPLETED_SUCCESS");
        }

		[self.paypalButton sendActionsForControlEvents:UIControlEventTouchUpInside];
	} else {
		NSLog(@"SAiOSPaypalPlugin.pay - payment not initialized. Call SAiOSPaypalPlugin.prepare(paymentType)");
	}
}

- (void) setPaymentInfo:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	self.paymentInfo = nil;
	self.paymentInfo = [[PaypalPaymentInfo alloc] init];
	
	[self.paymentInfo setValuesForKeysWithDictionary:options];
}

- (void) payWithPaypal
{
	if (self.paymentInfo)
	{
		PayPalPayment *payment =[[PayPalPayment alloc] init];

		payment.paymentCurrency = self.paymentInfo.paymentCurrency;
		payment.subTotal	= [NSDecimalNumber decimalNumberWithString:self.paymentInfo.paymentAmount];
		payment.description		= self.paymentInfo.itemDesc;
        payment.recipient		= self.paymentInfo.recipient;
		payment.merchantName	= self.paymentInfo.merchantName;

        PayPalInvoiceItem *item = [[[PayPalInvoiceItem alloc] init] autorelease];

        item.name = self.paymentInfo.nameItem;
        item.itemPrice=[NSDecimalNumber decimalNumberWithString:self.paymentInfo.priceItem];

		[[PayPal getPayPalInst] checkoutWithPayment:payment];
		[payment release];

		NSLog(@"SAiOSPaypalPlugin.payWithPaypal - payment sent. currency:%@ amount:%@ desc:%@ recipient:%@ merchantName:%@",
			  self.paymentInfo.paymentCurrency, self.paymentInfo.paymentAmount, self.paymentInfo.itemDesc,
			  self.paymentInfo.recipient, self.paymentInfo.merchantName);
	}
	else
	{
		NSLog(@"SAiOSPaypalPlugin.payWithPaypal - no payment info. Set it using SAiOSPaypalPlugin.setPaymentInfo");
	}
}

#pragma mark -
#pragma mark Paypal delegates

- (void)paymentSuccessWithKey:(NSString *)payKey andStatus:(PayPalPaymentStatus)paymentStatus
{
	NSLog(@"paymentSuccessWithKey");
	NSString *severity = [[PayPal getPayPalInst].responseMessage objectForKey:@"severity"];
	NSLog(@"severity: %@", severity);
	NSString *category = [[PayPal getPayPalInst].responseMessage objectForKey:@"category"];
	NSLog(@"category: %@", category);
	NSString *errorId = [[PayPal getPayPalInst].responseMessage objectForKey:@"errorId"];
	NSLog(@"errorId: %@", errorId);
	NSString *message = [[PayPal getPayPalInst].responseMessage objectForKey:@"message"];
	NSLog(@"message: %@", message);
	NSLog(@"paykey:%@", payKey);

	status = PAYMENTSTATUS_SUCCESS;

	NSString* transactionId = [[NSString alloc] initWithString:[payKey substringFromIndex:3]];
    	transaction = transactionId;
}
- (void) paymentCanceled 
{
	NSLog(@"paymentCanceled");
	status = PAYMENTSTATUS_CANCELED;
}

-(void)paymentFailedWithCorrelationID:(NSString *)correlationID
{
	NSLog(@"paymentFailed");
	status = PAYMENTSTATUS_FAILED;
}

- (void)paymentLibraryExit
{
NSLog(@"LibraryExit");
NSLog(@"transactionId:%@ ",transaction);
	NSString* jsString;
	switch (status) {
		case PAYMENTSTATUS_SUCCESS:

			jsString = [NSString stringWithFormat:@"(function() {"
			"var e = document.createEvent('Events');"
			"e.initEvent('PaypalPaymentEvent.Success');"
			"e.transactionID = '%@';"
			"document.dispatchEvent(e);"
			"})();",transaction];
			[super writeJavascript:[NSString stringWithFormat:jsString]];

			NSLog(@"SAiOSPaypalPlugin.paymentSuccess");

			break;
		case PAYMENTSTATUS_FAILED:
		  jsString = @"(function() {"
			"var e = document.createEvent('Events');"
			"e.initEvent('PaypalPaymentEvent.Failed');"
			"document.dispatchEvent(e);"
			"})();";

			[super writeJavascript:[NSString stringWithFormat:jsString]];

			NSLog(@"SAiOSPaypalPlugin.paymentFailed");
				break;
		case PAYMENTSTATUS_CANCELED:
			jsString = @"(function() {"
			"var e = document.createEvent('Events');"
			"e.initEvent('PaypalPaymentEvent.Canceled');"
			"document.dispatchEvent(e);"
			"})();";

			[super writeJavascript:jsString];
			break;
	}
}
@end
