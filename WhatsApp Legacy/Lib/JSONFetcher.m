//
//  JSONFetcher.m
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 15/10/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import "JSONFetcher.h"
#import "JSONKit.h"
#import "JSONUtility.h"

@implementation JSONFetcher
@synthesize delegate;

+ (void)fetchJSON:(NSString *)urlString withMethod:(NSString *)method delegate:(id<JSONFetcherDelegate>)delegate {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            urlString, @"urlString",
                            method, @"method",
                            delegate, @"delegate",
                            nil];
    
    // Ejecutar en segundo plano para no bloquear la UI
    [self performSelectorInBackground:@selector(fetchJSONInBackground:) withObject:params];
}

+ (void)fetchJSON:(NSString *)urlString withMethod:(NSString *)method jsonBody:(NSDictionary *)jsonBody delegate:(id<JSONFetcherDelegate>)delegate {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            urlString, @"urlString",
                            method, @"method",
                            jsonBody, @"jsonBody", // Pasar el cuerpo JSON
                            delegate, @"delegate",
                            nil];
    
    // Ejecutar en segundo plano para no bloquear la UI
    [self performSelectorInBackground:@selector(fetchJSONInBackground:) withObject:params];
}

+ (void)fetchJSONInBackground:(NSDictionary *)params {
    NSString *urlString = [params objectForKey:@"urlString"];
    NSString *method = [params objectForKey:@"method"];
    NSDictionary *jsonBody = [params objectForKey:@"jsonBody"];
    id<JSONFetcherDelegate> delegate = [params objectForKey:@"delegate"];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    
    [request setHTTPMethod:method];
    [request setURL:url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    // Si hay un jsonBody, convertirlo a NSData y asignarlo al cuerpo de la solicitud
    if (jsonBody) {
        NSError *jsonError = nil;
        NSData *bodyData = [[JSONUtility JSONStringIfy:jsonBody] dataUsingEncoding:NSUTF8StringEncoding];;
        
        if (!jsonError) {
            [request setHTTPBody:bodyData];  // Establecer el cuerpo de la solicitud
        } else {
            NSLog(@"Error serializando JSON: %@", jsonError);
        }
    }
    
    NSError *error = nil;
    NSURLResponse *response = nil;
    
    // Realizar la solicitud sincrónica en segundo plano
    NSData *finalDataToDisplay = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSDictionary *json = nil;
    if (finalDataToDisplay && !error) {
        json = [finalDataToDisplay objectFromJSONData];
    }
    
    // Volver al hilo principal para devolver los datos al delegado
    NSDictionary *completionParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                      (json ? json : (NSDictionary *)[NSNull null]), @"json",
                                      (error ? error : (NSError *)[NSNull null]), @"error",
                                      delegate, @"delegate",
                                      nil];
    
    [self performSelectorOnMainThread:@selector(notifyDelegateOnMainThread:) withObject:completionParams waitUntilDone:NO];
}

+ (void)notifyDelegateOnMainThread:(NSDictionary *)params {
    NSDictionary *json = [params objectForKey:@"json"];
    NSError *error = [params objectForKey:@"error"];
    id<JSONFetcherDelegate> delegate = [params objectForKey:@"delegate"];
    
    if ([delegate respondsToSelector:@selector(fetcherDidFinishWithJSON:error:)]) {
        [delegate fetcherDidFinishWithJSON:([json isEqual:[NSNull null]] ? nil : json)
                                     error:([error isEqual:[NSNull null]] ? nil : error)];
    }
}

@end
