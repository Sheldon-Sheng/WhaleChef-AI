# Whale Chef AI (肥鱼大厨) · codename DeepFry

**English | [简体中文](README.zh.md)**

A **smart-kitchen / weekly-meal-planning app** built with Flutter (iOS + Android). Fill in your body data, let the AI generate a week of recipes, auto-compute the shopping list from your fridge stock, deduct ingredients day by day, and track your weekly calorie intake.

## ✨ Features

- **AI-generated weekly meal plan**: each meal lists ingredients with quantities + seasonings. Customizable: meat/veggie ratio, add soup, cooking time, cuisine style, meal types (breakfast/lunch/dinner), prioritize favorites.
- **Health & allergy constraints**: once you fill in chronic conditions and food allergens, the prompt asks the AI to **strictly avoid contraindicated / allergenic ingredients**.
- **Shopping list = need − fridge**: derived from fridge inventory; only subtracted when names & units match.
- **Auto-deduct when cooking**: fridge first, then the shopping list, delete when it hits zero; running out of a seasoning prompts you and adds it to the shopping list.
- **Weekly calorie stats**: tapping "Finished Today's Cooking" records the day's recipes + calories; the **Stats** tab shows a **weekly bar chart** (X = week start~end dates, Y = cumulative calories).
- **Chinese / English**: follows the system language by default, switchable in Settings; the AI prompt switches too, and the AI replies in that language.
- **Must use your utensils**: the prompt requires every dish to be cookable with the utensils you listed.

## 🛠 Tech stack

- **Flutter 3.47 / Dart 3.13**, state management with **Provider**
- Local storage with **sqflite** (`deepfry.db`: profile, fridge, kitchen, recipes, shopping, cooking records)
- AI integration: **OpenAI-compatible chat/completions** (DeepSeek / OpenAI / Moonshot / Qwen / Zhipu GLM / SiliconFlow / custom)
- Charts via **fl_chart**, localization via **gen-l10n**, preferences via **shared_preferences**

## 🚀 Getting started

```bash
# 1. Fetch dependencies
flutter pub get

# 2. gen-l10n output is committed; you can regenerate it manually too
flutter gen-l10n

# 3. Run (simulator / real device)
flutter run
```

**Configure AI**: Settings → AI Config, enter `API Key`, `Model`, and `Base URL` (pick a preset or custom, e.g. `https://api.deepseek.com/v1`).

## 📦 Build

```bash
flutter build apk --release          # Android APK
flutter build ios --release          # iOS (needs Xcode + signing)
```

The artifact is ~85 MB (all ABIs + Flutter engine).

## 🗂 Project layout

```
lib/
  data/local_db.dart      # sqflite singleton, DB v7
  services/               # AI calls + Prompt building (zh/en)
  providers/              # Provider state
  pages/                  # Home / Fridge / Kitchen / Stats / Settings / Onboarding
  models/                 # data models
  utils/                  # quantity, meal type, default utensils & seasonings
  l10n/                   # gen-l10n ARB + AppLocalizations
assets/images/            # brand & UI illustrations
```

> Display name (iOS `CFBundleDisplayName` / Android `android:label`) is **肥鱼大厨**; package / bundle id: `com.feiyudachu.deepfry`.

## 📄 License

This project is licensed under the [MIT](LICENSE) License.

## ⚠️ Notes

- All data is stored **locally** (sqflite) and never uploaded; switching language clears recipes/fridge/seasonings (cooking history is kept).
- Generation depends on the AI service you configure; fees & availability are the provider's responsibility.
