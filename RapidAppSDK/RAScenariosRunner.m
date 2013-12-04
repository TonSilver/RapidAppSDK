//
//  ScenariosRunner.m
//

#import "RAScenariosRunner.h"


// Очередь исполнения сценариев (последовательная)
static dispatch_queue_t ScenariosQueue = NULL;


// Менеджер сценариев
@implementation RAScenariosRunner

+ (void)executeScenarioWithObject:(id)object selector:(SEL)selector command:(NSString *)command block:(RAScenariosRunnerBlock)block skip:(BOOL)skip
{
	if (skip)
	{
		NSLog(@"[RAScenariosRunner] [%@ %@] %@ >>> Skipped!", NSStringFromClass([object class]), NSStringFromSelector(selector), command);
	}
	else if (object && selector && command && block)
	{
		if (!ScenariosQueue)
			ScenariosQueue = dispatch_queue_create("RAScenariosRunner", DISPATCH_QUEUE_SERIAL);
		
		NSString *logString = [NSString stringWithFormat:@"[RAScenariosRunner] [%@ %@] %@ >>> Running...", NSStringFromClass([object class]), NSStringFromSelector(selector), command];
		
		dispatch_async(ScenariosQueue, ^{
			double delayInSeconds = 0.1;
			dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
			dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
				NSLog(@"%@", logString);
				block();
			});
		});
	}
}

@end
