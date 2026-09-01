# 🎮 Donzumari Stage Balance Guide

## Overview

This guide explains how to analyze and adjust stage difficulty in Donzumari to ensure balanced, progressive gameplay from stages 1-20.

---

## Stage Structure

### Easy Stages (1-5): Tutorial & Foundations
- **Purpose**: Teach players core mechanics
- **Target Clear Rate**: 50-90%
- **Player Base**: New players, casual gamers
- **Progression**: Gradually introduce more instability

### Intermediate Stages (6-15): Skill Development
- **Purpose**: Challenge players to master techniques
- **Target Clear Rate**: 30-50%
- **Player Base**: Regular players, competitive casual
- **Progression**: Mix stable and unstable parcels

### Advanced Stages (16-20): Mastery & Legends
- **Purpose**: Ultimate challenge for skilled players
- **Target Clear Rate**: 5-20%
- **Player Base**: Hardcore players, speed runners
- **Progression**: Primarily unstable and rare parcels

---

## Difficulty Parameters

Each stage has configurable difficulty parameters:

```dart
StageDifficulty(
  stageNumber: 1,
  name: 'チュートリアル',
  targetHeight: 100,           // Height players should achieve
  targetClearTime: 60,          // Expected clear time (seconds)
  allowedStability: [...],      // Which parcel types allowed
  parcelCountMin: 3,            // Minimum parcels to spawn
  parcelCountMax: 5,            // Maximum parcels to spawn
  parcelCountStable: 0.7,       // 70% of parcels should be stable
  difficultyMultiplier: 0.5,    // Physics difficulty scale
)
```

---

## Key Metrics

### Clear Rate
The percentage of attempts that successfully complete the stage.
- **Calculation**: (Successful Clears) / (Total Attempts)
- **Good Range**: 70-90% of expected

### Expected Clear Rate
Derived from difficulty multiplier:
- **Formula**: 1.0 / (difficultyMultiplier * 1.5)
- **Stage 1**: 1.0 / (0.5 * 1.5) = 133% → capped at realistic ~70%
- **Stage 20**: 1.0 / (2.4 * 1.5) = 28% → realistic ~20%

### Average Height
Average tower height achieved (completed or failed).
- **Indicates**: How well players are performing
- **Compare to**: Target height for the stage

---

## Balance Analysis Tool

### Generating a Balance Report

```dart
final analyticsService = StageAnalyticsService(firestore: FirebaseFirestore.instance);

// Generate full report
final report = await analyticsService.generateBalanceReport(daysBack: 30);
print(report);

// Get problematic stages
final problematic = await analyticsService.getProblematicStages(daysBack: 30);
for (final stage in problematic) {
  print(stage.getReport());
}

// Get metrics for specific stage
final metrics = await analyticsService.getStageMetrics(5);
print(metrics.getDetailedReport());
```

---

## Adjustment Scenarios

### 🟥 Stage is TOO HARD (Clear Rate < Expected * 0.7)

**Symptoms:**
- Frustration in player feedback
- Very low clear rate
- Players stuck for extended time
- High drop-off rate

**Solutions:**

1. **Reduce Parcel Instability**
   - Lower `parcelCountStable` (increase % of stable parcels)
   - Remove unstable parcels from `allowedStability`
   - Example: `parcelCountStable: 0.7` → `0.8` (10% more stable)

2. **Reduce Parcel Count**
   - Lower `parcelCountMax`
   - Lower `parcelCountMin`
   - Example: `parcelCountMax: 12` → `10`

3. **Increase Target Time**
   - Raise `targetClearTime`
   - Gives players more time to think
   - Example: `targetClearTime: 120` → `150`

4. **Lower Physics Difficulty**
   - Reduce `difficultyMultiplier`
   - Makes physics more forgiving
   - Example: `difficultyMultiplier: 1.5` → `1.4`

**Priority Order**: Stability > Count > Time > Multiplier

### 🟩 Stage is TOO EASY (Clear Rate > Expected * 1.3)

**Symptoms:**
- No challenge, boring gameplay
- Very high clear rate (>80% for intermediate stages)
- Players rushing through
- No skill differentiation

**Solutions:**

1. **Increase Parcel Instability**
   - Raise `parcelCountStable` (decrease % of stable parcels)
   - Add unstable parcels to `allowedStability`
   - Example: `parcelCountStable: 0.6` → `0.4` (20% fewer stable)

2. **Add More Parcels**
   - Raise `parcelCountMax`
   - Raise `parcelCountMin`
   - Example: `parcelCountMin: 5` → `7`

3. **Reduce Target Time**
   - Lower `targetClearTime`
   - Pressures players to be quick
   - Example: `targetClearTime: 120` → `90` (only for stages 8+)

4. **Increase Physics Difficulty**
   - Raise `difficultyMultiplier`
   - Makes physics less forgiving
   - Example: `difficultyMultiplier: 1.5` → `1.6`

**Priority Order**: Stability > Count > Multiplier > Time

---

## Progression Curve Guidelines

### Easy Stages (1-5)
- Start: **70% stable** → Focus on learning
- End: **50% stable** → Ready for intermediate

### Intermediate Stages (6-15)
- Stages 6-10: **40% stable** → Skill building
- Stages 11-15: **10% stable** → Mastery challenge

### Advanced Stages (16-20)
- All stages: **5% or 0% stable** → Pure skill
- Multiplier: **2.0-2.4** → Maximum difficulty

---

## Real-World Adjustment Process

### Step 1: Collect Data
```dart
// Wait at least 30 days for meaningful data
// Need minimum 5 attempts per stage
final metrics = await analyticsService.getAllStageMetrics(daysBack: 30);
```

### Step 2: Identify Issues
```dart
// Find stages that need adjustment
final problematic = await analyticsService.getProblematicStages(daysBack: 30);
problematic.forEach((stage) {
  if (stage.issue == 'TOO_HARD') {
    print('Stage ${stage.stageNumber} is too hard (${(stage.clearRate*100).toStringAsFixed(1)}%)');
  }
});
```

### Step 3: Make Adjustments
Edit `difficulty_service.dart`:
```dart
// Before (too hard)
15: StageDifficulty(
  stageNumber: 15,
  parcelCountStable: 0.05,
  parcelCountMax: 26,
  difficultyMultiplier: 1.8,
),

// After (adjusted)
15: StageDifficulty(
  stageNumber: 15,
  parcelCountStable: 0.15,  // 10% more stable
  parcelCountMax: 22,       // Fewer parcels
  difficultyMultiplier: 1.7, // Slightly easier physics
),
```

### Step 4: Test Changes
- Update stage configuration
- Run test games on the stage
- Play 5-10 games to feel the new difficulty
- Commit changes

### Step 5: Monitor Results
- Wait 1-2 weeks for new data
- Re-run balance report
- Verify clear rate moved toward target
- Iterate if needed

---

## Common Issues & Solutions

### 🔴 Players Get Stuck at Stage 5-6
**Issue**: Big jump in difficulty between easy and intermediate

**Solution**:
- Reduce `parcelCountStable` in stage 6 from 0.4 → 0.5
- Reduce `difficultyMultiplier` from 1.0 → 0.95

### 🔴 Stages 8-10 Too Clustered
**Issue**: Similar difficulty across 3 stages, no progression

**Solution**:
- Stage 8: `difficultyMultiplier: 1.1` (keep easier)
- Stage 9: `difficultyMultiplier: 1.3` (mid point)
- Stage 10: `difficultyMultiplier: 1.4` (harder)
- Increment multipliers by 0.1 per stage

### 🔴 Advanced Stages (16-20) Not Differentiated
**Issue**: All stages feel the same difficulty

**Solution**:
- Gradually reduce `parcelCountStable` from 5% → 0%
- Slowly increase `difficultyMultiplier` from 2.0 → 2.4
- Reduce `targetClearTime` as stages progress

---

## Testing Checklist

After making adjustments:

- [ ] Stage configuration updated in code
- [ ] No syntax errors (code compiles)
- [ ] Firestore updated with new parcel sets
- [ ] Test game runs on target stage 5+ times
- [ ] Clear feels right (not too easy, not too hard)
- [ ] Height progression is smooth
- [ ] Physics behavior matches expected difficulty
- [ ] Changes committed to branch
- [ ] PR created with clear explanation
- [ ] Wait for player feedback (1-2 weeks)
- [ ] Metrics re-analyzed for success

---

## Parcel Stability Reference

### 🟢 Stable Parcels (Easy to Stack)
- Small box, medium box, letter
- Cylinder, book
- Pizza box (rare)

**Use for**: Stages 1-10, foundation of harder stages

### 🟡 Moderate Parcels (Medium Challenge)
- Triangle box, tall box, wide box
- Round item, slanted box
- Plant (rare), tire (rare)

**Use for**: Stages 5-18, mixing with stable/unstable

### 🔴 Unstable Parcels (Hard to Stack)
- Narrow tower, wobble cone, tilted cube
- Asymmetric, top-heavy
- Dumbbell (rare), crown (rare)

**Use for**: Stages 12-20, maximum challenge

---

## Performance Optimization

### Physics Difficulty Multiplier Effects
- **0.5**: Very easy (stage 1), good learning
- **1.0**: Normal, well-balanced
- **1.5**: Challenging, requires skill
- **2.0+**: Very hard, expert only

### Parcel Count Effects
- **3-5**: Tutorial, very controlled
- **8-12**: Standard gameplay
- **18-30**: High stress, lots of options

### Stability Proportion Effects
- **70% stable**: Learning phase
- **50% stable**: Intermediate start
- **10% stable**: Expert play
- **0% stable**: Maximum difficulty

---

## FAQ

**Q: Should I adjust multiple stages at once?**
A: No, adjust one or two stages at a time. Wait 1-2 weeks to see the effect.

**Q: How many attempts do I need for valid data?**
A: Minimum 5 per stage, ideally 20+ for reliable metrics.

**Q: What's the best time to collect data?**
A: After at least 30 days of actual player gameplay.

**Q: Should I adjust based on feedback alone?**
A: No, use metrics. Feedback can be biased. Combine feedback + data.

**Q: Can I have too many stable parcels?**
A: Yes. Stages 1-5 should max out at 70% stable, stages 16+ should have <5%.

---

## Version History

- **v1.0** (2026-08-29): Initial difficulty system with 20 stages, analytics service, balance framework

---

## Contact & Support

For questions about stage balance or difficulty adjustment:
- Check balance metrics using `StageAnalyticsService`
- Review this guide's progression guidelines
- Run test games to verify feel
- Create issue if pattern doesn't match expectations
