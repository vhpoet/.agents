# React Native Best Practices

Guidelines for building reliable, performant React Native + Expo apps.

## Core Principles

- Respect platform conventions. Make iOS feel like iOS and Android feel like Android.
- Smoothness over flash. Prioritize responsiveness and scroll performance.
- Deterministic state. Avoid race conditions and ambiguous loading states.
- Minimal native churn. Use Expo and existing native modules before introducing new ones.

## Architecture and Boundaries

- Prefer composable, feature-scoped components over global utilities.
- Keep side effects in hooks or data layers, not inside presentational components.
- Make platform differences explicit with `Platform.select` or file suffixes.
- Avoid implicit global state; document any global caches or singletons.

## React Native Practices

- Keep components small and predictable; avoid heavy render trees.
- Use `FlatList` or `SectionList` for long lists; never map large arrays inline.
- Minimize re-renders with `memo`, `useCallback`, and `useMemo` when proven.
- Avoid inline object/array literals for critical props in large lists.
- Prefer `Pressable` with consistent hit slop and feedback patterns.
- Keep animations on the native driver or reanimated where possible.

## Expo-Specific Practices

- Prefer Expo-managed APIs and config plugins over custom native code.
- Keep `app.json` / `app.config` consistent and minimal.

## iOS-Specific Practices

- Respect safe areas and dynamic type sizes; test larger text sizes.
- Avoid blocking the main thread; keep JS work small during transitions.
- Keep permission strings clear and user-focused.
- Match iOS navigation patterns and gesture expectations.
- Validate push, background, and notification entitlements explicitly.

## Data, State, and Offline

- Model loading, empty, error, and offline states explicitly.
- Keep cache invalidation and refetching rules centralized.
- Use async storage only for small, structured data; prefer secure storage for secrets.
- Debounce or batch network calls from user input.
- Prefer optimistic updates only when a rollback is straightforward.

## Accessibility and UX

- Ensure touch targets are at least 44x44 points.
- Provide accessibility labels for interactive controls.
- Support keyboard dismissal and avoid trapping focus.
- Use consistent spacing and typography across screens.
- Test in dark and light themes if supported.

## Performance and Reliability

- Avoid heavy work in render; move computation to memoized selectors.
- Keep images sized appropriately and use caching where available.
- Avoid synchronous storage reads on the UI path.
- Measure before optimizing; check FPS, memory, and startup time.
- Handle low-memory and app-resume flows explicitly.

## Change Checklist

- Did I reuse existing components or hooks where possible?
- Are error, empty, and offline states handled clearly?
- Does the UI feel native on both iOS and Android?
- Did I avoid introducing new native code unless necessary?

## When to Ask Questions

- The request requires new native modules or config plugins.
- The design conflicts with platform conventions or accessibility.
- The change affects auth, payments, or other sensitive flows.
- The request implies background behavior or persistent permissions.

## What to Avoid

- Unbounded lists, heavy animations on JS, or frequent re-renders.
- Storing secrets in JS or persisting PII in plain storage.
- Over-customizing platform UI to the point it feels non-native.
