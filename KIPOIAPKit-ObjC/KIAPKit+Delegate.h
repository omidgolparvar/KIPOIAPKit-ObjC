//
//  KIAPKit+Delegate.h
//  KIPOIAPKit-ObjC
//
//  Created by Omid Golparvar on 8/26/18.
//  Copyright © 2018 Omid Golparvar. All rights reserved.
//


@protocol KipoIAPDelegate <NSObject>

- (void)kipoCannotPerformWithError:(NSString *)error;

- (void)kipoPaymentFinishedWithPaymentToken:(NSString *)paymentToken;

- (void)kipoPaymentFinishedWithErrorMessage:(NSString *)errorMessage;

@end
