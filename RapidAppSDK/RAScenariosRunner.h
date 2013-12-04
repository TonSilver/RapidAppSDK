//
//  RAScenariosRunner.h
//

#import <Foundation/Foundation.h>


#if defined (RA_SCENARIOS_RUNNER)

// Макрос для многоразового запуска указанного сценария
#define RA_SCENARIO_RUN_MANY(_ACTIVE, _COMMAND, _BLOCK) [RAScenariosRunner executeScenarioWithObject:self selector:_cmd command:_COMMAND block:_BLOCK skip:!(_ACTIVE)]

// Макрос для одноразового запуска указанного сценария
#define RA_SCENARIO_RUN_ONCE(_ACTIVE, _COMMAND, _BLOCK) { static dispatch_once_t sr_onceToken = 0; dispatch_once(&sr_onceToken, ^{ RA_SCENARIO_RUN_MANY(_ACTIVE, _COMMAND, _BLOCK); }); }

#else

#define RA_SCENARIO_RUN_MANY(...)
#define RA_SCENARIO_RUN_ONCE(...)

#endif // defined (RA_SCENARIOS_RUNNER)


// Тип блока содержащего сценарий
typedef void (^RAScenariosRunnerBlock)(void);


// Менеджер сценариев
@interface RAScenariosRunner : NSObject

+ (void)executeScenarioWithObject:(id)object selector:(SEL)selector command:(NSString *)command block:(RAScenariosRunnerBlock)block skip:(BOOL)skip;

@end
