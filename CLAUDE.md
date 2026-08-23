# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概览(版本 1.0)

**肥鱼大厨**(工程名/内部名 DeepFry)是一个 Flutter 智能厨房 / 周菜谱规划 App(iOS + Android),基于 **Flutter 3.47 / Dart 3.13**,状态管理用 **Provider**。

核心用户流程:填写身体数据(或跳过 on-boarding)→ AI 生成一周菜谱(每餐食材带数量 + 调味品名单)→ 自动生成采购清单(**按冰箱存量算差量**)→ 在采购清单确认购买入冰箱(累加)→ 每天点「已完成今天的烹饪」从冰箱优先扣减、不足从采购清单扣、归零删除。

## 常用命令

```bash
flutter pub get                       # 装依赖
flutter run                           # 运行(连模拟器/真机)
flutter analyze                       # 静态分析,必须 0 告警
flutter test                          # 全部测试
flutter test test/local_db_test.dart  # 单个测试文件
flutter test test/foo.dart --plain-name "用例名"  # 单个用例
dart format lib/ test/                # 格式化
```

## 架构要点(大图)

### 1. 统一数量模型(最重要,别破坏)
所有数量统一为 `amount`(REAL,**0 = 适量**)+ `unit`(TEXT),全 App 一致:
- 冰箱 `ingredients.amount/unit`、采购 `shopping_items.amount/unit`、菜谱 `ingredient_list = [{"name","amount","unit"}]`
- **不存在**「文本数量」列或字段;运行时**零文本解析**——唯一例外是 AI 摄入边界(`_savePlan` 用 `parseQuantity`)。
- 展示统一走 `lib/utils/quantity.dart` 的 `formatQuantity(amount, unit)` 或各模型 `displayQuantity` getter(amount=0 →「适量」)。
- `ingredients` 表**没有** `quantity` 列——任何写入都不得含 quantity(否则 SQLite 报 no such column)。
- 数量解析/聚合:`parseQuantity`(摄入)、`formatQuantity`(展示)、`aggregateRecipeIngredients`(聚合周需求)、`computeShoppingShortfall`(差量,单位一致才减)、`computeDishBreakdown`(荤素配比:素 = 总 − 荤)。

### 2. 数据层(LocalDB)
`lib/data/local_db.dart` 是 sqflite 单例,DB version **5**,`init()` 支持可选 path(测试用)。表:user_profile / ingredients / kitchen_items / weekly_plans / recipes / shopping_items / ai_config。

迁移历史(只进不退):
- v3:recipes 加 `seasoning_list`(加列)
- v4:shopping_items 改 amount+unit,**直接清空** 冰箱/采购/菜谱/计划(刻意为之,统一数量模型)
- v5:ai_config 加 `base_url`(加列)

### 3. 导航与页面
入口 `main.dart` → `SplashScreen`(2s Timer + 淡出)→ Onboarding(未完成时)或 `MainShell`。`MainShell` 底部 4 标签:菜谱(HomePage)/ 冰箱(FridgePage)/ 厨房(KitchenPage)/ 设置(SettingsPage)。采购清单 `ShoppingPage` 是**子页面**(从首页采购区进入),不是标签页。

### 4. AI 集成(OpenAI 兼容 chat/completions)
`lib/services/deepseek_api.dart`:`baseUrl` + `apiKey` + `model` 全部从 `ai_config` 读取,**base_url 无默认值**——为空时 `generateMealPlan` 直接抛「请先在设置中配置 API 地址 (Base URL)」,不要加回默认 DeepSeek 回退。`normalizeBaseUrl` 去尾斜杠。请求 `{baseUrl}/chat/completions`。
- 设置页 AI 配置:API Key / 模型名称 / **Base URL 预设下拉框**(DeepSeek、OpenAI、Moonshot、通义千问、智谱 GLM、SiliconFlow + 自定义 URL);保存按钮用 `kSeedBlue`。
- 生成失败态:白底对话框 + error.png + 重试按钮(进度条在生成时位于屏幕底部)。

### 5. 菜谱生成流
`MealPlannerService.generateWeekPlan` → `PromptBuilder.buildPrompt`(每餐 `ingredients=[{"name","amount","unit"}]` + `seasonings=["盐"]`,无 shopping_list)→ AI → `_savePlan`:
- 摄入时把 AI 文本数量解析为结构化 amount/unit。
- **采购清单 = 周需求 − 冰箱存量**(差量):冰箱够→不买;不够→买差量;单位不一致→买全量;需求适量→原样。
- 荤素配比由 `computeDishBreakdown` 推导,对话框里荤菜是下拉、素菜只读显示。

### 6. 完成烹饪扣减
`MealPlanProvider.completeTodayCooking(dayIndex)` → `aggregateRecipeIngredients`(今日各餐同名相加)→ `LocalDB.consumeForCooking(planId, needs)`:
- 冰箱优先扣 → 不足从**当前计划**采购扣 → 归零删除条目;适量(amount=0)→ 用完当前可用整条。
- **仅食材(ingredients)参与扣减,调味品不参与**。
- 采购清单的名字/单位与菜谱食材**必须一致**(这是扣减能命中冰箱/采购的前提——采购清单由菜谱差量生成保证这一点)。

### 7. 采购确认
`ShoppingPage._confirmPurchase` → `LocalDB.batchMarkPurchased`(单事务):冰箱已有该食材则**累加**存量(`addToIngredientStock` 语义),无则新增,删除采购项。

### 8. 主题与图片资源
- 钢蓝主题 seed `kSeedBlue = Color(0xFF4D72AC)`(`lib/theme.dart`,与 App 图标蓝系渐变一致)。硬编码图标颜色统一用 `kSeedBlue` / `formatQuantity`。
- `assets/images/`:icon(App 图标源)、welcome(启动屏)、loading(生成中全屏背景)、shopping(采购页底部)、error(失败态)、ponding(设置页底部)、recipe。**ai_failed_1080x1920.png 已废弃无引用**(可安全删除,勿重新引用)。

## 关键注意(历史踩坑)

- **别改这些内部标识**:`DeepFryApp` Dart 类名、`deepfry.db` 数据库文件名(改名会新建库、丢数据)、Dart 包名 `deepfry`(改动破坏 `package:deepfry/...` import)。用户可见的 App 名是「肥鱼大厨」(ios Info.plist `CFBundleDisplayName` + android `android:label`)。
- **Splash 用 `Timer(2s)`**,必须在 `dispose()` 取消(`_navigateTimer`)——`widget_test` 依赖它(否则 pending timer 报错)。
- **测试用 sqflite_common_ffi 桌面内存/文件库**;每个测试文件用**独立 DB 文件**(如 `deepfry_consume_test.db`)避免并行争用,必要时 `setUp` 清表隔离。
- 数据库/模型字段改动必须**同步所有构造/访问点**(历史上有多次「只改了 schema 忘了改写入」引发的 DatabaseException)。
- 每任务收尾必须 `flutter analyze` 0 告警 + `flutter test` 全绿。
- 设置页 AI 配置里带圈 i 图标是「获取 API Key 教程」占位(功能待补充)。
