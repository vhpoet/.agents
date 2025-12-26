# React Native Best Practices

Guidelines for building reliable, performant React Native + Expo apps.

## Core Principles

- Respect platform conventions. iOS should feel like iOS, Android like Android.
- Smoothness over flash. Prioritize responsiveness and scroll performance.
- Deterministic state. Avoid race conditions and ambiguous loading states.
- Minimal native churn. Use Expo and existing modules before introducing new ones.

## Architecture

- Prefer composable, feature-scoped components over global utilities.
- Keep side effects in hooks or data layers, not in presentational components.
- Make platform differences explicit with `Platform.select` or file suffixes.
- Avoid implicit global state.

## React Native Practices

- Keep components small; avoid heavy render trees.
- Use `FlatList`/`SectionList` for long lists; never map large arrays inline.
- Minimize re-renders with `memo`, `useCallback`, `useMemo` when proven.
- Avoid inline object/array literals for props in large lists.
- Prefer `Pressable` with consistent hit slop and feedback.
- Keep animations on native driver or reanimated.

## Expo

- Prefer Expo-managed APIs and config plugins over custom native code.
- Keep `app.json`/`app.config` minimal.

## iOS

- Respect safe areas and dynamic type sizes.
- Avoid blocking the main thread during transitions.
- Match iOS navigation patterns and gesture expectations.

## Data and State

- Model loading, empty, error, and offline states explicitly.
- Centralize cache invalidation and refetching rules.
- Use secure storage for secrets; async storage for small structured data.
- Debounce network calls from user input.

## Accessibility

- Touch targets at least 44x44 points.
- Provide accessibility labels for interactive controls.
- Support keyboard dismissal.
- Test in dark and light themes.

## Performance

- Avoid heavy work in render; use memoized selectors.
- Size images appropriately and use caching.
- Avoid synchronous storage reads on the UI path.
- Measure before optimizing (FPS, memory, startup time).

## What to Avoid

- Unbounded lists, heavy JS animations, frequent re-renders.
- Storing secrets in JS or persisting PII in plain storage.
- Over-customizing platform UI to the point it feels non-native.
