//
//  RAHelperPrivate.h
//

#define RA_SHORTYFY(STR, CNT) ([STR length] > (CNT) ? [STR substringFromIndex:[STR length] - (CNT)] : STR)


#pragma mark - Макросы блоков для кеширования

// Начала для блока, кеширующего вывод
#define RA_CACHE_BEGIN return [[RAHelper shared] valueForKey:NSStringFromSelector(_cmd) withBlock:^id {
#define RA_CACHE_BEGIN_KEY(KEY) return [[RAHelper shared] valueForKey:KEY withBlock:^id {
#define RA_CACHE_BEGIN_FORMAT(FORMAT, ...) return [[RAHelper shared] valueForKey:[NSStringFromSelector(_cmd) stringByAppendingFormat:FORMAT, ##__VA_ARGS__] withBlock:^id {
// Окончание для блока, кэширующих данные
#define RA_CACHE_END }];
// Кешируем и выдает значение одной команды
#define RA_CACHE(COMMAND) return [[RAHelper shared] valueForKey:NSStringFromSelector(_cmd) withBlock:^id { return COMMAND; }]
// Кширует и выдает значение одной команды записанной под определенным ключем
#define RA_CACHE_KEY(COMMAND, FORMAT, ...) return [[RAHelper shared] valueForKey:[NSStringFromSelector(_cmd) stringByAppendingFormat:FORMAT, ##__VA_ARGS__] withBlock:^id { return COMMAND; }]
