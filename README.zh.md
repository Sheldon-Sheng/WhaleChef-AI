# 肥鱼大厨（Whale Chef AI）· 工程名 DeepFry

**[English](README.md) | 简体中文**

一个 **Flutter 智能厨房 / 一周菜谱规划 App**（iOS + Android）。填写身体数据、让 AI 生成一周菜谱、自动算采购差量、按天扣减冰箱/采购、统计每周摄入卡路里。

## ✨ 功能特性

- **AI 生成一周菜谱**：每餐带食材数量 + 调味品；支持荤素配比、加汤、烹饪时间、菜系、餐次（早/午/晚）、收藏优先等自定义。
- **健康与过敏约束**：填写慢性病、过敏的食物后，Prompt 会要求 AI **严格避开忌口/过敏食材**。
- **按冰箱算差量**：菜谱需求 − 冰箱存量 = 采购清单；按名字/单位一致才可扣减。
- **完成烹饪自动扣减**：冰箱优先扣，不足从采购清单扣，归零即删；调味品用完会提示并加入采购。
- **每周卡路里统计**：点「已完成今天的烹饪」自动记录当日菜谱与卡路里，底部「统计」页展示**每周柱状图**（X = 周一起止日期，Y = 该周累计卡路里）。
- **中/英双语**：跟随系统语言默认，可在设置里手动切换；AI Prompt 也按语言切换，AI 以对应语言回复。
- **必须用已有厨具**：Prompt 要求菜谱能用你填写的厨具完成烹饪。

## 🛠 技术栈

- **Flutter 3.47 / Dart 3.13**，状态管理 **Provider**
- 本地数据 **sqflite**（`deepfry.db`，含用户资料/冰箱/厨房/菜谱/采购/烹饪记录）
- AI 集成：**OpenAI 兼容 chat/completions**（DeepSeek / OpenAI / Moonshot / 通义千问 / 智谱 GLM / SiliconFlow / 自定义）
- 图表 **fl_chart**，本地化 **gen-l10n**，偏好持久化 **shared_preferences**

## 🚀 快速开始

```bash
# 1. 拉取依赖
flutter pub get

# 2. 首次会生成 l10n 产物（已提交，也可手动生成）
flutter gen-l10n

# 3. 运行（连模拟器/真机）
flutter run
```

**配置 AI**：设置 → AI 配置，填入 `API Key`、`模型名称`、`Base URL`（选择预设或自定义，如 `https://api.deepseek.com/v1`）。

## 📦 打包

```bash
flutter build apk --release          # Android APK
flutter build ios --release          # iOS（需 Xcode + 签名）
```

产物体积约 85MB（含全 ABI 与 Flutter 引擎）。

## 🗂 目录结构

```
lib/
  data/local_db.dart      # sqflite 单例，DB v7
  services/               # AI 调用 + Prompt 构建（中/英）
  providers/              # Provider 状态
  pages/                  # 首页/冰箱/厨房/统计/设置/引导
  models/                 # 数据模型
  utils/                  # 数量/餐次/默认厨具与调味料
  l10n/                   # gen-l10n ARB + AppLocalizations
assets/images/            # 品牌与界面插图
```

> App 名（iOS `CFBundleDisplayName` / Android `android:label`）为 **肥鱼大厨**；包名 / bundle id：`com.feiyudachu.deepfry`。

## 📄 许可证

本项目基于 [MIT](LICENSE) 协议开源。

## ⚠️ 说明

- 数据全部**本地存储**（sqflite），不会上传；切换语言会清空菜谱/冰箱/调味料（历史烹饪记录保留）。
- 生成依赖你配置的 AI 服务，接口费用与可用性由对应服务商负责。
