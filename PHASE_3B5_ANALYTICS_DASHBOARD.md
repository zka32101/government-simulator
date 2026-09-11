# Phase 3B.5: Analytics Dashboard & Reporting Guide

## Overview

Phase 3B.5 provides comprehensive guidance for accessing and analyzing user data from Firebase Analytics. This guide covers dashboard setup, custom reports, audience segmentation, and data interpretation.

## Firebase Analytics Console Access

### 1. Navigate to Analytics Dashboard
1. Open [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `government-simulator`
3. Go to **Analytics** in the left sidebar
4. Click **Reports** to view the dashboard

## Key Analytics Reports

### Real-Time Analytics

**Location:** Analytics > Reports > Realtime

**What it shows:**
- Active users in the last 30 minutes
- Events happening right now
- Current user locations and devices
- Real-time event parameters

**Use case:** Monitor live events during gameplay sessions or immediately after feature launches

```
Example: Watch policy_chosen events fire in real-time as players make decisions
```

### Lifecycle Reports

**Location:** Analytics > Reports > Lifecycle

#### User Acquisition
- Show where new users come from
- Track install source (organic, ads, referral)
- Compare user quality by source

#### Engagement
- Session duration by user segment
- Event frequency per user
- User retention trends

#### Monetization
- Conversion to paid (isPurchased)
- Revenue by difficulty level
- In-app purchase adoption

#### Retention
- Day 1, 7, 30 retention rates
- User cohort analysis
- Churn prediction

### User Analytics

**Location:** Analytics > Reports > User Properties

**View custom user properties:**
- `authenticated` - User auth status (true/false)
- `game_style` - Playing style (aggressive/balanced/conservative)
- `total_playtime_minutes` - Cumulative playtime
- `game_completions` - Number of finished games

**Analyze by segment:**
- Filter users by authentication status
- Compare playstyle preferences
- Identify high-engagement users (playtime > 300 min)
- Find expert players (completions >= 5)

## Event Analytics Reports

### Event Flow Analysis

**Location:** Analytics > Reports > Events

**Key events to monitor:**

#### Game Lifecycle Events
```
game_started
  ↓
policy_chosen (multiple)
  ↓
year_end (multiple)
  ↓
game_over
```

**Metrics to track:**
- Funnel completion rate: game_started → game_over
- Average events per session: count of policy_chosen per session
- Time spent per year: time between year_end events

#### Decision Quality Analysis
Monitor `policy_chosen` event parameters:
- `impact_score`: Distribution of decision quality scores
- `event_category`: Most popular policy categories
- `year`, `day`: When players make decisions (early game vs late game)

**Insights:**
- High-impact decisions earlier in games indicate better planning
- Certain categories might be overused or underused
- End-game decision patterns differ from early-game patterns

#### Achievement Tracking
Via `achievement_unlocked` events:
- Unlock rate by achievement type
- Time to unlock (progression speed)
- Achievement rarity (percentage of players)

**Identify:**
- Too-easy achievements (> 80% unlock rate)
- Too-hard achievements (< 5% unlock rate)
- Balanced achievements (20-50% unlock rate)

### Custom Event Reports

**Location:** Analytics > Reports > Events > [Event Name]

**Setup for each event type:**

#### game_started Report
- Count by `difficulty` level (normal/scenario/stage)
- Segment by `scenario_id` to track popularity
- Compare `country_name` popularity

Useful questions:
- Which difficulty do most players choose?
- Which scenarios/stages are most popular?
- How many times do players retry after game over?

#### policy_chosen Report
- Average `impact_score` by `event_category`
- Identify `event_category` distribution (are some overused?)
- Track decision frequency per session

Policy balance insights:
- If economic category has high impact scores, policies might be too powerful
- If military has low frequency, players might avoid those choices

#### game_over Report
- Distribution of `gameOverType` (victory/defeat/custom)
- Average `year` reached (game length)
- Final scores: `finalGdp`, `finalSatisfaction`, `finalHealthScore`

Game difficulty insights:
- If average year reached is too low, game might be too hard
- If most games end in victory, game might be too easy
- Satisfaction vs GDP vs stability balance

#### year_end Report
- Track `satisfactionChange` trends over years
- Monitor `gdpChange` stability
- Identify `decisionsInYear` average (player pace)

Gameplay patterns:
- Steep satisfaction drops indicate policy consequences
- Consistent GDP growth shows economic stability
- Decision count shows player engagement level

## Custom Dashboards

### Creating a Custom Dashboard

**Location:** Analytics > Custom Dashboards

**Steps:**
1. Click **Create Dashboard**
2. Name it (e.g., "Government Simulator Health Dashboard")
3. Add cards for key metrics:

### Recommended Dashboard: Game Health

**Card 1: Daily Active Users (DAU)**
- Metric: User Count
- Filter: Authenticated = true
- Timeframe: Last 30 days
- Goal: Growing DAU indicates healthy engagement

**Card 2: Session Length**
- Metric: Average Session Duration
- Segment by `game_style`
- Goal: > 10 minutes average indicates engaging gameplay

**Card 3: Policy Decision Rate**
- Metric: Event Count (policy_chosen)
- Filter by timeframe
- Divide by DAU for per-user metric
- Goal: > 5 decisions per user per session

**Card 4: Game Completion Rate**
- Metric: game_over event count / game_started event count
- Track as percentage
- Goal: 40-60% indicates balanced difficulty

**Card 5: Achievement Unlock Distribution**
- Metric: Count of achievement_unlocked by achievementId
- Top 10 achievements
- Goal: Varied unlock rates (5%-80%) indicates good achievement design

**Card 6: Platform/Device Distribution**
- Metric: User Count by Device OS
- Helps identify platform-specific issues
- Goal: Balanced distribution or expected platform preferences

## Audience Segmentation

### Predefined Audiences to Create

**Location:** Analytics > Audiences

#### 1. Active Players
```
Conditions:
- User engagement: Active users (used app in last 7 days)
- Metrics: User engagement score > 50
```

#### 2. High-Value Players
```
Conditions:
- Lifetime value: Purchased content (isPurchased = true)
- Playtime: total_playtime_minutes > 300
```

#### 3. Expert Players
```
Conditions:
- game_completions >= 5
- authenticated = true
- total_playtime_minutes > 500
```

#### 4. At-Risk Players
```
Conditions:
- Last app engagement: > 7 days ago
- But: session_duration < 5 minutes on last session
- Indicates: Players who opened app but didn't engage
```

#### 5. Tutorial Incomplete
```
Conditions:
- Event: game_started (recent)
- No event: policy_chosen (in last 24 hours)
- Indicates: Players stuck in tutorial or early game
```

### Using Audiences for Targeting

Once audiences are created:
1. Use them to create user lists for push notifications
2. A/B test features with specific audiences
3. Create targeted guides for at-risk segments
4. Celebrate achievements with high-value player segments

## Data Interpretation Guides

### Funnel Analysis: Game Flow

**Setup Funnel:**
```
game_started → policy_chosen → game_over
```

**Analyze funnel steps:**
- Step 1→2: % of players making first decision
  - Goal: > 80%
  - Low rate: Tutorial might be confusing
  
- Step 2→3: % of players finishing games
  - Goal: 40-60%
  - Too high: Game might be too easy
  - Too low: Game might be too hard or tedious

**Funnel insights:**
```
Example 1: 100% game_started, 50% policy_chosen, 30% game_over
Problem: Players not making decisions - tutorial issue

Example 2: 100% game_started, 95% policy_chosen, 10% game_over
Problem: High dropout after first choice - might be difficulty spike

Example 3: 100% game_started, 90% policy_chosen, 60% game_over
Healthy: Good engagement through full game lifecycle
```

### Retention Cohort Analysis

**Understanding Retention:**
- **Day 1 Retention**: % of users who return within 1 day
  - Goal: > 50%
  
- **Day 7 Retention**: % of users who return within 7 days
  - Goal: > 25%
  
- **Day 30 Retention**: % of users who return within 30 days
  - Goal: > 15%

**Poor Retention Indicators:**
- Day 1 retention < 30%: Game is not engaging
- Sharp drop-off after day 3: Tutorial/early game fails
- Consistent decline: Lack of new content/goals

**Improving Retention:**
1. Analyze when churn happens (which year/day of gameplay?)
2. Look at last event before churn (stuck on hard decision?)
3. A/B test onboarding changes to high-churn segment

## Setting Alerts

### Firebase Analytics Alerts

**Location:** Analytics > Settings > Alerts

Create alerts for:
1. **DAU drops by 20%** - Indicates technical issue or major problem
2. **Crash rate > 5%** - Critical performance issue
3. **Funnel drop > 30% at any step** - User flow issue
4. **New error code detected** - Unexpected exception

**Alert actions:**
- Send email to team
- Investigate quickly if alert fires
- Correlate with recent code changes

## Export Data for Analysis

### BigQuery Integration

**Location:** Analytics > Settings > Integration > BigQuery

**Benefits:**
- Raw event data for custom analysis
- SQL queries for complex questions
- Export to Google Sheets for visualization
- Machine learning on user behavior

**Useful queries:**
```sql
-- Average game length by difficulty
SELECT
  STRUCT(params.value.string_value) as difficulty,
  COUNT(*) as game_count,
  AVG(CAST(event_params.value.int_value AS FLOAT64)) as avg_year
FROM `project.analytics_XXXXXX.events_*`
WHERE event_name = 'game_over'
GROUP BY difficulty
ORDER BY avg_year DESC

-- Most popular policies
SELECT
  event_params.value.string_value as policy_name,
  COUNT(*) as frequency
FROM `project.analytics_XXXXXX.events_*`,
UNNEST(event_params) as event_params
WHERE event_name = 'policy_chosen'
AND event_params.key = 'policy_name'
GROUP BY policy_name
ORDER BY frequency DESC
LIMIT 10
```

## Troubleshooting Analytics

### Events Not Appearing in Dashboard

**Checklist:**
1. ✓ Events appear in Real-time within 30 seconds? (check Real-time tab)
2. ✓ Wait 24 hours for events to appear in reports (Firebase requirement)
3. ✓ Check event name spelling exactly matches service code
4. ✓ Verify parameters are string/int types (not complex objects)
5. ✓ Confirm analytics enabled in Firebase Console project settings

**Common issues:**
- Event names have typos (exact match required)
- Parameters exceed character limits (truncated)
- Event fired > 40KB (ignored by Firebase)
- Analytics disabled on device

### User Properties Not Showing

**Verification:**
1. User property appears in Custom Reports after 24 hours
2. Check **Events > [Event Name] > Parameters** tab
3. Confirm user property name matches exactly (case-sensitive)
4. Verify property value is valid string (max 100 chars)

**Debug steps:**
```dart
// In code:
await analytics.setUserProperty(name: 'game_style', value: 'aggressive');

// In console:
// Wait 24+ hours
// Check Analytics > Reports > User Properties
// Should see 'game_style' listed with values
```

### Retention Report Shows 0%

**Causes:**
- Firebase needs 2+ days of data to calculate retention
- Not enough users in cohort (< 20 users)
- User session dates don't allow cohort calculation

**Solution:**
- Wait 2+ days after launch
- Target more users before analyzing retention
- Check if app_update event exists (resets cohorts)

## Performance Monitoring with Analytics

### Identifying Performance Issues

**Metrics to track:**
1. **Session duration** - Longer sessions = better engagement
   - If decreasing over time: Performance degradation?
   
2. **Crash rate** - Should be < 1%
   - Monitor in Real-time crashes report
   
3. **Event delay** - Events should log within seconds
   - Check timestamps in custom SQL queries

### Optimization Opportunities

**Based on analytics data:**

1. **High-frequency events** (policy_chosen)
   - May be too granular or player is very active
   - Optimize for large-scale analytics if needed

2. **Low achievement unlock rate**
   - Too difficult
   - Might need hints or intermediate checkpoints

3. **Year-end event patterns**
   - If most games end at year 3, there's a difficulty spike
   - Rebalance early-to-mid-game transitions

4. **Policy category imbalance**
   - If players avoid certain categories, might be weak/frustrating
   - Buff weak policies or make them more relevant

## Monthly Analytics Review Checklist

**Every month, review:**
- [ ] DAU trend (growing, stable, declining?)
- [ ] Session length (are players engaged?)
- [ ] Funnel completion rate (how many finish games?)
- [ ] Retention cohorts (are players returning?)
- [ ] Crash/error rate (stability OK?)
- [ ] New events appearing (data pipeline working?)
- [ ] Achievement unlock rates (balanced difficulty?)
- [ ] Top user issues (from error logs)
- [ ] Feature adoption (if new features added)
- [ ] Player feedback (qualitative data)

**Create a monthly report with:**
1. Key metrics summary (DAU, retention, completion rate)
2. Trend analysis (month-over-month changes)
3. Anomalies detected (unexpected patterns)
4. Action items (what to fix/improve)
5. Hypotheses to test (A/B test ideas)

## Privacy & Compliance

### GDPR Considerations

**Firebase Analytics in GDPR context:**
- User data is anonymized by default (using advertising ID)
- No personally identifiable information (PII) in events
- User can disable analytics in Settings screen

**Implementation:**
```dart
// User disables analytics
await analytics.setAnalyticsEnabled(false);

// Firebase stops collecting events for this user
// Historical data is not deleted (GDPR allows this for legal reasons)
```

### Data Retention

- Firebase keeps raw events for 60 days
- Aggregated reports available for longer
- Enable BigQuery integration to archive longer

## Future Enhancements (Phase 4+)

### Machine Learning
- Predict churn before it happens
- Automatic anomaly detection
- User lifetime value prediction

### Advanced Segmentation
- Behavioral clustering (similar player archetypes)
- Personalized difficulty recommendations
- Dynamic difficulty based on analytics

### In-App Dashboards
- Show player stats on home screen
- Achievement progress tracking
- Leaderboards based on analytics

### A/B Testing
- Test policy balance changes
- Test UI improvements
- Test tutorial variations

---

**Documentation Status:** ✓ Phase 3B.5 Complete

**Next Phase:** Phase 4 - Advanced Analytics and Optimization

Last Updated: 2026-09-11
