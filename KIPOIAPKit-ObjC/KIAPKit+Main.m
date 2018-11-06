//
//  KIAPKit+Main.m
//  KIPOIAPKit-ObjC
//
//  Created by Omid Golparvar on 8/26/18.
//  Copyright © 2018 Omid Golparvar. All rights reserved.
//


#import <KIAPKit+Main.h>
#import <KIAPKit+Delegate.h>

@interface KipoIAP ()

@property (class, assign, nonatomic) NSString* MerchantKey;

@property (class, nonatomic, weak) id <KipoIAPDelegate> delegate;

@end

@implementation KipoIAP

@dynamic MerchantKey;
@dynamic delegate;

+ (void)SetupMerchantKey:(NSString *)merchantKey {
	KipoIAP.MerchantKey = [merchantKey stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (void)SetupDelegate:(id <KipoIAPDelegate>)delegate {
	KipoIAP.delegate = delegate;
}

+ (void)Pay:(NSInteger)amount {
	NSString* bundleIdentifier;
	bundleIdentifier = [NSBundle mainBundle].bundleIdentifier;
	if (bundleIdentifier == nil) {
		[KipoIAP.delegate kipoCannotPerformWithError:@"KIPOIAP Error - Can Not Get Bundle Identifier."];
		return;
	}
	
	if ([[KipoIAP.MerchantKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
		[KipoIAP.delegate kipoCannotPerformWithError:@"KIPOIAP Error - Missing Merchant Key."];
		return;
	}
	
	NSString *merchantKey = KipoIAP.MerchantKey;
	NSString *regExPattern = @"^98[9][0-9]{9,9}$";
	NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
	NSUInteger regExMatches = [regEx numberOfMatchesInString:merchantKey options:0 range:NSMakeRange(0, [merchantKey length])];
	if (regExMatches == 0) {
		[KipoIAP.delegate kipoCannotPerformWithError:@"KIPOIAP Error - Invalid Merchant Key; It should be a valid persian phone number like 989*********."];
		return;
	}
	
	NSInteger invoiceNumber = [KipoIAP GetInvoiceNumber];
	NSMutableString *urlString = [NSMutableString alloc];
	[urlString appendString:@"http://iap.kipopay.com/?"];
	
	[urlString appendString:@"bi="];
	[urlString appendString:bundleIdentifier];
	[urlString appendString:@"&"];
	
	[urlString appendString:@"in="];
	[urlString appendString:[@(invoiceNumber) stringValue]];
	[urlString appendString:@"&"];
	
	[urlString appendString:@"mp="];
	[urlString appendString:merchantKey];
	[urlString appendString:@"&"];
	
	[urlString appendString:@"a="];
	[urlString appendString:[@(amount) stringValue]];
	[urlString appendString:@"&"];
	
	[urlString appendString:@"os=ios"];
	
	NSURL* url = [NSURL URLWithString:urlString];
	
	if (![[UIApplication sharedApplication] canOpenURL:url]) {
		[KipoIAP.delegate kipoCannotPerformWithError:@"KIPOIAP Error - Application Cannot Open HTTP URL."];
		return;
	}
	
	[[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {}];
}

+ (bool)Check:(NSURL *)url {
	// > {}://app/token/{token}
	// > {}://app/error/{message}
	
	NSString *host = url.host;
	if (([host length] == 0)) {
		return NO;
	}
	if (![host isEqualToString:@"app"])	{
		return NO;
	}
	if (url.pathComponents.count != 3) {
		return NO;
	}
	
	NSString *action = url.pathComponents[1];
	if ([action isEqualToString:@"token"]) {
		NSString *paymentToken = url.pathComponents[2];
		[KipoIAP.delegate kipoPaymentFinishedWithPaymentToken:paymentToken];
		return YES;
	}
	if ([action isEqualToString:@"error"]) {
		NSString *errorMessage = url.pathComponents[2];
		[KipoIAP.delegate kipoPaymentFinishedWithErrorMessage:errorMessage];
		return YES;
	}
	
	return NO;
}

+ (NSInteger)GetInvoiceNumber {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSNumber* invoiceNumber;
	invoiceNumber = [userDefaults objectForKey:@"KIPOIAP_InvoiceNumber"];
	if (invoiceNumber != nil) {
		NSInteger newInvoiceNumber = [invoiceNumber integerValue] + 1;
		[userDefaults setInteger:newInvoiceNumber forKey:@"KIPOIAP_InvoiceNumber"];
		[userDefaults synchronize];
		return [invoiceNumber integerValue];
	} else {
		[userDefaults setInteger:10000 forKey:@"KIPOIAP_InvoiceNumber"];
		[userDefaults synchronize];
		return 10000;
	}
}

@end

