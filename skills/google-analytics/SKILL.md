---
name: google-analytics
description: Query the user's Google Analytics (GA4) traffic — pageviews, users, sessions, top pages, sources — for any of their sites. Use for "check analytics", "check traffic", "how is <site> doing".
---

# Google Analytics (GA4)

The user's GA4 data for **all** their properties is queryable from the terminal. Run the tool directly — no setup needed in normal use.

## Tool

`~/.config/ga/ga` (wrapper around a venv + `ga.py`).

```sh
# List every property the credential can see (account, name, property_id)
~/.config/ga/ga properties

# Run a report (JSON out)
~/.config/ga/ga report \
  --metrics screenPageViews,totalUsers \
  --dimensions pagePath \
  --start 28daysAgo --end today \
  --order=-screenPageViews \
  --limit 20 \
  [--property <PROPERTY_ID>]
```

- `--property` is optional; it defaults to **Read This Twice** (`~/.config/ga/property`). Always pass `--property` explicitly when the user asks about a different site.
- `--start` / `--end` accept `YYYY-MM-DD`, `NdaysAgo`, `yesterday`, or `today`.
- `--order` sorts by a metric or dimension name; prefix with `-` for descending.

## Property IDs

| Site | property_id |
|---|---|

(If unsure or it may have changed, run `~/.config/ga/ga properties` to re-list.)

## Common GA4 fields

- **Metrics:** `screenPageViews`, `totalUsers`, `activeUsers`, `newUsers`, `sessions`, `engagedSessions`, `engagementRate`, `bounceRate`, `averageSessionDuration`, `conversions`, `eventCount`.
- **Dimensions:** `pagePath`, `pageTitle`, `landingPage`, `sessionSource`, `sessionMedium`, `sessionDefaultChannelGroup`, `country`, `city`, `deviceCategory`, `browser`, `date`, `yearMonth`.

Common asks → recipe:
- "top pages last week" → `--metrics screenPageViews,totalUsers --dimensions pagePath --start 7daysAgo --end today --order=-screenPageViews`
- "traffic trend" → `--metrics totalUsers,sessions --dimensions date --start 30daysAgo --end today --order=date`
- "where's traffic coming from" → `--metrics sessions,totalUsers --dimensions sessionDefaultChannelGroup --start 28daysAgo --end today --order=-sessions`

Parse the JSON and answer in plain language (tables/highlights), not raw JSON, unless the user wants the data.

## Auth (only relevant if it fails)

Auth is gcloud **Application Default Credentials** as the user (you@example.com, scopes cloud-platform + analytics.readonly) via a custom Desktop OAuth client in GCP project `your-gcp-project`. There is **no service account** — GA4 on this account hard-blocks adding service-account and Google-Group principals, so we authenticate as the user, who owns every property.

If a query returns `ACCESS_TOKEN_SCOPE_INSUFFICIENT` / `PermissionDenied` / "Reauthentication required", the ADC token expired (this happens every 7 days if the OAuth consent screen is still in "Testing"). Re-auth (interactive — the user must complete the browser flow; have them run it via the `! ` prompt prefix):

```sh
gcloud auth application-default login \
  --client-id-file=~/.config/ga/oauth-client.json \
  --scopes=https://www.googleapis.com/auth/cloud-platform,https://www.googleapis.com/auth/analytics.readonly,https://www.googleapis.com/auth/webmasters.readonly
gcloud auth application-default set-quota-project your-gcp-project
```

Keep **all three** scopes in that command — the same login also powers Search Console (`webmasters.readonly`); dropping a scope breaks the other tool.

To stop the weekly expiry, the user can publish the OAuth app to production at https://console.cloud.google.com/auth/audience?project=your-gcp-project.

## Related

Search-side data (impressions, queries, average position, clicks from Google Search) is in the sibling **search-console** skill (`~/.config/ga/gsc`), same login.
