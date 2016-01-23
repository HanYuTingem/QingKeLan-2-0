//
//  SINOAFNetWorking.h
//  AFNetWorking
//
//  Created by 许文波 on 15/10/14.
//  Copyright (c) 2015年 GDH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LYLAFNetWorking : NSObject


typedef void(^HttpSuccess)(id json);
typedef void(^HttpFailure)(NSError *error);
typedef void(^HttpNoNet)(void);


/**
 *  post 无参数请求
 *
 *  @param url     地址链接
 *  @param success 成功回调
 *  @param failure 失败回调
 */
+(void)postWithBaseURL:(NSString *)url success:(HttpSuccess)success failure:(HttpFailure)failure;
/**
 *  post 有参数请求
 *
 *  @param url     地址链接
 *  @param params  参数
 *  @param success 成功回调
 *  @param failure 失败回调
 */
+(void)postWithBaseURL:(NSString *)url  params:(NSDictionary *)params success:(HttpSuccess)success failure:(HttpFailure)failure;

/**
 *  get 无参数请求
 *
 *  @param url     地址链接
 *  @param success 成功回调
 *  @param failure 失败回调
 */
+(void)getWithBaseURL:(NSString *)url  success:(HttpSuccess)success failure:(HttpFailure)failure;
/**
 *  get 有参数的请求
 *
 *  @param url     地址链接
 *  @param params  参数
 *  @param success 成功回调
 *  @param failure 失败回调
 */
+(void)getWithBaseURL:(NSString *)url  params:(NSDictionary *)params success:(HttpSuccess)success failure:(HttpFailure)failure;


@end
